//**********************************************************************************************************************
//
//  BXScriptCommandCompilable.swift
//	Defines the requirements for a compilable command
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


/// The BXScriptCommandCompilable protocol can be implemented by BXScriptCommand implementations. That way it can add compiler support.

public protocol BXScriptCommandCompilable
{
	/// Returns a list of one or more BXScriptCommandBuilders.

	static var commandBuilders:[BXScriptCommandBuilder] { get }
}


//----------------------------------------------------------------------------------------------------------------------


/// A BXScriptCommandBuilder if a function that takes a single line of text, parses it and tries to build a BXScriptCommand struct

public typealias BXScriptCommandBuilder = (String)->BXScriptCommand?


//----------------------------------------------------------------------------------------------------------------------
