//**********************************************************************************************************************
//
//  BXScriptCommand+log.swift
//	Adds a log command to BXScriptCommand
//  Copyright ©2023-2026 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation


//----------------------------------------------------------------------------------------------------------------------


/// This command logs a message to the console.

public struct BXScriptCommand_log : BXScriptCommand
{
	public var message:String
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	public func execute()
	{
		self.queue.async
		{
			NSLog(message)
			completionHandler?()
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_log
{
	/// Creates a command that logs a message to the console.
	
	public static func log(_ message:String) -> BXScriptCommand
	{
		BXScriptCommand_log(message:message)
	}
}


//----------------------------------------------------------------------------------------------------------------------
	

// Add compiler support for BXScriptCommand_log

extension BXScriptCommand_log : BXScriptCommandCompilable
{
	public static var commandBuilders:[BXScriptCommandBuilder]
	{
		return [logCommandBuilder]
	}
	
	// This is a really naive implementation. In reality we should use a regex to parse the command and all arguments.
	
	public static func logCommandBuilder(line:String) -> BXScriptCommand_log?
	{
		if line.hasPrefix("log ")
		{
			let argument1 = String(line.dropFirst(4))
			return BXScriptCommand_log(message:argument1)
		}
		
		return nil
	}
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: - Builder


// The following functions provide the high-level syntax for the commands above. They simply forward to the low-level
// factory functions. Capitalized function names are necessary, because a command cannot be written with leading dot
// syntax as a statement inside a @BXScriptBuilder body - the compiler would parse consecutive lines that start with
// a dot as a single method chain.


public func Log(_ message:String) -> BXScriptCommand
{
	.log(message)
}


//----------------------------------------------------------------------------------------------------------------------
