//**********************************************************************************************************************
//
//  BXScriptCommand+wait.swift
//	Adds a wait command to BXScriptCommand
//  Copyright ©2023-2026 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_wait
{
	/// Creates a command that waits for the specified amount of seconds.
	
	public static func wait(seconds:Double) -> BXScriptCommand
	{
		BXScriptCommand_wait(delay:seconds)
	}

	/// Creates a command that waits for the specified amount of milliseconds.
	
	public static func wait(milliseconds:Double) -> BXScriptCommand
	{
		BXScriptCommand_wait(delay:milliseconds/1000)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command waits for the specified amount of time.

public struct BXScriptCommand_wait : BXScriptCommand, BXScriptCommandCancellable
{
	var delay:Double
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil

	fileprivate let helper = Helper()
	
	public func execute()
	{
		self.helper.isCancelled = false
		
		self.queue.asyncAfter(deadline:.now()+delay)
		{
			guard !self.helper.isCancelled else { return }
			self.completionHandler?()
		}
	}
	
	public func cancel()
	{
		self.helper.isCancelled = true
	}
}


//----------------------------------------------------------------------------------------------------------------------


// This helper class is needed because the struct above is immutable

fileprivate class Helper
{
	var isCancelled = false
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: - Builder


// The following functions provide the high-level syntax for the commands above. They simply forward to the low-level
// factory functions. Capitalized function names are necessary, because a command cannot be written with leading dot
// syntax as a statement inside a @BXScriptBuilder body - the compiler would parse consecutive lines that start with
// a dot as a single method chain.


public func Wait(seconds:Double) -> BXScriptCommand
{
	.wait(seconds:seconds)
}


public func Wait(milliseconds:Double) -> BXScriptCommand
{
	.wait(milliseconds:milliseconds)
}


//----------------------------------------------------------------------------------------------------------------------
