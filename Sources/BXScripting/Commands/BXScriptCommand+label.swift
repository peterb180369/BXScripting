//**********************************************************************************************************************
//
//  BXScriptCommand+label.swift
//	Adds a label command to BXScriptCommand
//  Copyright ©2023-2026 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_label
{
	/// Creates a command that provides a named label in the script that can be used by goto command.
	
	public static func label(_ label:String) -> BXScriptCommand
	{
		BXScriptCommand_label(label:label)
	}
	
	/// Creates a command that provides a named label in the script that can be used by goto command.
	
	public static func label(_ label:any RawRepresentable<String>) -> BXScriptCommand
	{
		BXScriptCommand_label(label:label.rawValue)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command provides a named label in the script that can be used by goto command.

public struct BXScriptCommand_label : BXScriptCommand, BXScriptCommandLabeled
{
	public var label:String
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	public func execute()
	{
		self.queue.async
		{
			completionHandler?() // Nothing to be done here, immediately call completionHandler
		}
	}
}
	

//----------------------------------------------------------------------------------------------------------------------


// MARK: - Builder


// The following functions provide the high-level syntax for the commands above. They simply forward to the low-level
// factory functions. Capitalized function names are necessary, because a command cannot be written with leading dot
// syntax as a statement inside a @BXScriptBuilder body - the compiler would parse consecutive lines that start with
// a dot as a single method chain.


public func Label(_ label:String) -> BXScriptCommand
{
	.label(label)
}


public func Label(_ label:any RawRepresentable<String>) -> BXScriptCommand
{
	.label(label)
}


//----------------------------------------------------------------------------------------------------------------------
