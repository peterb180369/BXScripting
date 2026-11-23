//**********************************************************************************************************************
//
//  BXScriptCommand+for-closure.swift
//	Adds a for-loop command to BXScriptCommand
//  Copyright ©2023-2026 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_for_closure
{
	/// Creates a command that performs the supplied closure in a loop with a specified range.
	
	public static func `for`(_ range:ClosedRange<Int>, loopBody:@escaping (Int)->Void) -> BXScriptCommand
	{
		BXScriptCommand_for_closure(range:range, loopBody:loopBody)
	}
}


//----------------------------------------------------------------------------------------------------------------------


public struct BXScriptCommand_for_closure : BXScriptCommand
{
	var range:ClosedRange<Int>
	var loopBody:(Int)->Void
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	public func execute()
	{
		self.queue.async
		{
			for i in range
			{
				loopBody(i)
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


public func For(_ range:ClosedRange<Int>, loopBody:@escaping (Int)->Void) -> BXScriptCommand
{
	.for(range, loopBody:loopBody)
}


//----------------------------------------------------------------------------------------------------------------------
