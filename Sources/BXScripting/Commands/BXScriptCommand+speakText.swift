//**********************************************************************************************************************
//
//  BXScriptCommand+speakText.swift
//	Adds a speakText command that speaks a text
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AVFAudio


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_speakText
{
	public static func speakText(_ text:String, wait:Bool = true) -> BXScriptCommand
	{
		BXScriptCommand_speakText(text:text, wait:wait)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command speaks the specified text.

public struct BXScriptCommand_speakText : BXScriptCommand, BXScriptCommandCancellable
{
	// Params
	
	public var text:String
	public var wait:Bool
	
	// Text to Speech
	
	fileprivate static var synthesizer:AVSpeechSynthesizer? = nil
	fileprivate static var delegate = BXScriptCommandSpeakDelegate()
	
	// Execution support
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	// Init
	
	public init(text: String, wait:Bool)
	{
		self.text = text
		self.wait = wait
	}
	
	// Execute
	
	public func execute()
	{
		self.queue.async
		{
			// If we still have somebody speaking, we cannot start a new speaker. Try again in the next runloop cycle.
			
			if Self.synthesizer != nil
			{
				self.execute()
				return
			}
			
			// Start speaking new text
			
			DispatchQueue.main.asyncIfNeeded
			{
				// Create speech synthesizer
				
				Self.synthesizer = AVSpeechSynthesizer()
				Self.synthesizer?.delegate = Self.delegate
				
				// Setup delegate
				
				Self.delegate.completionHandler = completionHandler
				Self.delegate.didCallCompletionHandler = false 

				// Setup text to be spoken
				
				let fixedText = Self.fixPronunciation(for:text)
				let utterance = AVSpeechUtterance(string:fixedText)
				utterance.voice = AVSpeechSynthesisVoice.bestAvailableVoice
				Self.delegate.utterance = utterance
				Self.delegate.updateVolume()

				// Start speaking
				
				Self.synthesizer?.speak(utterance)
				BXSubtitleWindowController.shared.text = text
			}
			
			// If waiting for end is not desired, then we can continue to the next command immediately
			
			if !wait
			{
				Self.delegate.didCallCompletionHandler = true
				self.completionHandler?()
			}
		}
	}
	
	public func cancel()
	{
		Self.synthesizer?.stopSpeaking(at:.immediate)
	}
	
	/// Checks if we have any registered pronunciation fixes for the current language. If yes, then all occurances in the text will be replaced with the fixes that
	/// force a better pronunciation.
	
	public static func fixPronunciation(for text:String) -> String
	{
		var text = text
		let code = AVSpeechSynthesisVoice.currentLanguageCode
		let pronunciationFixes = BXScriptEnvironment.shared.speechPronunciationFixes[code] ?? [:]

		for (key,value) in pronunciationFixes
		{
			text = text.replacingOccurrences(of:key, with:value)
		}
		
		return text
	}
 }


//----------------------------------------------------------------------------------------------------------------------


fileprivate class BXScriptCommandSpeakDelegate : NSObject, AVSpeechSynthesizerDelegate
{
	var observers:[Any] = []
	var utterance:AVSpeechUtterance? = nil
	var completionHandler:(()->Void)? = nil
	var didCallCompletionHandler = false
	
	override init()
	{
		super.init()
		
		self.observers += NotificationCenter.default.publisher(for:BXScriptEngine.didPauseNotification, object:nil).sink
		{
			[self] _ in self.pause()
		}

//		self.observers += NotificationCenter.default.publisher(for:BXScriptWindowController.muteAudioNotification, object:nil).sink
//		{
//			[self] _ in self.delegate.updateVolume()
//		}
	}
	
	// AVSpeechSynthesizerDelegate
	
    public func speechSynthesizer(_ synthesizer:AVSpeechSynthesizer, didStart utterance:AVSpeechUtterance)
    {
		BXScriptEngine.didStartSpeakingHandler?()
    }
    
	public func speechSynthesizer(_ synthesizer:AVSpeechSynthesizer, didFinish utterance:AVSpeechUtterance)
    {
		self.cleanup()
		if !didCallCompletionHandler { self.completionHandler?() }
    }

	public func speechSynthesizer(_ synthesizer:AVSpeechSynthesizer, didCancel utterance:AVSpeechUtterance)
    {
		self.cleanup()
    }
    
    /// Pauses or continues speaking
    
	func pause()
	{
		guard let synthesizer = BXScriptCommand_speakText.synthesizer else { return }
		
		if synthesizer.isPaused
		{
			synthesizer.continueSpeaking()
		}
		else
		{
			synthesizer.pauseSpeaking(at:.word)
		}
	}

	/// Sets the volume
	
    func updateVolume()
    {
		if let controller = BXScriptWindowController.shared, let utterance = utterance
		{
			utterance.volume = controller.muteAudio ? 0.0 : 1.0
		}
    }
    
    /// Performs cleanup after speaking
    
    func cleanup()
    {
		self.utterance = nil
		BXScriptCommand_speakText.synthesizer = nil
		BXSubtitleWindowController.shared.text = nil
		BXScriptEngine.didStopSpeakingHandler?()
    }
}
 
 
//----------------------------------------------------------------------------------------------------------------------


extension AVSpeechSynthesisVoice
{
	/// Tries to find the best available voice for the current UI language. Returns nil if not available. In this case the default system voice will be used.
	
	static var bestAvailableVoice:AVSpeechSynthesisVoice?
	{
		// Get current UI language

		let code = Self.currentLanguageCode

		// Filter installed system voices to currently running UI language, sorted by quality
		
		let voices = Self.speechVoices()
			.filter { Self.isCorrectLanguage($0,code) }						// remove all voices that do not match current UI language
			.filter { Self.isAcceptable($0) } 								// remove all blacklisted voices (they are really bad)
			.sorted { $0.quality.rawValue < $1.quality.rawValue }			// sort by quality

print("\(voices)")

		// Use the highest quality voice that is available
		
		let voice = voices.last
print("USING: \(voice)")
		return voice
	}
	
	
	/// Returns the code of the current UI languange
	
	static var currentLanguageCode:String
	{
		// Get current UI language
		
		let preferredLanguages = Bundle.main.preferredLocalizations
		let language = preferredLanguages.first ?? Self.currentLanguageCode()
		
		// Older apps may stil be using "English.lproj" instead of "en.lproj". Convert "English" to "en"
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
	
	
	/// Removes voice that do not have the correct language code.
	
	static func isCorrectLanguage(_ voice:AVSpeechSynthesisVoice,_ code:String) -> Bool
	{
		voice.language.contains(code)
	}


	/// Removes blacklisted voices. These are being removed because they have insufficient quality and would thus create a bad impression.
	
	static func isAcceptable(_ voice:AVSpeechSynthesisVoice) -> Bool
	{
		// "Novelty" voices are really bad, so eliminate them
		
		if voice.identifier.contains("speech.synthesis.voice") { return false }
		
		// "Eloquence" voices are really bad, so eliminate them
		
		if voice.identifier.contains("eloquence") { return false }
		
		// Remove other blacklisted voices
		
		let blacklist:[String] =
		[
			"com.apple.voice.compact.en-ZA.Tessa",
			"com.apple.voice.compact.en-US.Samantha",
			"com.apple.ttsbundle.siri_Marie_fr-FR_compact",
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
}

 
//----------------------------------------------------------------------------------------------------------------------
