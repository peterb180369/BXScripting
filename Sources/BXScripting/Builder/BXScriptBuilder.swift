//**********************************************************************************************************************
//
//	BXScriptBuilder.swift
//	A function builder that provides a high-level SwiftUI like syntax for building scripts
//	Copyright ©2026 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation


//----------------------------------------------------------------------------------------------------------------------


/// BXScriptBuilder provides a high-level syntax for building a script, as an alternative to writing an array of
/// low-level BXScriptCommand structs by hand.
///
///		@BXScriptBuilder var chapter:BXScriptCommands
///		{
///			Step("Image Browser")
///
///			If( document?.selectedSidebarTab != .images )
///			{
///				HiliteView(withID:"images-button", in:documentWindow)
///				SpeakText("Click on this button to switch to the Image Browser.", wait:false)
///				WaitUntil { document?.selectedSidebarTab == .images }
///				UnhiliteView()
///			}
///			Else
///			{
///				SpeakText("The Image Browser is already visible.")
///			}
///
///			Run(nextChapter)
///		}
///
/// The result is an ordinary BXScriptCommands array, so the engine, the controller and the existing low-level syntax
/// are unaffected. Each statement is either a command (via one of the high-level wrapper functions, or via Cmd()),
/// a BXScriptCommands array, or a BXScriptFragment like If, While, For or Commands.
///
/// IMPORTANT: Conditions must be expressed with If/ElseIf/Else and not with a native Swift "if" statement. A script
/// is built long before it is executed - the whole chapter tree of a tutorial is usually built within a millisecond
/// after the user starts it, while execution takes many minutes. A native "if" would thus be evaluated at build time,
/// freezing the decision before the user even gets there, whereas If() stores the condition in a closure that the
/// engine evaluates when it reaches that point in the script. For this reason buildOptional() and buildEither() are
/// declared unavailable below, which turns a native "if" inside a builder body into a compile time error.
///
/// A native "for" loop on the other hand is allowed, because generating a known number of commands at build time is
/// a legitimate (and sometimes useful) thing to do. Use For() if the loop needs to be evaluated at execution time.

@resultBuilder public struct BXScriptBuilder
{
	// MARK: - Expressions


	public static func buildExpression(_ command:any BXScriptCommand) -> [BXScriptPart]
	{
		[.commands([command])]
	}

	public static func buildExpression(_ scriptCommands:BXScriptCommands) -> [BXScriptPart]
	{
		[.commands(scriptCommands)]
	}

	public static func buildExpression(_ fragment:any BXScriptFragment) -> [BXScriptPart]
	{
		[.commands(fragment.scriptCommands)]
	}

	public static func buildExpression(_ ifBlock:BXScriptIf) -> [BXScriptPart]
	{
		[.ifBlock(ifBlock)]
	}

	public static func buildExpression(_ elseIfBlock:BXScriptElseIf) -> [BXScriptPart]
	{
		[.elseIfBlock(elseIfBlock)]
	}

	public static func buildExpression(_ elseBlock:BXScriptElse) -> [BXScriptPart]
	{
		[.elseBlock(elseBlock)]
	}


	// MARK: - Blocks


	public static func buildBlock(_ parts:[BXScriptPart]...) -> [BXScriptPart]
	{
		parts.flatMap { $0 }
	}

	public static func buildArray(_ parts:[[BXScriptPart]]) -> [BXScriptPart]
	{
		parts.flatMap { $0 }
	}

	public static func buildLimitedAvailability(_ parts:[BXScriptPart]) -> [BXScriptPart]
	{
		parts
	}

	public static func buildFinalResult(_ parts:[BXScriptPart]) -> BXScriptCommands
	{
		Self.scriptCommands(for:parts)
	}


	// MARK: - Unavailable


	// These two functions would add support for native Swift "if" statements. They are intentionally unavailable,
	// because a native "if" would be evaluated while the script is being built and not while it is running. Please
	// see the discussion above.

	@available(*, unavailable, message:"Use If(condition) { } Else { } instead of a native Swift if statement, so that the condition is evaluated while the script is running and not while it is being built.")
	public static func buildOptional(_ parts:[BXScriptPart]?) -> [BXScriptPart]
	{
		parts ?? []
	}

