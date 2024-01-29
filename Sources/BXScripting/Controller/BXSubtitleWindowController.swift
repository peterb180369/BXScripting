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
		let size = hostview.intrinsicContentSize

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
				self.showSubtitle(text)
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
		guard let hostview = window.contentView as? NSHostingView<BXSubtitleView> else { return }
		
		// Get the main screen safe area (with inset)
		
		let safeArea = screen.visibleFrame.insetBy(dx:50, dy:50)
		
		// Set window to safe area and measure text size
		
		window.setFrame(safeArea, display:false)
		let size = hostview.intrinsicContentSize
		
		// Resize the window to text size
		
		var frame = safeArea
		frame.origin.x = safeArea.midX - round (0.5 * size.width)
		frame.size.height = size.height
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
