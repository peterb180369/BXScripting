//**********************************************************************************************************************
//
//  BXScriptCommand+run.swift
//	Adds a run-script command to BXScriptCommand
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_run
{
	/// Creates a command that runs the specified script as a subroutine.
	
	public static func run(_ scriptCommands:BXScriptCommands) -> BXScriptCommand
	{
		BXScriptCommand_run(scriptCommands:scriptCommands)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command runs the specified script as a subroutine.

public struct BXScriptCommand_run : BXScriptCommand, BXScriptCommandCancellable
{
	var scriptCommands:BXScriptCommands
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	public func execute()
	{
		guard let parentEngine = scriptEngine else { return }
		let parentEnvironment = parentEngine.environment
		let subEngine = BXScriptEngine(scriptCommands, environment:parentEnvironment, completionHandler:completionHandler)
		subEngine.run(on:queue)
	}
	
	public func cancel()
	{
		#warning("TODO: also cancel subEngine")
	}
}


//----------------------------------------------------------------------------------------------------------------------
