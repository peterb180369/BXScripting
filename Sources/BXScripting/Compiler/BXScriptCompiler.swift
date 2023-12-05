//**********************************************************************************************************************
//
//  BXScriptCompiler.swift
//	Compiles a text based script source code into a list of BXScriptCommands
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import BXSwiftUtils


//----------------------------------------------------------------------------------------------------------------------


public class BXScriptCompiler
{
	/// Possible errors for the BXScriptCompiler
	
	enum Error : Swift.Error
	{
		case parsingFailed(lineNumber:Int, text:String)
	}
	
	
//----------------------------------------------------------------------------------------------------------------------


	/// Registers a BXScriptCommandCompilable with the compiler.
	///
	/// Without any registered command the compiler does nothing, as it doesn't know anything about the script commands and the syntax.
	
	public static func register(_ commandType:BXScriptCommandCompilable.Type)
	{
		Self.registeredBuilders += commandType.commandBuilders
	}
	
	/// The list of registered command builders
	
	private static var registeredBuilders:[BXScriptCommandBuilder] = []


//----------------------------------------------------------------------------------------------------------------------


	/// Compiles a text based script source code into a list of BXScriptCommands.
	
	public static func compile(_ sourceCode:String) throws -> BXScriptCommands
	{
		var commands:BXScriptCommands = []
		
		// Split source into separate lines and remove unwanted whitespace chars at start and end of the line
		
		let lines = sourceCode
			.components(separatedBy:"\n")
			.map { $0.trimmingCharacters(in:.whitespacesAndNewlines) }
		
		// Go through all lines and convert them BXScriptCommands
		
		for (i,text) in lines.enumerated()
		{
			guard !text.hasPrefix("//") else { continue } // Ignore comment lines
			commands += try Self.buildCommand(lineNumber:i+1, text:text)
		}
		
		return commands
	}


	/// Builds a BXScriptCommand for a single line of text.
	///
	/// The first BXScriptCommandBuilder that successfully builds a BXScriptCommand wins.
	
	private static func buildCommand(lineNumber:Int, text:String) throws -> BXScriptCommand
	{
		for builder in registeredBuilders
		{
			if let command = builder(text)
			{
				return command
			}
		}
		
		throw Error.parsingFailed(lineNumber:lineNumber, text:text)
	}
}


//----------------------------------------------------------------------------------------------------------------------
