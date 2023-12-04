//**********************************************************************************************************************
//
//  BXScriptCommand+extendMessage.swift
//	Adds a display-message command to BXScriptCommand
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit
import BXSwiftUtils


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_displayMessage
{
	public static func extendMessage(_ string:String, in window:NSWindow?, position:BXScriptCommand_extendMessage.Position = .before) -> BXScriptCommand
	{
		BXScriptCommand_extendMessage(string:string, window:window, position:position)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command displays a text message at the bottom of a window.

public struct BXScriptCommand_extendMessage : BXScriptCommand
{
	var string:String = ""
	var window:NSWindow? = nil
	var position:Position = .before
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil

	public enum Position
	{
		case before
		case after
	}
	
	public func execute()
	{
		guard let view = window?.contentView else { return }
		guard let textLayer = view.sublayer(named:"BXScriptCommand_displayMessage.textLayer") as? CATextLayer  else { return }
		var message = textLayer.string as? String ?? ""

		self.queue.async
		{
			DispatchQueue.main.asyncIfNeeded
			{
				if position == .before
				{
					message = string + message
				}
				else
				{
					message = message + string
				}
				
				textLayer.string = message
				self.completionHandler?()
			}
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------
