//**********************************************************************************************************************
//
//  BXScriptCommand+waitForPublisher.swift
//	Adds a waitForPublisher command to BXScriptCommand
//  Copyright ©2023-2026 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Combine
import SwiftUI


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_waitForPublisher<NotificationCenter.Publisher>
{
	/// Creates a command that waits until a notification arrives for the specified number of times.
	
	public static func waitForNotification(_ notification:Notification.Name, minimumCount:Int = 1, timeoutDuration:Double? = nil, timeoutHandler:(()->Void)? = nil) -> BXScriptCommand
	{
		let publisher = NotificationCenter.default.publisher(for:notification)
		return BXScriptCommand_waitForPublisher(publisher:publisher, minimumCount:minimumCount, timeoutDuration:timeoutDuration, timeoutHandler:timeoutHandler)
	}
}

extension BXScriptCommand where Self == BXScriptCommand_waitForPublisher<AnyPublisher<Any,Never>>
{
	/// Creates a command that waits until a publisher fires for the specified number of times.
	
	public static func waitForPublisher(_ publisher:AnyPublisher<Any,Never>, minimumCount:Int = 1, timeoutDuration:Double? = nil, timeoutHandler:(()->Void)? = nil) -> BXScriptCommand
	{
		return BXScriptCommand_waitForPublisher(publisher:publisher, minimumCount:minimumCount, timeoutDuration:timeoutDuration, timeoutHandler:timeoutHandler)
	}
}

extension BXScriptCommand where Self == BXScriptCommand_waitForPublisher<ObservableObjectPublisher>
{
	/// Creates a command that waits until a publisher fires for the specified number of times.
	
	public static func waitForPublisher(_ publisher:ObservableObjectPublisher, minimumCount:Int = 1, timeoutDuration:Double? = nil, timeoutHandler:(()->Void)? = nil) -> BXScriptCommand
	{
		return BXScriptCommand_waitForPublisher(publisher:publisher, minimumCount:minimumCount, timeoutDuration:timeoutDuration, timeoutHandler:timeoutHandler)
	}
}


//----------------------------------------------------------------------------------------------------------------------


public struct BXScriptCommand_waitForPublisher<P:Publisher> : BXScriptCommand, BXScriptCommandCancellable where P.Failure==Never
{
	public var publisher:P
	public var minimumCount:Int
	public var timeoutDuration:Double?
	public var timeoutHandler:(()->Void)?
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	private var helper = Helper()
	
	public init(publisher:P, minimumCount:Int = 1, timeoutDuration:Double? = nil, timeoutHandler:(()->Void)? = nil)
	{
		self.publisher = publisher
		self.minimumCount = minimumCount
		self.timeoutDuration = timeoutDuration
		self.timeoutHandler = timeoutHandler
	}
	
	
	public func execute()
	{
		// Call the completionHandler once the specified notification arrives
		
		self.helper.subscribers += self.publisher
			.receive(on:queue)
			.sink
			{
				_ in
				
				self.helper.count += 1
				
				if self.helper.count >= self.minimumCount
				{
					self.helper.subscribers.removeAll()	// Kill all subscribers
					self.completionHandler?()
				}
			}
		
		// If we have a timeout, the setup a timer. Once we reach the timeout, call the timeoutHandler and then call the completionHandler.
		
		if let delay = timeoutDuration
		{
			self.helper.subscribers += Timer.publish(every:delay, on:.main, in:.default)
				.autoconnect()
				.receive(on:queue)
				.sink
				{
					_ in
					self.helper.subscribers.removeAll()	// Kill all subscribers
					self.timeoutHandler?()
					self.completionHandler?()
				}
		}
	}
	
	
	public func cancel()
	{
		self.helper.subscribers.removeAll()
	}
}


//----------------------------------------------------------------------------------------------------------------------


// This helper class is needed because the struct above is immutable

fileprivate class Helper
{
	var count = 0
	var subscribers:[Any] = []
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: - Builder


// The following functions provide the high-level syntax for the commands above. They simply forward to the low-level
// factory functions. Capitalized function names are necessary, because a command cannot be written with leading dot
// syntax as a statement inside a @BXScriptBuilder body - the compiler would parse consecutive lines that start with
// a dot as a single method chain.


public func WaitForNotification(_ notification:Notification.Name, minimumCount:Int = 1, timeoutDuration:Double? = nil, timeoutHandler:(()->Void)? = nil) -> BXScriptCommand
{
	.waitForNotification(notification, minimumCount:minimumCount, timeoutDuration:timeoutDuration, timeoutHandler:timeoutHandler)
}


public func WaitForPublisher(_ publisher:AnyPublisher<Any,Never>, minimumCount:Int = 1, timeoutDuration:Double? = nil, timeoutHandler:(()->Void)? = nil) -> BXScriptCommand
{
	.waitForPublisher(publisher, minimumCount:minimumCount, timeoutDuration:timeoutDuration, timeoutHandler:timeoutHandler)
}


public func WaitForPublisher(_ publisher:ObservableObjectPublisher, minimumCount:Int = 1, timeoutDuration:Double? = nil, timeoutHandler:(()->Void)? = nil) -> BXScriptCommand
{
	.waitForPublisher(publisher, minimumCount:minimumCount, timeoutDuration:timeoutDuration, timeoutHandler:timeoutHandler)
}


//----------------------------------------------------------------------------------------------------------------------
