//**********************************************************************************************************************
//
//  BXScriptCommand.swift
//	Defines the requirements for a single command in a script
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation


//----------------------------------------------------------------------------------------------------------------------


/// An array of commands makes a script

public typealias BXScriptCommands = [any BXScriptCommand]


//----------------------------------------------------------------------------------------------------------------------


/// The BXScriptCommand protocol defines the API for a generic step in a BXSwiftScript

public protocol BXScriptCommand
{
	/// A reference to the engine that runs this step. This can be used to interact with the engine, e.g. to cancel or to change the commandIndex.
	
	/*weak*/ var scriptEngine:BXScriptEngine? { set get }

	/// The (optional) queue will be passed to the step by the script
	
	var queue:DispatchQueue { set get }
	
	/// This completionHandler will be set by the BXScriptEngine.
	///
	/// It MUST be called exactly once, after this step has been executed. This will trigger the following command in the script.
	
	var completionHandler:(()->Void)? { set get }
	
	/// This required function performs the work for a single step in a script
	
	func execute()
}


//----------------------------------------------------------------------------------------------------------------------


/// This protocol can be adopted by commands that need to cleanup upon cancellation

public protocol BXScriptCommandCancellable : BXScriptCommand
{
	func cancel()
}


//extension BXScriptCommandCancellable
//{
//	public func cancel() {}
//}


//----------------------------------------------------------------------------------------------------------------------


/// This protocol can be adopted by commands that have a label

public protocol BXScriptCommandLabeled
{
	/*weak*/ var scriptEngine:BXScriptEngine? { get }
	var label:String { get }
}


extension BXScriptCommandLabeled
{
	/// Returns the index for the first command of specified type and label.
	
	public func index<T:BXScriptCommandLabeled>(for label:String, type:T.Type) -> Int?
	{
		guard let scriptEngine = self.scriptEngine else { return nil }

		for (index,command) in scriptEngine.scriptCommands.enumerated()
		{
			if let cmd = command as? T, label == cmd.label
			{
				return index
			}
		}

		return nil
	}
}


//----------------------------------------------------------------------------------------------------------------------
