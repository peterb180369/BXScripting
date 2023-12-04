//**********************************************************************************************************************
//
//  BXScriptCommand+waitUntil.swift
//	Adds a waitUntil condition command to BXScriptCommand
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


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

public struct BXScriptCommand_waitUntil : BXScriptCommand
{
	public var condition:()->Bool
	public var timeoutDuration:Double?
	public var timeoutHandler:(()->Void)?
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	private var startTime:CFAbsoluteTime
	
	public init(condition:@escaping ()->Bool, timeoutDuration:Double? = nil, timeoutHandler:(()->Void)? = nil)
	{
		self.condition = condition
		self.timeoutDuration = timeoutDuration
		self.timeoutHandler = timeoutHandler
		self.startTime = CFAbsoluteTimeGetCurrent()
	}
	
	public func execute()
	{
		self.queue.async
		{
			// Once the condition is true, we can continue to the following command
			
			if condition()
			{
				self.completionHandler?()
			}
			else
			{
				// If we reach a timeout, call the timeoutHandler and then go on to the next command
				
				if let timeoutDuration = timeoutDuration
				{
					if CFAbsoluteTimeGetCurrent() - startTime >= timeoutDuration
					{
						self.timeoutHandler?()
						self.completionHandler?()
						return
					}
				}
				
				// If not true yet, simply check again in next runloop cycle
				
				self.execute()
			}
		}
	}

}


//----------------------------------------------------------------------------------------------------------------------
