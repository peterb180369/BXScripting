//**********************************************************************************************************************
//
//  BXScriptCommand+while-endwhile.swift
//	Adds a while-loop command to BXScriptCommand
//  Copyright ©2023-2026 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation


//----------------------------------------------------------------------------------------------------------------------


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

public struct BXScriptCommand_while : BXScriptCommand, BXScriptCommandLabeled
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

public struct BXScriptCommand_endwhile : BXScriptCommand, BXScriptCommandLabeled
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


// MARK: - Builder


/// Creates a loop for the high-level script syntax.
///
///		While( !document.isSaved )
///		{
///			SpeakText("Please save the document.")
///			Wait(seconds:5)
///		}
///
/// The condition is stored in a closure and re-evaluated by the engine at the start of each iteration.

public func While(_ condition:@autoclosure @escaping ()->Bool, @BXScriptBuilder _ body:()->BXScriptCommands) -> BXScriptWhile
{
	BXScriptWhile(condition:condition, bodyCommands:body())
}


//----------------------------------------------------------------------------------------------------------------------


/// A While loop that is expanded to a while-endwhile command pair by the BXScriptBuilder

public struct BXScriptWhile : BXScriptFragment
{
	let condition:()->Bool
	let bodyCommands:BXScriptCommands


	public var scriptCommands:BXScriptCommands
	{
		let label = UUID().uuidString
		var scriptCommands:BXScriptCommands = []

		scriptCommands.append(.while(condition, label:label))
		scriptCommands += bodyCommands
		scriptCommands.append(.endwhile(label))

		return scriptCommands
	}
}


//----------------------------------------------------------------------------------------------------------------------
