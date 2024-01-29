//**********************************************************************************************************************
//
//  BXScriptCommand+displayMessageWindow.swift
//	Adds a displayMessage command to BXScriptCommand
//  Copyright ©2023-2024 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_moveMessageWindow
{
	/// Creates a command that moves an existing standalone message window to the specified position on screen.

	public static func moveMessageWindow(to position:@escaping @autoclosure ()->CGPoint, anchor:MessageLayerAnchor = .center, animated:Bool = false) -> BXScriptCommand
	{
		BXScriptCommand_moveMessageWindow(position:position, anchor:anchor, animated:animated)
	}
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: -

/// This command displays a text message at the bottom of a window.

public struct BXScriptCommand_moveMessageWindow : BXScriptCommand, BXScriptCommandCancellable
{
	// Layout
	
	var position:()->CGPoint
	var anchor:MessageLayerAnchor = .center
	var animated:Bool = false
	
	// Execution support
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	// Execute
	
	public func execute()
	{
		self.queue.async
		{
			DispatchQueue.main.asyncIfNeeded
			{
				if let window = BXScriptCommand_displayMessageWindow.standaloneWindow
				{
					Self.moveWindow(window, to:position(), anchor:anchor, animated:animated)
				}
				
				self.completionHandler?()
			}
		}
	}
	
	
	public func cancel()
	{

	}
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: - Window

extension BXScriptCommand_moveMessageWindow
{
	static func moveWindow(_ window:NSWindow, to position:CGPoint, anchor:MessageLayerAnchor, animated:Bool)
	{
		// Get the current size of the message window. Please note that this includes the background,
		// i.e.the padding around the text.
		
		let size = window.frame.size
		
		// Since the size already includes that background padding, we will supply 0 values for the padding
		// to calculate the new center position.
		
		var center = BXScriptCommand_displayMessage.adjustPosition(
			position,
			anchor: anchor,
			textSize:size,
			t:0,
			l:0,
			b:0,
			r:0)

		// Calculate the frame and move the window
		
		let frame = CGRect(center:center, size:size)
		window.setFrame(frame, display:true, animate:animated)
	}
}


//----------------------------------------------------------------------------------------------------------------------
