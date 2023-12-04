//**********************************************************************************************************************
//
//  BXScriptCommand+while-endwhile.swift
//	Adds a while-loop command to BXScriptCommand
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


extension BXScriptCommand where Self == BXScriptCommand_while
{
	public static func `while`(_ condition:@escaping ()->Bool, label:String) -> BXScriptCommand
	{
		BXScriptCommand_while(condition:condition, label:label)
	}

	public static func `while`(_ conditionName:String, label:String) -> BXScriptCommand
	{
		let condition:()->Bool = BXScriptEnvironment.shared[conditionName] ?? { false }
		return BXScriptCommand_while(condition:condition, label:label)
	}
}


extension BXScriptCommand where Self == BXScriptCommand_endwhile
{
	public static func endwhile(_ label:String) -> BXScriptCommand
	{
		BXScriptCommand_endwhile(label:label)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command checks a condition and jumps to the first command after endwhile if the condition is false.

public struct BXScriptCommand_while : BXScriptCommand, BXLabeledScriptCommand
{
	var condition:()->Bool
	public var label:String
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	public func execute()
	{
		self.queue.async
		{
			if !condition()
			{
				if let endwhileIndex = self.index(for:label, type:BXScriptCommand_endwhile.self)
				{
					scriptEngine?.commandIndex = endwhileIndex + 1 // Jump to first command AFTER endwhile
				}
			}
			
			completionHandler?()
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command jumps to the start of the while loop, where the condition will be evaluated again.

public struct BXScriptCommand_endwhile : BXScriptCommand, BXLabeledScriptCommand
{
	public var label:String
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	public func execute()
	{
		self.queue.async
		{
			if let whileIndex = self.index(for:label, type:BXScriptCommand_while.self)
			{
				scriptEngine?.commandIndex = whileIndex // Jump to start of while-loop, condition will be re-evaluated there
			}
			
			completionHandler?()
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------
