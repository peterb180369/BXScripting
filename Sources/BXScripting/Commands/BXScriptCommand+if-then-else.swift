//**********************************************************************************************************************
//
//  BXScriptCommand+if.swift
//	Adds a if-then-else command to BXScriptCommand
//  Copyright ©2023-2026 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_if
{
	public static func `if`(_ condition:@autoclosure @escaping ()->Bool, label:String) -> BXScriptCommand
	{
		BXScriptCommand_if(condition:condition, label:label)
	}

	public static func `if`(_ condition:@autoclosure @escaping ()->Bool, label:any RawRepresentable<String>) -> BXScriptCommand
	{
		BXScriptCommand_if(condition:condition, label:label.rawValue)
	}

	public static func `if`(_ conditionName:String, label:String) -> BXScriptCommand
	{
		let condition:()->Bool = BXScriptEnvironment.shared[conditionName] ?? { false }
		return BXScriptCommand_if(condition:condition, label:label)
	}

	public static func `if`(_ conditionName:String, label:any RawRepresentable<String>) -> BXScriptCommand
	{
		let condition:()->Bool = BXScriptEnvironment.shared[conditionName] ?? { false }
		return BXScriptCommand_if(condition:condition, label:label.rawValue)
	}
}


extension BXScriptCommand where Self == BXScriptCommand_then
{
	public static func then(_ label:String) -> BXScriptCommand
	{
		BXScriptCommand_then(label:label)
	}

	public static func then(_ label:any RawRepresentable<String>) -> BXScriptCommand
	{
		BXScriptCommand_then(label:label.rawValue)
	}
}


extension BXScriptCommand where Self == BXScriptCommand_else
{
	public static func `else`(_ label:String) -> BXScriptCommand
	{
		BXScriptCommand_else(label:label)
	}

	public static func `else`(_ label:any RawRepresentable<String>) -> BXScriptCommand
	{
		BXScriptCommand_else(label:label.rawValue)
	}
}


extension BXScriptCommand where Self == BXScriptCommand_endif
{
	public static func endif(_ label:String) -> BXScriptCommand
	{
		BXScriptCommand_endif(label:label)
	}

