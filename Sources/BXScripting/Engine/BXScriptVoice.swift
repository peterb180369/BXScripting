//**********************************************************************************************************************
//
//  BXScriptVoice.swift
//	External control for text to speech functionality
//  Copyright ©2024 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AVFAudio


//----------------------------------------------------------------------------------------------------------------------


public struct BXScriptVoice
{

	// MARK: - Languages
	
	
	/// Returns the code of the current UI languange
	///
	/// For an app that is only localized in a few languages (e.g. "en", "de", "fr") voices will only be chosen from this list.
	
	static var currentLanguageCode:String
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
	
	/// Tries to find the best available voice for the current UI language. Returns nil if not available. In this case the default system voice will be used.
	
	static var bestAvailableVoice:AVSpeechSynthesisVoice?
	{
		// Get current UI language

		let code = Self.currentLanguageCode

		// Filter installed system voices to currently running UI language, sorted by quality
		
		let voices = AVSpeechSynthesisVoice.speechVoices()
			.filter { Self.isCorrectLanguage($0,code) }						// remove all voices that do not match current UI language
			.filter { Self.isAcceptableVoice($0) } 							// remove all blacklisted voices (they are really bad)
			.sorted { $0.quality.rawValue < $1.quality.rawValue }			// sort by quality

print("\(voices)")

		// Use the highest quality voice that is available
		
		let voice = voices.last
print("USING: \(String(describing: voice))")
		return voice
	}
		

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
		
		// Remove other lower quality voices
		
		if voice.identifier.contains("en-IN") { return false }

		let blacklist:[String] =
		[
			"com.apple.voice.compact.en-ZA.Tessa",
			"com.apple.voice.compact.en-US.Samantha",
			"com.apple.voice.compact.en-IE.Moira",
			"com.apple.voice.compact.en-GB.Daniel",
			"com.apple.voice.compact.en-AU.Karen",
			"com.apple.ttsbundle.siri_Aaron_en-US_compact",
			
			"com.apple.ttsbundle.siri_Dan_fr-FR_compact",
			"com.apple.voice.compact.fr-FR.Thomas",
		]
		
		if blacklist.contains(voice.identifier)
		{
			return false
		}
		
		// This voice is acceptable
		
		return true
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

}


//----------------------------------------------------------------------------------------------------------------------
