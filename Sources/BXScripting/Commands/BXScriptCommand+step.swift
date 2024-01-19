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
			BXScriptWindowController.shared?.currentStep = self // Store reference to the current step
			completionHandler?()
		}
	}

	// The Helper class is used to store a various indexes. The BXScriptCommand_step struct is immutable and cannot store anything by itself.
	
	class Helper
	{
		var globalStepIndex:Int = 0
		var localCommandIndex:Int = 0
	}
	
	let helper = Helper()
}
	

//----------------------------------------------------------------------------------------------------------------------
