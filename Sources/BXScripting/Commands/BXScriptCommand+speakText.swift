//**********************************************************************************************************************
//
//  BXScriptCommand+speakText.swift
//	Adds a speakText command that speaks a text
//  Copyright ©2023-2026 Peter Baumgartner. All rights reserved.
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
				let utterance = AVSpeechUtterance(attributedString:Self.speechString(for:text))
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
	
	/// Applies the registered pronunciations for the current language to the text that is to be spoken.
	///
	/// A term with a phonetic spelling stays in the text and gets its IPA notation attached as an attribute,
	/// so the synthesizer is told which phonemes to produce. A term with a spoken form is replaced outright,
	/// which is what a notation like "3/4" needs - it is not mispronounced, it is simply not meant to be read
	/// out literally.
	
	public static func speechString(for text:String) -> NSAttributedString
	{
		let code = BXScriptVoice.currentLanguageCode
		let pronunciations = BXScriptEnvironment.shared.speechPronunciationFixes[code] ?? [:]
		
		// Longest term first, so that a term which contains a shorter one wins. Dictionary order is not
		// stable, so without an explicit order the result could differ from one run to the next.
		
		let terms = pronunciations.keys.sorted
		{
			$0.count != $1.count ? $0.count > $1.count : $0 < $1
		}
		
		// Apply the replacements first, since they move the character offsets that the attributes below
		// are attached to.
		
		var text = text
		
		for term in terms
		{
			guard case .spoken(let replacement) = pronunciations[term] else { continue }
			
			let mutable = NSMutableString(string:text)
			
			for range in Self.ranges(of:term, in:text).reversed()
			{
				mutable.replaceCharacters(in:range, with:replacement)
			}
			
			text = mutable as String
		}
		
		// Then attach the phonetics to whatever is left
		
		let string = NSMutableAttributedString(string:text)
		let key = NSAttributedString.Key(rawValue:AVSpeechSynthesisIPANotationAttribute)
		
		for term in terms
		{
			guard case .phonetic(let ipa) = pronunciations[term] else { continue }
			
			for range in Self.ranges(of:term, in:text)
			{
				string.addAttribute(key, value:ipa, range:range)
			}
		}
		
		return string
	}
	
	
	/// Returns the ranges of all whole word occurrences of a term.
	///
	/// The word boundary check is what keeps a short term like "TV" from also matching inside "TVs". Note
	/// that a trailing apostrophe does not count as a boundary violation, so "FotoMagico's" still has its
	/// phonetics applied to the name itself.
	
	static func ranges(of term:String, in text:String) -> [NSRange]
	{
		let string = text as NSString
		let length = string.length
		var ranges:[NSRange] = []
		var location = 0
		
		while location < length
		{
			let searchRange = NSRange(location:location, length:length-location)
			let range = string.range(of:term, options:[], range:searchRange)
			guard range.location != NSNotFound else { break }
			
			if Self.isWholeWord(range, in:string)
			{
				ranges.append(range)
			}
			
			location = range.location + max(range.length,1)
		}
		
		return ranges
	}
	
	
	private static func isWholeWord(_ range:NSRange, in string:NSString) -> Bool
	{
		func isLetterOrDigit(at index:Int) -> Bool
		{
			guard let scalar = Unicode.Scalar(string.character(at:index)) else { return false }
			return CharacterSet.alphanumerics.contains(scalar)
		}
		
		if range.location > 0 && isLetterOrDigit(at:range.location-1) { return false }
		
		let end = range.location + range.length
		if end < string.length && isLetterOrDigit(at:end) { return false }
		
		return true
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


// MARK: - Builder


// The following functions provide the high-level syntax for the commands above. They simply forward to the low-level
// factory functions. Capitalized function names are necessary, because a command cannot be written with leading dot
// syntax as a statement inside a @BXScriptBuilder body - the compiler would parse consecutive lines that start with
// a dot as a single method chain.


public func SpeakText(_ text:@escaping @autoclosure ()->String, blockUI:Bool = true, wait:Bool = true) -> BXScriptCommand
{
	.speakText(text(), blockUI:blockUI, wait:wait)
}


//----------------------------------------------------------------------------------------------------------------------
