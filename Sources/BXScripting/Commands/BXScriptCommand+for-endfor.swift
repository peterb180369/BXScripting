//**********************************************************************************************************************
//
//  BXScriptCommand+for-endfor.swift
//	Adds a for-endfor command to BXScriptCommand
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


extension BXScriptCommand where Self == BXScriptCommand_while
{
	public static func `for`(_ range:ClosedRange<Int>, label:String) -> BXScriptCommand
	{
		BXScriptCommand_for(range:range, label:label)
	}
}

extension BXScriptCommand where Self == BXScriptCommand_endfor
{
	public static func endfor(_ label:String) -> BXScriptCommand
	{
		BXScriptCommand_endfor(label:label)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command checks a condition and jumps to the first command after endwhile if the condition is false.

public struct BXScriptCommand_for : BXScriptCommand, BXLabeledScriptCommand
{
	var range:ClosedRange<Int>
	public var label:String
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	public func execute()
	{
		self.queue.async
		{
			// If we already have an i value in the environment, then increment it.
			// Once we go beyond end of range, exit the loop.
			
			if let i:Int = scriptEngine?.environment[label]
			{
				scriptEngine?.environment[label] = i + 1
				
				if i > range.upperBound, let endforIndex = self.index(for:label, type:BXScriptCommand_endfor.self)
				{
					scriptEngine?.commandIndex = endforIndex + 1 // Jump to first command AFTER endfor
				}
			}
			
			// During the first iteration we do not have an i value in the environment yet,
			// so set it to the start value
			
			else
			{
				scriptEngine?.environment[label] = range.lowerBound
			}

			completionHandler?()
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command jumps to the start of the for loop, where the condition will be evaluated again.

public struct BXScriptCommand_endfor : BXScriptCommand, BXLabeledScriptCommand
{
	public var label:String
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	public func execute()
	{
		self.queue.async
		{
			if let forIndex = self.index(for:label, type:BXScriptCommand_for.self)
			{
				scriptEngine?.commandIndex = forIndex // Jump to start of for-loop
			}
			
			completionHandler?()
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------
