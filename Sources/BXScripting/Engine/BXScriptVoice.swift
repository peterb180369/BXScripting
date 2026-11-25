//**********************************************************************************************************************
//
//  BXScriptVoice.swift
//	External control for text to speech functionality
//  Copyright ©2024-2026 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AVFAudio
import AppKit


//----------------------------------------------------------------------------------------------------------------------


public struct BXScriptVoice
{

	// MARK: - Languages
	
	
	/// Returns the code of the current UI languange
	///
	/// For an app that is only localized in a few languages (e.g. "en", "de", "fr") voices will only be chosen from this list.
	
	public static var currentLanguageCode:String
	{
		// Get current UI language
		
		let preferredLanguages = Bundle.main.preferredLocalizations
		let language = preferredLanguages.first ?? AVSpeechSynthesisVoice.currentLanguageCode()
		
		// Older apps may still be using "English.lproj" instead of "en.lproj". Convert "English" to "en"
		// to make sure that the following filtering works correctly.
		
		return Self.fixLanguageCode(for:language)
	}
	
	
	/// Some old apps use English.lproj or German.lproj folders instead of en.lproj and de.lproj. This function converts old style language names
	/// to modern ISO  language codes.
	
	static func fixLanguageCode(for oldName:String) -> String
	{
		guard oldName.count > 2 else { return oldName }
		
		let name2code:[String:String] =
		[
			"Arabic": "ar",
			"Chinese": "zh",
			"Dutch": "nl",
			"English": "en",
			"French": "fr",
			"German": "de",
			"Italian": "it",
			"Japanese": "ja",
			"Korean": "ko",
			"Portuguese": "pt",
			"Russian": "ru",
			"Spanish": "es",
			"Swedish": "sv",
		]
		
		let code = name2code[oldName]
		return code ?? "en"
	}
	
	
	/// Removes voices that do not have the correct language code.
	
	static func isCorrectLanguage(_ voice:AVSpeechSynthesisVoice,_ code:String) -> Bool
	{
		voice.language.contains(code)
	}
	
	
//----------------------------------------------------------------------------------------------------------------------


	// MARK: - Voices
	
	
	/// Voice identifiers that should be used if they are installed, best first.
	///
	/// This is the escape hatch for an application that wants one particular voice, regardless of the ranking
	/// below. The first identifier in this list that is actually installed and acceptable wins outright.
	
	public static var preferredVoiceIdentifiers:[String] = []
	
	
	/// Tries to find the best available voice for the current UI language. Returns nil if none was found,
	/// in which case the default system voice will be used.
	///
	/// The result is cached, because finding it enumerates every voice installed on the system, while a
	/// tutorial speaks hundreds of sentences. The cache is dropped again when the user installs or removes
	/// a voice in System Settings.
	
	public static var bestAvailableVoice:AVSpeechSynthesisVoice?
	{
		if let voice = cachedVoice { return voice }
		
		Self.observeAvailableVoices()
		
		let voice = Self.bestVoice(for:Self.currentLanguageCode)
		cachedVoice = voice
		
		return voice
	}
	
	private static var cachedVoice:AVSpeechSynthesisVoice? = nil
	
	private static var availableVoicesObserver:Any? = nil
	
	
	/// Discards the cached voice, so that the next access picks a voice again
	
	public static func clearCachedVoice()
	{
		cachedVoice = nil
	}
	
	
	private static func observeAvailableVoices()
	{
		guard availableVoicesObserver == nil else { return }
		guard #available(macOS 14,*) else { return }
		
		availableVoicesObserver = NotificationCenter.default.addObserver(
			forName: AVSpeechSynthesizer.availableVoicesDidChangeNotification,
			object: nil,
			queue: .main)
		{
			_ in Self.clearCachedVoice()
		}
	}
	
	
//----------------------------------------------------------------------------------------------------------------------


	/// Picks the best voice for the specified language, without consulting the cache.
	///
	/// This is also the way to find out what would be chosen for a language other than the one the app is
	/// currently running in.
	
	public static func bestVoice(for code:String) -> AVSpeechSynthesisVoice?
	{
		// Discard everything that does not speak the requested language, and everything the application
		// considers unacceptable. Whatever is left gets ranked.
		
		let candidates = Self.acceptableVoices(for:code)
		
		// A voice that the application asked for by name wins outright, if it happens to be installed
		
		for identifier in preferredVoiceIdentifiers
		{
			if let voice = candidates.first(where:{ $0.identifier == identifier }) { return voice }
		}
		
		let regions = Self.preferredRegions(for:code, candidates:candidates)
		let selected = Self.selectedVoiceIdentifier(for:code)
		
		return candidates
			.sorted { Self.isBetter($0, than:$1, regions:regions, selected:selected) }
			.first
	}
	
	
	/// Returns all installed voices that speak the specified language and are considered good enough to use
	
