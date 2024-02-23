//**********************************************************************************************************************
//
//  BXScriptCommand+speakText.swift
//	Adds a speakText command that speaks a text
//  Copyright ©2023-2024 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AVFAudio
import AppKit


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_speakText
{
	public static func speakText(_ text:@escaping @autoclosure ()->String, blockUI:Bool = true, wait:Bool = true) -> BXScriptCommand
	{
		BXScriptCommand_speakText(text:text, blockUI:blockUI, wait:wait)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command speaks the specified text.

public struct BXScriptCommand_speakText : BXScriptCommand, BXScriptCommandCancellable
{
	// Params
	
	public var text:()->String
	public var blockUI:Bool
	public var wait:Bool
	
	// Text to Speech
	
	fileprivate static var synthesizer:AVSpeechSynthesizer? = nil
	fileprivate static var delegate = BXScriptCommandSpeakDelegate()
	
	// Execution support
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
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
				
				let text = text()
				let fixedText = Self.fixPronunciation(for:text)
				let utterance = AVSpeechUtterance(string:fixedText)
				utterance.voice = BXScriptVoice.bestAvailableVoice
				Self.delegate.utterance = utterance
				Self.delegate.updateVolume()

				// Start speaking
				
				if blockUI && wait { Self.delegate.startBlockingWindow() }
				
				Self.synthesizer?.speak(utterance)
				BXSubtitleWindowController.shared.text = text
			}
			
			// If waiting for end is not desired, then we can continue to the next command immediately
			
			if !wait
			{
				Self.delegate.endBlockingWindow()
				Self.delegate.didCallCompletionHandler = true
				self.completionHandler?()
			}
		}
	}
	
	public func cancel()
	{
		Self.synthesizer?.stopSpeaking(at:.immediate)
		Self.delegate.cleanup()
	}
	
	/// Checks if we have any registered pronunciation fixes for the current language. If yes, then all occurances in the text will be replaced with the fixes that
	/// force a better pronunciation.
	
	public static func fixPronunciation(for text:String) -> String
	{
		var text = text
		let code = BXScriptVoice.currentLanguageCode
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
	static var blockingWindow:NSWindow? = nil
	
	override init()
	{
		super.init()
		
		self.observers += NotificationCenter.default.publisher(for:BXScriptEngine.didPauseNotification, object:nil).sink
		{
			[self] _ in self.pause()
		}
	}
	
	// AVSpeechSynthesizerDelegate
	
    public func speechSynthesizer(_ synthesizer:AVSpeechSynthesizer, didStart utterance:AVSpeechUtterance)
    {
		BXScriptVoice.didStartSpeakingHandler?()
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
    
    /// Installs a transparent window that covers the whole window and catches all mouse events
	
    func startBlockingWindow()
    {
		guard let window = BXScriptVoice.blockedWindowWhileSpeaking else { return }
		
		let frame = window.contentView?.frame ?? .zero
		let view = BXBlockingView(frame:frame)
		view.autoresizingMask = [.width,.height]
//		view.wantsLayer = true
//		view.layer?.borderColor = NSColor.green.cgColor
//		view.layer?.borderWidth = 1.0
		
		window.contentView?.addSubview(view, positioned:.above, relativeTo:nil)
    }
    
    /// Removes the blocking window again
	
    func endBlockingWindow()
    {
		BXScriptVoice.blockedWindowWhileSpeaking?
			.contentView?
			.subviews
			.compactMap { $0 as? BXBlockingView }
			.forEach { $0.removeFromSuperview() }
    }
    
    /// Performs cleanup after speaking
    
    func cleanup()
    {
		self.endBlockingWindow()
		
		self.utterance = nil
		BXScriptCommand_speakText.synthesizer = nil
		BXSubtitleWindowController.shared.text = nil
		BXScriptVoice.didStopSpeakingHandler?()
    }
}
 
 
//----------------------------------------------------------------------------------------------------------------------


/// This view class swallows all mouse events. If it is installed above all other window views, it effectively disabled the UI

fileprivate class BXBlockingView : NSView
{
	override func acceptsFirstMouse(for event:NSEvent?) -> Bool
	{
		true
	}
	
	override func mouseDown(with event:NSEvent)
	{
		NSSound.beep()
	}

	override func mouseDragged(with event:NSEvent)
	{

	}

	override func mouseUp(with event:NSEvent)
	{

	}

	override func rightMouseDown(with event:NSEvent)
	{
		NSSound.beep()
	}

	override func rightMouseDragged(with event:NSEvent)
	{

	}

	override func rightMouseUp(with event:NSEvent)
	{

	}

	override func otherMouseDown(with event:NSEvent)
	{
		NSSound.beep()
	}

	override func otherMouseDragged(with event:NSEvent)
	{

	}

	override func otherMouseUp(with event:NSEvent)
	{

	}
}


//----------------------------------------------------------------------------------------------------------------------
