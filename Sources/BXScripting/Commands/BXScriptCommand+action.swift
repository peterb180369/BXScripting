//**********************************************************************************************************************
//
//  BXSwiftScriptStep+action.swift
//	Adds an action command to BXScriptCommand
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
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