	static func acceptableVoices(for code:String) -> [AVSpeechSynthesisVoice]
	{
		AVSpeechSynthesisVoice.speechVoices()
			.filter { Self.isCorrectLanguage($0,code) }
			.filter { Self.isAcceptableVoice($0) }
	}
	
	
	/// Returns true if the first voice is a better choice than the second one.
	///
	/// Quality is the dominant criterion, because a compact voice sounds bad enough that an unexpected accent
	/// is the lesser evil. The region only decides between voices of equal quality, which is the common case:
	/// a machine with three premium English voices installed has nothing else to go on.
	///
	/// The voice that the user picked in System Settings breaks a remaining tie, and the identifier breaks the
	/// last one. That final criterion matters more than it looks: without it the winner among equally ranked
	/// voices is whatever order the system happened to return them in, which is not stable.
	
	static func isBetter(_ voice1:AVSpeechSynthesisVoice, than voice2:AVSpeechSynthesisVoice, regions:[String], selected:String?) -> Bool
	{
		let quality1 = voice1.quality.rawValue
		let quality2 = voice2.quality.rawValue
		if quality1 != quality2 { return quality1 > quality2 }
		
		let region1 = Self.regionRank(of:voice1, in:regions)
		let region2 = Self.regionRank(of:voice2, in:regions)
		if region1 != region2 { return region1 < region2 }
		
		let isSelected1 = voice1.identifier == selected
		let isSelected2 = voice2.identifier == selected
		if isSelected1 != isSelected2 { return isSelected1 }
		
		return voice1.identifier < voice2.identifier
	}
	
	
	/// Returns the position of a voice's region in the list of preferred regions. Lower is better, and a
	/// region that is not in the list at all sorts behind every region that is.
	
	static func regionRank(of voice:AVSpeechSynthesisVoice, in regions:[String]) -> Int
	{
		let region = Self.regionCode(of:voice.language)
		return regions.firstIndex(of:region) ?? regions.count
	}
	
	
//----------------------------------------------------------------------------------------------------------------------


	// MARK: - Regions
	
	
	/// Returns the regions whose accent should be preferred for the specified language, best first.
	///
	/// Only regions that one of the candidate voices actually speaks are listed. Without that filter a German
	/// user would get "DE" at the head of the list for every language, which matches nothing and merely
	/// pushes the region that does match further down.
	
	static func preferredRegions(for code:String, candidates:[AVSpeechSynthesisVoice]) -> [String]
	{
		let available = Set(candidates.map { Self.regionCode(of:$0.language) })
		var regions:[String] = []
		
		func append(_ region:String)
		{
			guard !region.isEmpty else { return }
			guard available.contains(region) else { return }
			guard !regions.contains(region) else { return }
			regions.append(region)
		}
		
		// 1) The region of the system speech settings, but only when it speaks the same language. This is as
		// close as we can get to asking the user which accent they would like to hear.
		
		let systemLanguage = AVSpeechSynthesisVoice.currentLanguageCode()
		
		if Self.languageCode(of:systemLanguage) == code
		{
			append(Self.regionCode(of:systemLanguage))
		}
		
		// 2) The region the user lives in, so that a British or an Australian user gets their own accent.
		
		append(Self.currentRegionCode ?? "")
		
		// 3) The region that is the usual choice for this language. This is what a German user who runs the
		// app in English ends up with, since there are no English voices made for Germany.
		
		append(Self.defaultRegions[code] ?? "")
		
		return regions
	}
	
	
	/// The region whose accent is the usual choice for a language, used as the last resort
	
	public static var defaultRegions:[String:String] =
	[
		"ar" : "SA",
		"cs" : "CZ",
		"da" : "DK",
		"de" : "DE",
		"el" : "GR",
		"en" : "US",
		"es" : "ES",
		"fi" : "FI",
		"fr" : "FR",
		"he" : "IL",
		"hi" : "IN",
		"hu" : "HU",
		"id" : "ID",
		"it" : "IT",
		"ja" : "JP",
		"ko" : "KR",
		"nl" : "NL",
		"no" : "NO",
		"pl" : "PL",
		"pt" : "BR",
		"ro" : "RO",
		"ru" : "RU",
		"sk" : "SK",
		"sv" : "SE",
		"th" : "TH",
		"tr" : "TR",
		"zh" : "CN",
	]
	
	
	/// Returns the region the user lives in, e.g. "DE"
	
	static var currentRegionCode:String?
	{
		guard #available(macOS 13,*) else { return nil }
		return Locale.current.region?.identifier.uppercased()
	}
	
	
	/// Returns the language part of a BCP-47 language tag, e.g. "en" for "en-US"
	
	static func languageCode(of tag:String) -> String
	{
		String(tag.split(separator:"-").first ?? "")
	}
	
	
	/// Returns the region part of a BCP-47 language tag, e.g. "US" for "en-US", or an empty string if the
	/// tag does not carry a region.
	
	static func regionCode(of tag:String) -> String
	{
		let parts = tag.split(separator:"-")
		guard parts.count > 1, let last = parts.last else { return "" }
		
		// A region subtag is two letters (US) or three digits (419). Anything longer is a script subtag,
		// as in zh-Hans-CN.
		
		let region = String(last).uppercased()
		guard region.count == 2 || region.count == 3 else { return "" }
		
		return region
	}
	
	
//----------------------------------------------------------------------------------------------------------------------


