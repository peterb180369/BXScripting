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
	/// Tries to find the best available voice for the current language. Returns nil if not available. In this case the default system voice will be used.
	
	static var bestAvailableVoice:AVSpeechSynthesisVoice?
	{
		let code = Self.currentLanguageCode()
		
		let voices = Self.speechVoices()
			.filter { $0.language == code }
			.filter { $0.quality != .default }
			.sorted { $0.quality.rawValue < $1.quality.rawValue }
		
		return voices.last
	}
}
 
 
//----------------------------------------------------------------------------------------------------------------------

