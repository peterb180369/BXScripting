//**********************************************************************************************************************
//
//	BXScriptLabelValidation.swift
//	Checks that the jump targets in a script are unambiguous
//	Copyright ©2026 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommands
{
	/// The command types that are used as jump targets, i.e. the types that BXScriptCommandLabeled.index(for:type:)
	/// is called with.
	///
	/// Commands that merely reference a label - if, while and goto - are not listed here, because referencing the
	/// same label more than once is perfectly legal. Steps are not listed either, as their label is just a display
	/// name for the controller window.

	private static var jumpTargetTypes:[any BXScriptCommandLabeled.Type]
	{
		[
			BXScriptCommand_then.self,
			BXScriptCommand_else.self,
			BXScriptCommand_endif.self,
			BXScriptCommand_label.self,
			BXScriptCommand_while.self,
			BXScriptCommand_endwhile.self,
			BXScriptCommand_for.self,
			BXScriptCommand_endfor.self,
		]
	}


	/// Logs a warning for every jump target that exists more than once in this script.
	///
	/// A duplicate target is almost always a bug, because index(for:type:) returns the FIRST match, so execution
	/// jumps to the wrong location. Scripts that are built with the BXScriptBuilder use generated UUID labels and
	/// are thus safe by construction - unless an already expanded fragment is stored in a constant and then inlined
	/// into the same script twice. Scripts with hand-written labels can of course have typos or copy/paste mistakes.

	func validateJumpTargets()
	{
		var counts:[String:Int] = [:]

		for command in self
		{
			guard let labeled = command as? (any BXScriptCommandLabeled) else { continue }
			let commandType = type(of:command)
			guard Self.jumpTargetTypes.contains(where: { $0 == commandType }) else { continue }

			let key = "\(commandType) \(labeled.label)"
			counts[key] = (counts[key] ?? 0) + 1
		}

		for (key,count) in counts where count > 1
		{
			let message = "BXScripting: The jump target \(key) exists \(count) times in this script, so jumps to it will go to the first one."
			NSLog("%@", message)
			assertionFailure(message)
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------
