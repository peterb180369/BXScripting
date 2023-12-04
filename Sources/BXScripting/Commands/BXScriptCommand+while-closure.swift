//**********************************************************************************************************************
//
//  BXScriptCommand+while-closure.swift
//	Adds a while-loop command to BXScriptCommand
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


extension BXScriptCommand where Self == BXScriptCommand_while_closure
{
	/// Creates a command that performs the supplied closure multiple times while a condition is true.
	
	public static func `while`(_ condition:@escaping ()->Bool, loopBody:@escaping ()->Void) -> BXScriptCommand
	{
		BXScriptCommand_while_closure(condition:condition, loopBody:loopBody)
	}

	/// Creates a command that performs a named closure multiple times while a condition is true.
	///
	/// The condition closure and the loopBody closures must be stored in the shared BXEnvironment under the specified names.
	
	public static func `while`(_ conditionName:String, loopBodyName:String) -> BXScriptCommand
	{
		let condition:()->Bool = BXScriptEnvironment.shared[conditionName] ?? { false }
		let loopBody:()->Void = BXScriptEnvironment.shared[loopBodyName] ?? { }
		return BXScriptCommand_while_closure(condition:condition, loopBody:loopBody)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command performs the supplied closure multiple times while a condition is true.

public struct BXScriptCommand_while_closure : BXScriptCommand
{
	var condition:()->Bool
	var loopBody:()->Void
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	public func execute()
	{
		self.queue.async
		{
			while condition()
			{
				loopBody()
			}
			
			completionHandler?()
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------
