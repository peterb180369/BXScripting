//**********************************************************************************************************************
//
//  BXScriptCommand+exit.swift
//	Adds a exit command to BXScriptCommand
//  Copyright ©2023-2026 Peter Baumgartner. All rights reserved.
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


// MARK: - Builder


// The following functions provide the high-level syntax for the commands above. They simply forward to the low-level
// factory functions. Capitalized function names are necessary, because a command cannot be written with leading dot
// syntax as a statement inside a @BXScriptBuilder body - the compiler would parse consecutive lines that start with
// a dot as a single method chain.


public func Exit() -> BXScriptCommand
{
	.exit()
}


//----------------------------------------------------------------------------------------------------------------------
