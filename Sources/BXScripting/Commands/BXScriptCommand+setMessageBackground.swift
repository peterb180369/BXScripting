//**********************************************************************************************************************
//
//  BXScriptCommand+setMessageBackground.swift
//	Sets or modifies the background layer for the currently visible message
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_displayMessage
{
	/// Creates a command that displays a text message in the specified window.

	public static func setMessageBackground(in window:@escaping @autoclosure ()->NSWindow?, padding:NSEdgeInsets? = NSEdgeInsets(top:12, left:60, bottom:12, right:60), cornerRadius:CGFloat = 12.0) -> BXScriptCommand
	{
		BXScriptCommand_setMessageBackground(window:window, backgroundPadding:padding, cornerRadius:cornerRadius)
	}
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: - Command


/// This command displays a text message at the bottom of a window.

public struct BXScriptCommand_setMessageBackground : BXScriptCommand
{
	var window:()->NSWindow?
	var backgroundPadding:NSEdgeInsets?
	var cornerRadius:CGFloat = 12.0
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	public func execute()
	{
		self.queue.async
		{
			DispatchQueue.main.asyncIfNeeded
			{
				self.updateLayers()
				self.completionHandler?()
			}
		}
	}
	
	
	private func updateLayers()
	{
		guard let window = self.window() else { return }
		guard let view = window.contentView else { return }
		guard let textLayer = view.sublayer(named:BXScriptCommand_displayMessage.textLayerName) as? CATextLayer else { return }

		let showsBackground = backgroundPadding != nil
		let padding = backgroundPadding ?? NSEdgeInsets()
	
		BXScriptCommand_displayMessage.updateBackgroundLayer(in:view, visible:showsBackground, padding:padding, cornerRadius:cornerRadius)
		BXScriptCommand_displayMessage.updateShadowLayer(in:view)
	}
}


//----------------------------------------------------------------------------------------------------------------------
