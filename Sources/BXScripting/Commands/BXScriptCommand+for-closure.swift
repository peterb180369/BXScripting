//**********************************************************************************************************************
//
//  BXScriptCommand+for-closure.swift
//	Adds a for-loop command to BXScriptCommand
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
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
