//**********************************************************************************************************************
//
//  BXCompilableScriptCommand.swift
//	Defines the requiresments for a single command in a script
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


/// The BXCompilableScriptCommand protocol can be implemented by BXScriptCommand implementations. That way it can add compiler support.

public protocol BXCompilableScriptCommand
{
	/// Returns a list of one or more BXScriptCommandBuilders.

	static var commandBuilders:[BXScriptCommandBuilder] { get }
}


//----------------------------------------------------------------------------------------------------------------------


/// A BXScriptCommandBuilder if a function that takes a single line of text, parses it and tries to build a BXScriptCommand struct

public typealias BXScriptCommandBuilder = (String)->BXScriptCommand?


//----------------------------------------------------------------------------------------------------------------------
