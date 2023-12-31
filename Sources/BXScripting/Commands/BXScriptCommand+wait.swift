//**********************************************************************************************************************
//
//  BXScriptCommand+wait.swift
//	Adds a wait command to BXScriptCommand
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
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
