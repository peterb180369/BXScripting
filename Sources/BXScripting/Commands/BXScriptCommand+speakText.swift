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
				
				if blockUI && wait { Self.delegate.installBlockingWindow() }
				
				Self.synthesizer?.speak(utterance)
				BXSubtitleWindowController.shared.text = text
			}
			
			// If waiting for end is not desired, then we can continue to the next command immediately
			
			if !wait
			{
				Self.delegate.removeBlockingWindow()
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
    
    /// Installs a transparent window that covers the whole screen and catches all mouse events
	
    func installBlockingWindow()
    {
		guard let screen = NSScreen.main else { return }
		let frame = screen.frame
		
		if Self.blockingWindow == nil
		{
			let window = NSPanel(contentRect:frame, styleMask:[.borderless], backing:.buffered, defer:true)
			window.level = .screenSaver
			window.backgroundColor = .clear
			window.isReleasedWhenClosed = false
			window.contentView = BXBlockingView(frame:CGRect(origin:.zero, size:frame.size))
			window.makeKeyAndOrderFront(nil)
			
			Self.blockingWindow = window
		}
		else
		{
			Self.blockingWindow?.setFrame(frame, display:true)
		}
    }
    
    /// Removes the blocking window again
	
    func removeBlockingWindow()
    {
		guard let window = Self.blockingWindow else { return }
		window.orderOut(nil)
		Self.blockingWindow = nil
    }
    
    /// Performs cleanup after speaking
    
    func cleanup()
    {
		self.removeBlockingWindow()
		
		self.utterance = nil
		BXScriptCommand_speakText.synthesizer = nil
		BXSubtitleWindowController.shared.text = nil
		BXScriptVoice.didStopSpeakingHandler?()
    }
}
 
 
//----------------------------------------------------------------------------------------------------------------------


fileprivate class BXBlockingView : NSView
{
	override init(frame:CGRect)
	{
		super.init(frame:frame)
		
		self.wantsLayer = true
		self.layer?.borderColor = NSColor.green.cgColor
		self.layer?.borderWidth = 1.0
		self.layer?.backgroundColor = CGColor(gray:0.0, alpha:0.01)
	}
	
	required init?(coder:NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}
	
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
