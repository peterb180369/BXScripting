//**********************************************************************************************************************
//
//  BXSwiftScriptStep+action.swift
//	Adds an action command to BXScriptCommand
//  Copyright ©2023-2026 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_action
{
	/// Creates a command that executes a single action closure.
	
	public static func action(_ action:@escaping ()->Void) -> BXScriptCommand
	{
		BXScriptCommand_action(action:action)
	}

	/// Creates a command that executes a single named action closure that is stored in the shared BXScriptEnvironment
	
	public static func action(_ actionName:String) -> BXScriptCommand
	{
		let action:()->Void = BXScriptEnvironment.shared[actionName] ?? {}
		return BXScriptCommand_action(action:action)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command executes a single action closure.

public struct BXScriptCommand_action : BXScriptCommand
{
	public var action:()->Void
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	public func execute()
	{
		self.queue.async
		{
			action()
			completionHandler?()
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: - Builder


// The following functions provide the high-level syntax for the commands above. They simply forward to the low-level
// factory functions. Capitalized function names are necessary, because a command cannot be written with leading dot
// syntax as a statement inside a @BXScriptBuilder body - the compiler would parse consecutive lines that start with
// a dot as a single method chain.


public func Action(_ action:@escaping ()->Void) -> BXScriptCommand
{
	.action(action)
}


public func Action(_ actionName:String) -> BXScriptCommand
{
	.action(actionName)
}


//----------------------------------------------------------------------------------------------------------------------
