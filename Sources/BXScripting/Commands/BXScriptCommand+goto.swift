//**********************************************************************************************************************
//
//  BXScriptCommand+goto.swift
//	Adds a goto command to BXScriptCommand
//  Copyright ©2023-2026 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_goto
{
	/// Creates a command that sets the commandIndex of the script to the specified label.
	
	public static func goto(_ label:String) -> BXScriptCommand
	{
		BXScriptCommand_goto(label:label)
	}
	
	/// Creates a command that sets the commandIndex of the script to the specified label.
	
	public static func goto(_ label:any RawRepresentable<String>) -> BXScriptCommand
	{
		BXScriptCommand_goto(label:label.rawValue)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command sets the commandIndex of the script to the specified index.

public struct BXScriptCommand_goto : BXScriptCommand, BXScriptCommandLabeled
{
	public var label:String
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	public func execute()
	{
		self.queue.async
		{
			if let index = self.index(for:label, type:BXScriptCommand_label.self)
			{
				scriptEngine?.commandIndex = index
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


public func Goto(_ label:String) -> BXScriptCommand
{
	.goto(label)
}


public func Goto(_ label:any RawRepresentable<String>) -> BXScriptCommand
{
	.goto(label)
}


//----------------------------------------------------------------------------------------------------------------------
