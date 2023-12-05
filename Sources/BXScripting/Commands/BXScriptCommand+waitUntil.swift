//**********************************************************************************************************************
//
//  BXScriptCommand+waitUntil.swift
//	Adds a waitUntil condition command to BXScriptCommand
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_waitUntil
{
	/// Creates a command that waits for multiple runloop cycles until the specified condition is true.
	
	public static func waitUntil(_ condition:@escaping ()->Bool, timeoutDuration:Double? = nil, timeoutHandler:(()->Void)? = nil) -> BXScriptCommand
	{
		BXScriptCommand_waitUntil(condition:condition, timeoutDuration:timeoutDuration, timeoutHandler:timeoutHandler)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command waits for multiple runloop cycles until the specified condition is true.

public struct BXScriptCommand_waitUntil : BXScriptCommand, BXScriptCommandCancellable
{
	public var condition:()->Bool
	public var timeoutDuration:Double?
	public var timeoutHandler:(()->Void)?
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	private var startTime:CFAbsoluteTime
	
	private var helper = Helper()


	public init(condition:@escaping ()->Bool, timeoutDuration:Double? = nil, timeoutHandler:(()->Void)? = nil)
	{
		self.condition = condition
		self.timeoutDuration = timeoutDuration
		self.timeoutHandler = timeoutHandler
		self.startTime = CFAbsoluteTimeGetCurrent()
	}
	
	
	public func execute()
	{
		guard !self.helper.isCancelled else { return }
		
		self.queue.async
		{
			// Once the condition is true, we can continue to the following command
			
			if condition()
			{
				self.completionHandler?()
			}
			
			// If we reach a timeout, call the timeoutHandler and then go on to the next command
				
			else if let timeoutDuration = timeoutDuration, CFAbsoluteTimeGetCurrent() - startTime >= timeoutDuration
			{
				self.timeoutHandler?()
				self.completionHandler?()
			}
				
			// If not true yet, simply check again in next runloop cycle
			
			else
			{
				self.execute()
			}
		}
	}

	public func reset()
	{
		self.helper.isCancelled = false
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
