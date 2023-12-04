//**********************************************************************************************************************
//
//  BXScriptEngine.swift
//	Lightweight and extensible scripting engine for Swift based applications
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


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
	
	public var completionHandler:(()->Void)? = nil
	

//----------------------------------------------------------------------------------------------------------------------


	/// The index of the current command
	
	public var commandIndex = 0
	
	/// Will be set to true when script execution has been cancelled
	
	private var isCancelled = false
	
	
//----------------------------------------------------------------------------------------------------------------------


	/// The internal id for this BXScript object  is used for retaining the script while it is running.

	private var id = UUID().uuidString
	
	///  This internal dictionary is used to retain a BXScript while it is running.
	
	private static var runningScripts:[String:BXScriptEngine] = [:]
	
	
//----------------------------------------------------------------------------------------------------------------------


	// MARK: -
	
	
	/// Creates a new BXScriptEngine with the specified command and completionHandler.
	
	public init(_ scriptCommands:BXScriptCommands, environment:BXScriptEnvironment = .shared, completionHandler:(()->Void)? = nil)
	{
		self.scriptCommands = scriptCommands
		self.environment = environment
		self.completionHandler = completionHandler
	}
	
	
//----------------------------------------------------------------------------------------------------------------------


	/// Runs a script on the specified queue. Default is the main queue.
	///
	/// - Returns: The ID of the script.
	
	@discardableResult public static func run(on queue:DispatchQueue = .main, environment:BXScriptEnvironment = .shared, _ scriptCommands:BXScriptCommands, completionHandler:(()->Void)? = nil) -> String
	{
		let engine = BXScriptEngine(scriptCommands, environment:environment, completionHandler:completionHandler)
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
	
	private func executeNextCommand()
	{
	
		// If this script has been cancelled, then stop execution
		
		guard !isCancelled else
		{
			// Do NOT call completionHandler here, as this might be a subroutine script called from a
			// parent script. We want to stop the whole chain! Simply release the script and bail out.
			
			Self.runningScripts[self.id] = nil
			return
		}
		
		// Get the command at the current commandIndex
			
		if commandIndex >= 0 && commandIndex<scriptCommands.count
		{
			var currentCommand = scriptCommands[commandIndex]
			commandIndex += 1
			
			// Assign queue and completion handler before executing the command
			
			currentCommand.scriptEngine = self
			currentCommand.queue = self.queue

			currentCommand.completionHandler =										// This will trigger the following command
			{																		// in the next runloop cycle once the
				[weak self] in self?.queue.async { self?.executeNextCommand() }		// current command completes
			}

			currentCommand.execute()
		}
		
		// Once there are no more commands to be executed, call the completionHandler and release this BXSwiftScript
		
		else
		{
			self.queue.async
			{
				self.completionHandler?()
				Self.runningScripts[self.id] = nil
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
		for command in scriptCommands
		{
			command.cancel()
		}
		
		self.isCancelled = true
	}
}


//----------------------------------------------------------------------------------------------------------------------
