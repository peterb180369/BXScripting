//**********************************************************************************************************************
//
//	BXScriptFragment.swift
//	A fragment contributes commands to a script that is being built with a @BXScriptBuilder
//	Copyright ©2026 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation


//----------------------------------------------------------------------------------------------------------------------


/// A BXScriptFragment contributes zero or more commands to a script.
///
/// Control flow blocks like While or For adopt this protocol, because they expand to several low-level commands.
/// Adopting this protocol is all that is needed to make a type usable as a statement inside a @BXScriptBuilder body.

public protocol BXScriptFragment
{
	var scriptCommands:BXScriptCommands { get }
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: - Grouping


/// Groups several statements into a single fragment.
///
/// This is useful for reusable script snippets that are built with the high-level syntax, but need to be stored
/// in a property or returned from a function:
///
///		static var feedbackOK:BXScriptFragment
///		{
///			Commands
///			{
///				PlayAudio("Success", volume:0.33)
///				Wait(seconds:0.66)
///			}
///		}

public struct Commands : BXScriptFragment
{
	public var scriptCommands:BXScriptCommands


	public init(@BXScriptBuilder _ body:()->BXScriptCommands)
	{
		self.scriptCommands = body()
	}


	public init(_ scriptCommands:BXScriptCommands)
	{
		self.scriptCommands = scriptCommands
	}
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: - Escape hatches


/// Wraps a low-level BXScriptCommand, so that it can be used as a statement inside a @BXScriptBuilder body.
///
/// A command cannot be written with leading dot syntax inside a builder body, because the Swift compiler would
/// parse consecutive lines that start with a dot as a single method chain. Commands that do not have a high-level
/// wrapper function yet can therefore be used like this:
///
///		Cmd(.displayLottie(animation, size:size, in:view, at:position))

public func Cmd(_ command:any BXScriptCommand) -> BXScriptCommand
{
	command
}


/// Wraps a list of low-level BXScriptCommands, so that it can be used as a statement inside a @BXScriptBuilder body.
///
/// Please note that a plain BXScriptCommands array can also be used as a statement directly. This function merely
/// exists for symmetry with Cmd() and for cases where the compiler needs a little help.

public func Cmds(_ scriptCommands:BXScriptCommands) -> BXScriptCommands
{
	scriptCommands
}


//----------------------------------------------------------------------------------------------------------------------
