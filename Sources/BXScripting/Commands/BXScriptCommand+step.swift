//**********************************************************************************************************************
//
//  BXScriptCommand+step.swift
//	Adds a step command to BXScriptCommand
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_step
{
	public static func step(_ name:String) -> BXScriptCommand
	{
		BXScriptCommand_step(label:name)
	}

	public static func step(_ name:any RawRepresentable<String>) -> BXScriptCommand
	{
		BXScriptCommand_step(label:name.rawValue)
	}
}


/// This command provides a named step that acts as a goto label for the controller buttons and also provides info for the progress bar.

public struct BXScriptCommand_step : BXScriptCommand, BXScriptCommandLabeled
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
