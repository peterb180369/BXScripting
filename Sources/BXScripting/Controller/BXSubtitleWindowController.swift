//**********************************************************************************************************************
//
//  BXSubtitleWindowController.swift
//	Displays a transparent window at the bottom of the screen with audio subtitles
//  Copyright ©2024 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit
import SwiftUI


//----------------------------------------------------------------------------------------------------------------------


/// BXSubtitleWindowController displays a transparent window at the bottom of the screen with audio subtitles

public class BXSubtitleWindowController : NSWindowController, ObservableObject
{
	/// Singleton instance of the prefs window
	
	public static var shared:BXSubtitleWindowController = BXSubtitleWindowController()
	
	
	/// Set to true if spoken audio should be displayed as subtitles

	public var displaySubtitles:Bool
	{
		set
		{
			self.objectWillChange.send()
			UserDefaults.standard.set(newValue, forKey:"BXSubtitleWindowController.displaySubtitles")
			NotificationCenter.default.post(name:Self.displaySubtitlesNotification, object:newValue)
		}

		get
		{
			UserDefaults.standard.bool(forKey:"BXSubtitleWindowController.displaySubtitles")
		}
	}
	
	public static let displaySubtitlesNotification = Notification.Name("BXSubtitleWindowController.displaySubtitles")


	/// The text that is currently being narrated

	@Published public var text:String? = nil
	{
		didSet
		{
			if let text = text { self.displayedText = text }
			self.update()
		}
	}
	
	@Published public var displayedText:String = ""
	
	/// The size of the subtitle window
	
	@Published public var size = CGSize(1000,48)
	
	/// Subscribers
	
	private var subscribers:[Any] = []
	

//----------------------------------------------------------------------------------------------------------------------


	// MARK: - Lifecycle
	
	
	public init()
	{
		super.init(window:nil)
	}
	
	
	required init?(coder:NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}

	/// Creates the subtitle window
	
	override public func loadWindow()
	{
		// Create the view

		let view = BXSubtitleView(controller:self)
		let hostview = NSHostingView(rootView:view)
		let size = CGSize.zero // hostview.intrinsicContentSize

		// Create window

		let frame = CGRect(origin:.zero, size:size)
		let style:NSWindow.StyleMask = [.hudWindow,.nonactivatingPanel,.fullSizeContentView]
		let window = BXScriptControllerPanel(contentRect:frame, styleMask:style, backing:.buffered, defer:true)
		window.titlebarAppearsTransparent = true
		window.isMovableByWindowBackground = true
		window.isExcludedFromWindowsMenu = true
		window.collectionBehavior.insert(NSWindow.CollectionBehavior.fullScreenAuxiliary)
		window.isFloatingPanel = true
		window.becomesKeyOnlyIfNeeded = true
		window.hasShadow = false
		window.backgroundColor = NSColor(calibratedWhite:0.0, alpha:0.45)
		window.level = .screenSaver
		window.contentView = hostview
		
		self.window = window
	}
	
	
	func update()
	{
		if displaySubtitles
		{
			if let text = text, text.count > 0
			{
				self.cancelAllDelayedPerforms()
				self.showSubtitle(displayedText)
			}
			else
			{
				self.performCoalesced(#selector(hideSubtitle), delay:2)
			}
		}
		else
		{
			self.hideSubtitle()
		}
	}
	
	/// Shows the window and displays the specified subtitle text.
	
	@objc func showSubtitle(_ text:String)
	{
		if window == nil { self.loadWindow() }
		
		guard let screen = NSScreen.main else { return }
		guard let window = window else { return }
		
		// Get the main screen safe area (with inset)
		
		let safeArea = screen.visibleFrame.insetBy(dx:50, dy:50)

		// Measure the size of the text
		
		let margin:CGFloat = 12
		let maxWidth = safeArea.width - margin - margin

		let attributedText = NSAttributedString(string:text, attributes: [.font:NSFont.systemFont(ofSize:20)])
		let rect = attributedText.boundingRect(with: CGSize(maxWidth,1e8), options:[.usesLineFragmentOrigin,.usesFontLeading])
		let outer = rect.insetBy(dx:-margin, dy:-margin)
		let w = outer.width
		let h = outer.height
		
		self.size = CGSize(w,h)

		// Resize the window to text size
		
		var frame = safeArea
		frame.origin.x = safeArea.midX - round (0.5 * w)
		frame.origin.y = safeArea.minY
		frame.size = size
		window.setFrame(frame, display:true)
		
		// Show the window
		
		window.orderFront(nil)
	}
	
	/// Closes the subtitle window
	
	@objc func hideSubtitle()
	{
		window?.orderOut(nil)
	}
	
}


//----------------------------------------------------------------------------------------------------------------------


fileprivate extension NSObject
{
	/// Performs a method call after the specified delay. If multiple requests are queued up, the method will be
	/// called only once after the delay has elapsed. Please note that both the method selector and the argument
	/// need to be the same for coalescing to take effect.
	///
	/// - parameter selector: The single argument method to be called
	/// - parameter argument: The object argument to this method
	/// - parameter delay: This method will only be called after this optional delay has elapsed. If the delay is
	/// 0.0 it will be called during the next runloop cycle.
	
	func performCoalesced(_ selector: Selector, argument: AnyObject?=nil, delay: TimeInterval=0.0)
	{
		NSObject.cancelPreviousPerformRequests(withTarget:self, selector:selector, object:argument)
        #if swift(>=4.2)
        let modes = [RunLoop.Mode.common]
        #else
        let modes = [RunLoopMode.commonModes]
        #endif
		self.perform(selector, with:argument, afterDelay:delay, inModes:modes)
	}


	/// Cancel a specific outstanding perform request for the specified method and argument. Please note that the
	/// combination of selector and argument is important here. Using the same selector with a different argument
	/// will not cancel anything.
	///
	/// - parameter selector: The method to be canceled
	/// - parameter argument: The object argument to this method
	
	func cancelDelayedPerform(_ selector: Selector, argument: AnyObject?=nil)
	{
		NSObject.cancelPreviousPerformRequests(withTarget:self, selector:selector, object:argument)
	}


	/// Cancel all outstanding perform requests for the receiving object.
	
	func cancelAllDelayedPerforms()
	{
		NSObject.cancelPreviousPerformRequests(withTarget:self)
		RunLoop.current.cancelPerformSelectors(withTarget:self)
	}
}


//----------------------------------------------------------------------------------------------------------------------
