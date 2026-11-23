//**********************************************************************************************************************
//
//  BXScriptCommand+run.swift
//	Adds a run-script command to BXScriptCommand
//  Copyright ©2023-2026 Peter Baumgartner. All rights reserved.
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
	
	// Execute
	
	public func execute()
	{
		guard let parentEngine = scriptEngine else { return }
		let parentEnvironment = parentEngine.environment

		let subEngine = BXScriptEngine(scriptCommands, environment:parentEnvironment, completionHandler:
		{
			BXScriptWindowController.shared?.currentEngine = scriptEngine
			completionHandler?()
		})
		
		BXScriptWindowController.shared?.currentEngine = subEngine
		helper.subEngine = subEngine
		subEngine.run(on:queue)
	}
	
	// Cancel
	
	public func cancel()
	{
		helper.subEngine?.cancel()
	}

	// The Helper class is used to store a reference to the subEngine. The BXScriptCommand_run struct is immutable and cannot store anything by itself.
	
	class Helper
	{
		var subEngine:BXScriptEngine? = nil
	}
	
	private let helper = Helper()
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: - Builder


// The following functions provide the high-level syntax for the commands above. They simply forward to the low-level
// factory functions. Capitalized function names are necessary, because a command cannot be written with leading dot
// syntax as a statement inside a @BXScriptBuilder body - the compiler would parse consecutive lines that start with
// a dot as a single method chain.


public func Run(_ scriptCommands:BXScriptCommands) -> BXScriptCommand
{
	.run(scriptCommands)
}


/// Creates a command that runs the specified script as a subroutine.
///
/// Please note that a script fragment can also be used as a statement inside a @BXScriptBuilder body directly, in
/// which case its commands are inlined into the enclosing script. Use Run() if the fragment should really be run
/// by a separate sub-engine, e.g. because it is a whole chapter of a tutorial.

public func Run(@BXScriptBuilder _ body:()->BXScriptCommands) -> BXScriptCommand
{
	.run(body())
}


//----------------------------------------------------------------------------------------------------------------------
