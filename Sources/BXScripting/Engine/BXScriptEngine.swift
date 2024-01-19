//**********************************************************************************************************************
//
//  BXScriptEngine.swift
//	Lightweight and extensible scripting engine for Swift based applications
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation
import SwiftUI


//----------------------------------------------------------------------------------------------------------------------


/// BXScriptEngine executes a list of BXScriptCommands, that will be run on a particular queue, with one step being executed per runloop cycle.

public class BXScriptEngine
{
	/// The list of commands in the script.
	
	public private(set) var scriptCommands:BXScriptCommands

	/// The environment for the running script
	
	public private(set) var environment:BXScriptEnvironment
	
	/// The queue that this script is running on.
	
	public private(set) var queue:DispatchQueue = .main

	/// The optional completionHandler will be executed after the last step on the specified queue.
	///
	/// Please note that this handler will only be executed if the script was NOT cancelled by the user.
	
	public var completionHandler:(()->Void)? = nil
	
	/// The optional cleanupHandler will be executed once script execution stops, either after the end of the last command, or when the user cancelled the script.
	
	public var cleanupHandler:(()->Void)? = nil


//----------------------------------------------------------------------------------------------------------------------


	/// The local index of the current command
	
	@Published public var commandIndex = 0
	
	/// Will be set to true when script execution has been cancelled
	
	@Published private var isCancelled = false
	
	
//----------------------------------------------------------------------------------------------------------------------


	/// The internal id for this BXScript object  is used for retaining the script while it is running.

	private var id = UUID().uuidString
	
	///  This internal dictionary is used to retain a BXScript while it is running.
	
	private static var runningScripts:[String:BXScriptEngine] = [:]
	
	
//----------------------------------------------------------------------------------------------------------------------


	/// This notification is sent before a command is executed.

	public static let willExecuteCommandNotification = Notification.Name("BXScriptEngine.willExecuteCommand")
	
	/// This notification is sent after the script finishes.

	public static let didEndNotification = Notification.Name("BXScriptEngine.didEnd")
	
	
//----------------------------------------------------------------------------------------------------------------------


	// MARK: -
	
	
	/// Creates a new BXScriptEngine with the specified command and completionHandler.
	
	public init(_ scriptCommands:BXScriptCommands, environment:BXScriptEnvironment = .shared, completionHandler:(()->Void)? = nil, cleanupHandler:(()->Void)? = nil)
	{
		self.scriptCommands = scriptCommands
		self.environment = environment
		self.completionHandler = completionHandler
		self.cleanupHandler = cleanupHandler
	}
	
	
//----------------------------------------------------------------------------------------------------------------------


	/// Runs a script on the specified queue. Default is the main queue.
	///
	/// - Returns: The ID of the script.
	
	@discardableResult public static func run(on queue:DispatchQueue = .main, environment:BXScriptEnvironment = .shared, _ scriptCommands:BXScriptCommands, completionHandler:(()->Void)? = nil, cleanupHandler:(()->Void)? = nil) -> String
	{
		let engine = BXScriptEngine(scriptCommands, environment:environment, completionHandler:completionHandler, cleanupHandler:cleanupHandler)
		return engine.run(on:queue)
	}


	/// Runs the script on the specified queue. Default is the main queue.
	///
	/// - Returns: The ID of the script.
	
	@discardableResult public func run(on queue:DispatchQueue = .main) -> String
	{
		// Retain this script until finished
		
		Self.runningScripts[id] = self

		// Set queue and start with first command
		
		self.queue = queue
		self.executeNextCommand()
		
		// Return the script ID. This can be used by the cancel(scriptID:) function
		
		return self.id
	}


	/// Executes the next command in the script.
	
	internal func executeNextCommand()
	{
		// If this script has been cancelled, then stop execution
		
		guard !isCancelled else
		{
			// Do NOT call completionHandler here, as this might be a subroutine script called from a
			// parent script. We want to stop the whole chain! Simply release the script and bail out.
			
			NotificationCenter.default.post(name:Self.didEndNotification, object:self, userInfo:nil)
			Self.runningScripts[self.id] = nil
			return
		}
		
		// Get the command at the current commandIndex
			
		if commandIndex >= 0 && commandIndex<scriptCommands.count
		{
			NotificationCenter.default.post(name:Self.willExecuteCommandNotification, object:self, userInfo:nil)
			var currentCommand = scriptCommands[commandIndex]
			commandIndex += 1
			
			// Assign queue and completion handler before executing the command
			
			currentCommand.scriptEngine = self
			currentCommand.queue = self.queue

			currentCommand.completionHandler =										// This will trigger the following command
			{																		// in the next runloop cycle once the
				[weak self] in self?.queue.async { self?.executeNextCommand() }		// current command completes
			}

			(currentCommand as? BXScriptCommandCancellable)?.reset()
			currentCommand.execute()
		}
		
		// Once there are no more commands to be executed, call the completionHandler and release this BXSwiftScript
		
		else
		{
			self.queue.async
			{
				self.completionHandler?()
				self.cleanupHandler?()
				Self.runningScripts[self.id] = nil
				NotificationCenter.default.post(name:Self.didEndNotification, object:self, userInfo:nil)
			}
		}
	}
	
	
//----------------------------------------------------------------------------------------------------------------------


	// MARK: -
	
	
	/// This function cancels execution of all scripts that are currently running.
	///
	/// Execution doesn't halt immediately. It will stop at the next runloop cycle, before the next script setp is executed.
	
	public static func cancelAll()
	{
		for (_,script) in runningScripts
		{
			script.cancel()
		}
	}
	
	
	/// This function cancels execution of the script with the specified id.
	///
	/// Execution doesn't halt immediately. It will stop at the next runloop cycle, before the next script setp is executed.
	
	public static func cancel(scriptID id:String)
	{
		guard let script = Self.runningScripts[id] else { return }
		script.cancel()
	}
	
	
	/// This function cancels execution of this script. Execution doesn't halt immediately.
	/// It will stop at the next runloop cycle, before the next script setp is executed.
	///
	/// Each command in the script will be given the chance to cleanup any side-effects it has caused.
	
	public func cancel()
	{
		self.cancelAllCommands()
		self.isCancelled = true
		self.cleanupHandler?()
	}


	/// Call the cancel() function of all commands in this script.
	
	public func cancelAllCommands()
	{
		for command in scriptCommands
		{
			(command as? BXScriptCommandCancellable)?.cancel()
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------
