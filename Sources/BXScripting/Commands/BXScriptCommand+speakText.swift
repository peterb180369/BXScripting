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
	public var text:String
	public var wait:Bool
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	private let synthesizer = AVSpeechSynthesizer()
	private let delegate = BXScriptCommandSpeakDelegate()
	
	public init(text: String, wait:Bool)
	{
		self.text = text
		self.wait = wait
		
		self.delegate.observers += NotificationCenter.default.publisher(for:BXScriptEngine.didPauseNotification, object:nil).sink
		{
			[self] _ in self.pause()
		}

		self.delegate.observers += NotificationCenter.default.publisher(for:BXScriptWindowController.muteAudioNotification, object:nil).sink
		{
			[self] _ in self.delegate.updateVolume()
		}
	}
	
	public func execute()
	{
		self.queue.async
		{
			// If we still have somebody speaking, we cannot start a new speaker. Try again in the next runloop cycle.
			
			if BXScriptCommandSpeakDelegate.currentSpeaker != nil
			{
				self.execute()
				return
			}
			
			// Start speaking new text
			
			DispatchQueue.main.asyncIfNeeded
			{
				self.delegate.completionHandler = completionHandler

				let utterance = AVSpeechUtterance(string:text)
				utterance.voice = AVSpeechSynthesisVoice.bestAvailableVoice
				self.delegate.utterance = utterance
				self.delegate.updateVolume()
				
				self.synthesizer.delegate = self.delegate
				self.synthesizer.speak(utterance)
				
				BXScriptCommandSpeakDelegate.currentSpeaker = synthesizer
				
				BXSubtitleWindowController.shared.text = text
			}
			
			// If waiting for end is not desired, then we can continue to the next command immediately
			
			if !wait
			{
				self.delegate.didCallCompletionHandler = true
				self.completionHandler?()
			}
		}
	}
	
	public func cancel()
	{
		self.synthesizer.stopSpeaking(at:.immediate)
	}
	
	nonmutating func pause()
	{
		if synthesizer.isPaused
		{
			synthesizer.continueSpeaking()
		}
		else
		{
			synthesizer.pauseSpeaking(at:.word)
		}
	}
 }


//----------------------------------------------------------------------------------------------------------------------


fileprivate class BXScriptCommandSpeakDelegate : NSObject, AVSpeechSynthesizerDelegate
{
	var observers:[Any] = []
	var utterance:AVSpeechUtterance? = nil
	var didCallCompletionHandler = false
	var completionHandler:(()->Void)? = nil

	public static var currentSpeaker:AVSpeechSynthesizer? = nil
	
	func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance)
    {
		self.cleanup()
		if !didCallCompletionHandler { self.completionHandler?() }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance)
    {
		self.cleanup()
    }
    
    func cleanup()
    {
		BXSubtitleWindowController.shared.text = nil
		self.utterance = nil
		Self.currentSpeaker = nil
    }
    
    func updateVolume()
    {
		if let controller = BXScriptWindowController.shared, let utterance = utterance
		{
			utterance.volume = controller.muteAudio ? 0.0 : 1.0
		}
    }
}
 
 
//----------------------------------------------------------------------------------------------------------------------


extension AVSpeechSynthesisVoice
{
	/// Tries to find the best available voice for the current UI language. Returns nil if not available. In this case the default system voice will be used.
	
	static var bestAvailableVoice:AVSpeechSynthesisVoice?
	{
		// Get current UI language
		
		let preferredLanguages = Bundle.main.preferredLocalizations
		let language = preferredLanguages.first ?? Self.currentLanguageCode()
		
		// Older apps may stil be using "English.lproj" instead of "en.lproj". Convert "English" to "en"
		// to make sure that the following filtering works correctly.
		
		let code = Self.fixLanguageCode(for:language)

		// Filter installed system voices to currently running UI language, sorted by quality
		
		let voices = Self.speechVoices()
			.filter { $0.language.contains(code) }							// remove all voices that do not match current UI language
			.filter { Self.isAcceptable($0) } 								// remove all blacklisted voices (they are really bad)
			.sorted { $0.quality.rawValue < $1.quality.rawValue }			// sort by quality

		// Use the highest quality voice that is available
		
		let voice = voices.last
		print("\(voice)")
		return voice
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
