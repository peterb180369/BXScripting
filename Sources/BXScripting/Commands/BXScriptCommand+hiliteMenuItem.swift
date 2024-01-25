//**********************************************************************************************************************
//
//  BXScriptCommand+hiliteMenuItem.swift
//	Adds a hiliteMenuItem command to BXScriptCommand
//  Copyright ©2024 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit
import SwiftUI
import Accessibility


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_hiliteMenuItem
{
	/// Creates a command that shows or hides a highlight on the view with the specified identifier. You can also supply an optional view label.

	public static func hiliteMenuItem(withID itemID:String, menuID:String, cornerRadius:CGFloat = 4.0) -> BXScriptCommand
	{
		BXScriptCommand_hiliteMenuItem(itemID:itemID, menuID:menuID, cornerRadius:cornerRadius)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command shows or hides a highlight on the view with the specified identifier. You can also supply an optional view label.

public struct BXScriptCommand_hiliteMenuItem : BXScriptCommand, BXScriptCommandCancellable
{
	/// The id of the NSMenuItem to be highlighted
	///
	/// Must be set on Identity and Accessibility Identity in IB
	
	var itemID:String
	
	/// The id of the parent NSMenu
	///
	/// Must be set on Identity and Accessibility Identity in IB
	
	var menuID:String
	
	/// The corner radius of the highlight frame
	
	var cornerRadius:CGFloat = 4.0
	
	/// This helper is needed to open a window and draw the hilite frame

	fileprivate static let helper = WindowHelper()
	
	// Script engine stuff
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	// Execute the command
	
	public func execute()
	{
		self.queue.async
		{
			defer { self.completionHandler?() }

			guard let environment = scriptEngine?.environment else { return }
			guard let mainMenu = NSMenu.main else { return }
			guard let item = mainMenu.menuItems(forIdentifier:itemID).first else { return }
			guard let menu = item.menu  else { return }

			// Configure the helper
			
			Self.helper.itemID = self.itemID
			Self.helper.strokeColor = environment.value(forKey:.hiliteStrokeColorKey) ?? .yellow
			Self.helper.strokeWidth = 4.0
			Self.helper.cornerRadius = self.cornerRadius
			
//			Self.helper.postMouseEvent(position:menuTitleFrame.center, type:.leftMouseDown)
//			Self.helper.postMouseEvent(position:menuTitleFrame.center, type:.leftMouseUp)
			
			// IMPORTANT: since the NSMenu.popup(…) function starts a local runloop in eventTracking mode,
			// this function doesn't return until the user makes a mouse click. For this reason we need
			// to schedule the execution of window creation and drawing of the hilite frame BEFORE
			// the menu is being shown! Scheduling with .eventTracking mode is essential here!
			
			Self.helper.perform(
				#selector(WindowHelper.createWindow),
				with:nil,
				afterDelay:0.2,
				inModes: [.eventTracking,.modalPanel,.common,.default])
			
			// Popup the menu. This will BLOCK the entire main thread until the user makes a mouse click!
			
//			AXUIElementPerformAction(menuTitleElement, kAXPickAction as CFString)
			menu.popUp(positioning:nil, at:menuTitleFrame.bottomLeft, in:nil)
			
			// The previous function has returned. Remove the window containing the hilite frame.
			
			self.cleanup()
		}
	}

	public func cancel()
	{
		self.cleanup()
	}

	private func cleanup()
	{
		Self.helper.closeWindow()
	}

	var menuTitleFrame:CGRect
	{
		Self.menuItemFrame(withIdentifier:menuID)
	}


	public static func menuItemFrame(withIdentifier itemID:String) -> CGRect
	{
		guard let element = BXAccessibilityHelper.findElement(withIdentifier:itemID) else { return .zero }
		guard let frame = BXAccessibilityHelper.getFrame(of:element) else { return .zero }
		return frame.insetBy(dx:-3, dy:-5)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This helper class is needed to create and draw the hilite frame in a transparent window.
///
/// Must be an NSObject, so that we can perform methods in obscure runloop modes.

fileprivate class WindowHelper : NSObject
{
	var window:NSWindow? = nil
	var itemID:String = ""
	var itemElement:AXUIElement? = nil
	var strokeColor:Color = .yellow
	var strokeWidth:CGFloat = 4.0
	var cornerRadius:CGFloat = 0.0
	
	/// Creates and configures a transparent window that contains a view that draws the hilite frame
	
	@objc func createWindow() -> NSWindow?
	{
//		guard let itemElement = itemElement else { return nil }
//		AXUIElementPerformAction(itemElement, kAXPickAction as CFString)
//		return nil
		
		let frame = menuItemFrame

		if self.window == nil
		{
			let stroke = RoundedRectangle(cornerRadius:cornerRadius)
				.stroke(strokeColor, lineWidth:strokeWidth)
				.padding(2)
			
			let window = NSPanel(contentRect:frame, styleMask:[.borderless,.fullSizeContentView,.utilityWindow,.nonactivatingPanel], backing:.buffered, defer:false)

			window.contentView = NSHostingView(rootView:stroke)
			window.collectionBehavior = .fullScreenAuxiliary		// make sure that StageManager doesn't push out other windows
			window.level = .screenSaver								// draw above menus
			window.backgroundColor = NSColor.clear					// transparent
			window.hasShadow = false								// no shadow
			window.isMovableByWindowBackground = false
			window.isReleasedWhenClosed = false
			window.isExcludedFromWindowsMenu = true

			self.window = window
		}
		
		self.window?.orderFront(nil)
		self.window?.setFrame(frame, display:true)

		return window
	}
	
	/// Closes the window
	
	@objc func closeWindow()
	{
		self.window?.close()
		self.window = nil
	}

	/// Calculates the frame of the menu item in screen coordinates
	
	var menuItemFrame:CGRect
	{
		BXScriptCommand_hiliteMenuItem.menuItemFrame(withIdentifier:itemID)
	}


	func postMouseEvent(position:CGPoint, type:NSEvent.EventType = .leftMouseDown)
	{
		let window = NSApplication.shared.windows.last
		let windowNumber = window?.windowNumber ?? 0
		let p = window?.convertPoint(fromScreen:position) ?? .zero
		
		let event = NSEvent.mouseEvent(
			with: .leftMouseDown, // Specify the type of mouse event
			location: p, // Specify the location
			modifierFlags: [], // Specify any modifier flags if needed
			timestamp: CFAbsoluteTimeGetCurrent(),
			windowNumber:windowNumber,
			context:nil,
			eventNumber:0,
			clickCount:1,
			pressure:1.0)
			
		if let event = event
		{
			NSApplication.shared.postEvent(event, atStart:true)
		}
	}
}
	
	
//----------------------------------------------------------------------------------------------------------------------