	@available(*, unavailable, message:"Use If(condition) { } Else { } instead of a native Swift if statement, so that the condition is evaluated while the script is running and not while it is being built.")
	public static func buildEither(first parts:[BXScriptPart]) -> [BXScriptPart]
	{
		parts
	}

	@available(*, unavailable, message:"Use If(condition) { } Else { } instead of a native Swift if statement, so that the condition is evaluated while the script is running and not while it is being built.")
	public static func buildEither(second parts:[BXScriptPart]) -> [BXScriptPart]
	{
		parts
	}
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: -


/// A BXScriptPart represents a single statement inside a @BXScriptBuilder body.
///
/// Most statements simply carry commands. The If/ElseIf/Else blocks are kept separate until the whole body has been
/// collected, because an Else statement needs to be attached to the If statement that precedes it.

public enum BXScriptPart
{
	case commands(BXScriptCommands)
	case ifBlock(BXScriptIf)
	case elseIfBlock(BXScriptElseIf)
	case elseBlock(BXScriptElse)
}


extension BXScriptBuilder
{
	/// A single slot in a builder body, after the Else and ElseIf statements have been folded into their If statement

	private enum Slot
	{
		case commands(BXScriptCommands)
		case ifBlock(BXScriptIf)
	}


	/// Folds all ElseIf and Else statements into the preceding If statement, and then expands everything to a flat
	/// list of low-level commands.

	fileprivate static func scriptCommands(for parts:[BXScriptPart]) -> BXScriptCommands
	{
		var slots:[Slot] = []

		for part in parts
		{
			switch part
			{
				// Plain commands are simply appended

				case .commands(let commands):

					slots.append(.commands(commands))

				// An If starts a new if-block

				case .ifBlock(let ifBlock):

					slots.append(.ifBlock(ifBlock))

				// An ElseIf adds another branch to the preceding if-block

				case .elseIfBlock(let elseIfBlock):

					guard var ifBlock = Self.openIfBlock(in:slots) else { continue }

					ifBlock.branches.append( BXScriptIf.Branch(condition:elseIfBlock.condition, scriptCommands:elseIfBlock.scriptCommands) )
					slots[slots.count-1] = .ifBlock(ifBlock)

				// An Else provides the fallback for the preceding if-block

				case .elseBlock(let elseBlock):

					guard var ifBlock = Self.openIfBlock(in:slots) else { continue }

					ifBlock.elseCommands = elseBlock.scriptCommands
					slots[slots.count-1] = .ifBlock(ifBlock)
			}
		}

		var scriptCommands:BXScriptCommands = []

		for slot in slots
		{
			switch slot
			{
				case .commands(let commands): scriptCommands += commands
				case .ifBlock(let ifBlock): scriptCommands += ifBlock.scriptCommands
			}
		}

		return scriptCommands
	}


	/// Returns the if-block that an ElseIf or Else statement belongs to, i.e. the if-block in the last slot.
	///
	/// Returns nil if the last statement wasn't an If or ElseIf, or if the if-block already has an Else, as in both
	/// cases the script source code is malformed.

	private static func openIfBlock(in slots:[Slot]) -> BXScriptIf?
	{
		guard let slot = slots.last else
		{
			assertionFailure("BXScriptBuilder: Else and ElseIf must directly follow an If or ElseIf block.")
			return nil
		}

		guard case .ifBlock(let ifBlock) = slot else
		{
			assertionFailure("BXScriptBuilder: Else and ElseIf must directly follow an If or ElseIf block.")
			return nil
		}

		guard ifBlock.elseCommands == nil else
		{
			assertionFailure("BXScriptBuilder: An If block can only have a single Else block, and it must be last.")
			return nil
		}

		return ifBlock
	}
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: -


extension BXScriptCommands
{
	/// Creates a BXScriptCommands array with the high-level syntax.
	///
	///		let script = BXScriptCommands
	///		{
	///			Step("Welcome")
	///			SpeakText("Welcome to the tutorial.")
	///		}

	public init(@BXScriptBuilder _ body:()->BXScriptCommands)
	{
		self = body()
	}
}


//----------------------------------------------------------------------------------------------------------------------
