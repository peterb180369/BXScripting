//**********************************************************************************************************************
//
//  BXScriptCommand+for-endfor.swift
//	Adds a for-endfor command to BXScriptCommand
//  Copyright ©2023-2026 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_while
{
	public static func `for`(_ range:ClosedRange<Int>, label:String) -> BXScriptCommand
	{
		BXScriptCommand_for(range:range, label:label)
	}
}

extension BXScriptCommand where Self == BXScriptCommand_endfor
{
	public static func endfor(_ label:String) -> BXScriptCommand
	{
		BXScriptCommand_endfor(label:label)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command checks a condition and jumps to the first command after endwhile if the condition is false.

public struct BXScriptCommand_for : BXScriptCommand, BXScriptCommandLabeled
{
	var range:ClosedRange<Int>
	public var label:String
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	public func execute()
	{
		self.queue.async
		{
			// If we already have an i value in the environment, then increment it.
			// Once we go beyond end of range, exit the loop.
			
			if let i:Int = scriptEngine?.environment[label]
			{
				scriptEngine?.environment[label] = i + 1
				
				if i > range.upperBound, let endforIndex = self.index(for:label, type:BXScriptCommand_endfor.self)
				{
					scriptEngine?.commandIndex = endforIndex + 1 // Jump to first command AFTER endfor
				}
			}
			
			// During the first iteration we do not have an i value in the environment yet,
			// so set it to the start value
			
			else
			{
				scriptEngine?.environment[label] = range.lowerBound
			}

			completionHandler?()
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command jumps to the start of the for loop, where the condition will be evaluated again.

public struct BXScriptCommand_endfor : BXScriptCommand, BXScriptCommandLabeled
{
	public var label:String
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	public func execute()
	{
		self.queue.async
		{
			if let forIndex = self.index(for:label, type:BXScriptCommand_for.self)
			{
				scriptEngine?.commandIndex = forIndex // Jump to start of for-loop
			}
			
			completionHandler?()
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: - Builder


/// Creates a counting loop for the high-level script syntax.
///
///		For(1...slideCount)
///		{
///			index in
///
///			SpeakText("This is slide number \(index()).")
///			Action { document.playhead = index() }
///		}
///
/// The index is supplied as a closure, because its value is only known while the script is running. Make sure to
/// call it inside a command argument that is itself lazy (most command arguments are @autoclosure) or inside an
/// Action closure, otherwise the value is read while the script is being built.

public func For(_ range:ClosedRange<Int>, @BXScriptBuilder _ body:(@escaping ()->Int)->BXScriptCommands) -> BXScriptFor
{
	BXScriptFor(range, body)
}


//----------------------------------------------------------------------------------------------------------------------


/// A For loop that is expanded to a while-endwhile command pair with an explicit counter.
///
/// ATTENTION: This is deliberately built on the while commands instead of the for-endfor commands, because the latter
/// store their counter in the script environment under the label key, which is never cleared - a for loop could thus
/// not be run a second time. The counter below is owned by this loop, so it is properly reset on every entry.

public struct BXScriptFor : BXScriptFragment
{
	private let range:ClosedRange<Int>
	private let counter:Counter
	private let bodyCommands:BXScriptCommands


	init(_ range:ClosedRange<Int>, _ body:(@escaping ()->Int)->BXScriptCommands)
	{
		let counter = Counter()

		self.range = range
		self.counter = counter
		self.bodyCommands = body({ counter.index })
	}


	public var scriptCommands:BXScriptCommands
	{
		let label = UUID().uuidString
		let counter = self.counter
		let range = self.range
		var scriptCommands:BXScriptCommands = []

		scriptCommands.append(.action { counter.index = range.lowerBound })
		scriptCommands.append(.while({ counter.index <= range.upperBound }, label:label))
		scriptCommands += bodyCommands
		scriptCommands.append(.action { counter.index += 1 })
		scriptCommands.append(.endwhile(label))

		return scriptCommands
	}


	/// The loop counter needs to be a reference type, as it is shared by the commands of this loop

	final class Counter
	{
		var index = 0
	}
}


//----------------------------------------------------------------------------------------------------------------------
