//**********************************************************************************************************************
//
//  BXScriptCommand+if-closure.swift
//	Adds a if-then-else command to BXScriptCommand
//  Copyright ©2023-2026 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_if_closure
{
	/// Creates a command that checks a condition and calls one of two supplied closure depending on the condition.
	
	public static func `if`(_ condition:@escaping ()->Bool, then thenAction:@escaping ()->Void, else elseAction:@escaping ()->Void) -> BXScriptCommand
	{
		BXScriptCommand_if_closure(condition:condition, thenAction:thenAction, elseAction:elseAction)
	}

	/// Creates a command that checks a condition and calls one of two closure depending on the condition.
	///
	/// The condition closure and the action closures must be stored in the shared BXEnvironment under the specified names.
	
	public static func `if`(_ conditionName:String, then thenActionName:String, else elseActionName:String) -> BXScriptCommand
	{
		let condition:()->Bool = BXScriptEnvironment.shared[conditionName] ?? { false }
		let thenAction:()->Void = BXScriptEnvironment.shared[thenActionName] ?? { }
		let elseAction:()->Void = BXScriptEnvironment.shared[elseActionName] ?? { }
		return BXScriptCommand_if_closure(condition:condition, thenAction:thenAction, elseAction:elseAction)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command checks a condition and calls one of two supplied closure depending on the condition.

public struct BXScriptCommand_if_closure : BXScriptCommand
{
	var condition:()->Bool
	var thenAction:()->Void
	var elseAction:()->Void
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	public func execute()
	{
		self.queue.async
		{
			if condition()
			{
				thenAction()
			}
			else
			{
				elseAction()
			}
			
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


public func If(_ condition:@escaping ()->Bool, then thenAction:@escaping ()->Void, else elseAction:@escaping ()->Void) -> BXScriptCommand
{
	.if(condition, then:thenAction, else:elseAction)
}


public func If(_ conditionName:String, then thenActionName:String, else elseActionName:String) -> BXScriptCommand
{
	.if(conditionName, then:thenActionName, else:elseActionName)
}


//----------------------------------------------------------------------------------------------------------------------
