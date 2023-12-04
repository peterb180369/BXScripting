//**********************************************************************************************************************
//
//  BXScriptCommand+goto.swift
//	Adds a goto command to BXScriptCommand
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
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

public struct BXScriptCommand_goto : BXScriptCommand, BXLabeledScriptCommand
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
