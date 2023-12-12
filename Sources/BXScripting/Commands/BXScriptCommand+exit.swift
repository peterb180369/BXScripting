//**********************************************************************************************************************
//
//  BXScriptCommand+exit.swift
//	Adds a exit command to BXScriptCommand
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_exit
{
	public static func exit() -> BXScriptCommand
	{
		BXScriptCommand_exit()
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command stops script execution.

public struct BXScriptCommand_exit : BXScriptCommand
{
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil

	public func execute()
	{
		self.queue.async
		{
			if let controller = BXScriptWindowController.shared
			{
				controller.abort()
			}
			else
			{
				self.scriptEngine?.cancel()
			}
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------
