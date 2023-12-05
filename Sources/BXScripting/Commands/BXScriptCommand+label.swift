//**********************************************************************************************************************
//
//  BXScriptCommand+label.swift
//	Adds a label command to BXScriptCommand
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
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