	// MARK: - System Settings
	
	
	/// Returns the identifier of the voice that the user selected in System Settings for the specified
	/// language, or nil if there is none.
	///
	/// AVSpeechSynthesisVoice has no API that is documented to do this, but voiceWithLanguage() turns out to
	/// return exactly the per language selection from System Settings - the premium voice the user picked,
	/// not merely some default. Should that ever change, the worst case is that this returns a voice the user
	/// did not pick, and since it is only used to break a tie between equally ranked voices, nothing breaks.
	
	static func selectedVoiceIdentifier(for code:String) -> String?
	{
		AVSpeechSynthesisVoice(language:code)?.identifier
	}
	
	
//----------------------------------------------------------------------------------------------------------------------


	// MARK: - Filtering
	
	
	/// This external closure can filter installed voices.
	///
	/// You can use it to remove voices with insufficient quality, as these would create a bad impression.
	
	public static var isAcceptableVoice:(AVSpeechSynthesisVoice)->Bool =
	{
		(voice:AVSpeechSynthesisVoice)->Bool in
		
		// "Novelty" voices are really bad, so eliminate them
		
		if voice.identifier.contains("speech.synthesis.voice") { return false }
		
		// "Eloquence" voices are really bad, so eliminate them
		
		if voice.identifier.contains("eloquence") { return false }
		
		// Siri voices are reserved for the system. They are listed here, but the speech synthesizer does not
		// hand them to third party apps - asking for a French voice returns Thomas even when Siri's Marie is
		// the selected voice - so do not let them win the ranking and end up with silence.
		
		if voice.identifier.contains("siri") { return false }
		if voice.identifier.contains("ttsbundle") { return false }
		
		// Remove other lower quality voices
		
		if voice.identifier.contains("en-IN") { return false }

		// Apple ships the same voice in several variants, and the variant sits in the middle of the
		// identifier: Karen exists as both "compact" and "super-compact". Matching the trailing part of the
		// identifier catches every variant, while matching the whole identifier catches none of them.
		
		let blacklist:[String] =
		[
			"en-ZA.Tessa",
			"en-US.Samantha",
			"en-IE.Moira",
			"en-GB.Daniel",
			"en-AU.Karen",
			"fr-FR.Thomas",
		]
		
		if blacklist.contains(Self.voiceKey(for:voice))
		{
			return false
		}
		
		// This voice is acceptable
		
		return true
	}
	
	
	/// Returns the language and name part of a voice identifier, e.g. "en-AU.Karen" for the identifier
	/// "com.apple.voice.super-compact.en-AU.Karen"
	
	public static func voiceKey(for voice:AVSpeechSynthesisVoice) -> String
	{
		let parts = voice.identifier.split(separator:".")
		guard parts.count >= 2 else { return voice.identifier }
		
		return parts.suffix(2).joined(separator:".")
	}
	
	
//----------------------------------------------------------------------------------------------------------------------


	// MARK: - Debugging
	
	
	/// Returns a description of every candidate voice and the criteria it was ranked by, best first.
	///
	/// Use this to find out why a particular voice was chosen on a particular machine.
	
	public static func voiceRankingDescription(for code:String = Self.currentLanguageCode) -> String
	{
		let selected = Self.selectedVoiceIdentifier(for:code)
		let unsorted = Self.acceptableVoices(for:code)
		let regions = Self.preferredRegions(for:code, candidates:unsorted)
		let candidates = unsorted
			.sorted { Self.isBetter($0, than:$1, regions:regions, selected:selected) }
		
		var description = "BXScriptVoice: language \(code), preferred regions \(regions)\n"
		description += "selected in System Settings: \(selected ?? "none")\n"
		
		for voice in candidates
		{
			let marker = voice.identifier == candidates.first?.identifier ? "->" : "  "
			let isSelected = voice.identifier == selected ? " [system]" : ""
			description += "\(marker) q=\(voice.quality.rawValue) region=\(Self.regionRank(of:voice, in:regions)) \(voice.language) \(voice.name)\(isSelected) \(voice.identifier)\n"
		}
		
		return description
	}


//----------------------------------------------------------------------------------------------------------------------


	// MARK: - Ducking
	
	
	/// An external closure that will be called whenever speaking starts
	///
	/// An application can use this hook to start ducking audio that is currently playing
	
	public static var didStartSpeakingHandler:(()->Void)? = nil


	/// An external closure that will be called whenever speaking stops
	///
	/// An application can use this hook to stop ducking audio that is currently playing
	
	public static var didStopSpeakingHandler:(()->Void)? = nil


//----------------------------------------------------------------------------------------------------------------------


	// MARK: - UI Blocking
	
	
	/// If this property is set, then any UI interaction will be blocked while speaking is in progress.
	
	public static var blockedWindowWhileSpeaking:NSWindow? = nil
}


//----------------------------------------------------------------------------------------------------------------------