	public static func endif(_ label:any RawRepresentable<String>) -> BXScriptCommand
	{
		BXScriptCommand_endif(label:label.rawValue)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command checks a condition and jumps to the then or else label

public struct BXScriptCommand_if : BXScriptCommand, BXScriptCommandLabeled
{
	var condition:()->Bool
	public var label:String
	
	public weak var scriptEngine:BXScriptEngine? = nil
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	
	
	public func execute()
	{
		self.queue.async
		{
			if condition()
			{
				if let thenIndex = self.index(for:label, type:BXScriptCommand_then.self)			// Jump to "then"
				{
					scriptEngine?.commandIndex = thenIndex
				}
			}
			else
			{
				if let elseIndex = self.index(for:label, type:BXScriptCommand_else.self)			// Jump to "else"
				{
					scriptEngine?.commandIndex = elseIndex + 1 // Important: jump to index AFTER "else", because else command jumps to "endif"
				}
				else if let endifIndex = self.index(for:label, type:BXScriptCommand_endif.self)		// If there is no "else" then jump to "endif" instead
				{
					scriptEngine?.commandIndex = endifIndex
				}
			}
			
			completionHandler?()
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command provides a label for the "then"

public struct BXScriptCommand_then : BXScriptCommand, BXScriptCommandLabeled
{
	public var label:String
	
	public weak var scriptEngine:BXScriptEngine? = nil
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	
	public func execute()
	{
		self.queue.async
		{
			completionHandler?() // Nothing to do here, just call completionHandler
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command  provides a label for the "else" and jumps directly to the "endif"

public struct BXScriptCommand_else : BXScriptCommand, BXScriptCommandLabeled
{
	public var label:String
	
	public weak var scriptEngine:BXScriptEngine? = nil
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	
	public func execute()
	{
		if let endifIndex = self.index(for:label, type:BXScriptCommand_endif.self)
		{
			scriptEngine?.commandIndex = endifIndex	// Jump to "endif"
		}
			
		completionHandler?()
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command provides a label for the "endif"

public struct BXScriptCommand_endif : BXScriptCommand, BXScriptCommandLabeled
{
	public var label:String
	
	public weak var scriptEngine:BXScriptEngine? = nil
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	
	public func execute()
	{
		self.queue.async
		{
			completionHandler?() // Nothing to do here, just call completionHandler
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: - Builder


/// Creates a conditional block for the high-level script syntax.
///
///		If( slideCount == 0 )
///		{
///			SpeakText("Please drag some images to the storyboard.")
///		}
///		ElseIf( slideCount < 5 )
///		{
///			SpeakText("Please drag some more images.")
///		}
///		Else
///		{
///			SpeakText("That's plenty of images.")
///		}
///
/// The condition is stored in a closure and evaluated by the engine when it reaches this point in the script, i.e.
/// it reflects the state of the app at that moment and not the state when the script was being built.

public func If(_ condition:@autoclosure @escaping ()->Bool, @BXScriptBuilder _ body:()->BXScriptCommands) -> BXScriptIf
{
	BXScriptIf(branches:[BXScriptIf.Branch(condition:condition, scriptCommands:body())])
}


/// Adds another condition to the preceding If block. Must directly follow an If or ElseIf block.

public func ElseIf(_ condition:@autoclosure @escaping ()->Bool, @BXScriptBuilder _ body:()->BXScriptCommands) -> BXScriptElseIf
{
	BXScriptElseIf(condition:condition, scriptCommands:body())
}


/// Adds the fallback to the preceding If block. Must directly follow an If or ElseIf block.

public func Else(@BXScriptBuilder _ body:()->BXScriptCommands) -> BXScriptElse
{
	BXScriptElse(scriptCommands:body())
}


//----------------------------------------------------------------------------------------------------------------------


/// An If block with one or more conditional branches and an optional fallback.
///
/// Please note that this is not a BXScriptCommand, but a description that is expanded to a list of if-then-else-endif
/// commands by the BXScriptBuilder.

public struct BXScriptIf
{
	/// A single condition with the commands that are executed when it is true

	public struct Branch
	{
		var condition:()->Bool
		var scriptCommands:BXScriptCommands
	}

	/// The branches of this block, in source code order. The first one is the If, the others are the ElseIfs.

	var branches:[Branch]

	/// The commands of the Else block, if there is one

	var elseCommands:BXScriptCommands? = nil
}


extension BXScriptIf
{
	/// Expands this block to a flat list of low-level commands

	public var scriptCommands:BXScriptCommands
	{
		Self.scriptCommands(for:branches, elseCommands:elseCommands)
	}


	/// Expands the specified branches recursively, so that an ElseIf becomes a nested if-then-else-endif.
	///
	/// The generated label is a UUID, which guarantees that the jump targets of nested or repeated blocks can never
	/// be confused with each other - something that was easy to get wrong with hand-written label strings.

	private static func scriptCommands(for branches:[Branch], elseCommands:BXScriptCommands?) -> BXScriptCommands
	{
		guard let branch = branches.first else { return elseCommands ?? [] }

		let label = UUID().uuidString
		let remaining = Array(branches.dropFirst())
		let fallbackCommands = Self.scriptCommands(for:remaining, elseCommands:elseCommands)

		var scriptCommands:BXScriptCommands = []

		scriptCommands.append(.if(branch.condition(), label:label))
		scriptCommands.append(.then(label))
		scriptCommands += branch.scriptCommands

		// The else command is only needed if anything follows this branch. Without it the if command jumps
		// directly to the endif when the condition is false.

		if !fallbackCommands.isEmpty
		{
			scriptCommands.append(.else(label))
			scriptCommands += fallbackCommands
		}

		scriptCommands.append(.endif(label))

		return scriptCommands
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// The description of an ElseIf block. Created by the ElseIf() function and folded into the preceding BXScriptIf.

public struct BXScriptElseIf
{
	var condition:()->Bool
	var scriptCommands:BXScriptCommands
}


/// The description of an Else block. Created by the Else() function and folded into the preceding BXScriptIf.

public struct BXScriptElse
{
	var scriptCommands:BXScriptCommands
}


//----------------------------------------------------------------------------------------------------------------------
