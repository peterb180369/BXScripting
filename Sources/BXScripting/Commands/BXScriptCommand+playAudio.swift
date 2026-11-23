//**********************************************************************************************************************
//
//  BXScriptCommand+playAudio.swift
//	Adds a playAudio command
//  Copyright ©2023-2026 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_playAudio
{
	public static func playAudio(_ name:String, volume:Double = 1.0) -> BXScriptCommand
	{
		BXScriptCommand_playAudio(name:name, volume:volume)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command speaks the specified text.

public struct BXScriptCommand_playAudio : BXScriptCommand, BXScriptCommandCancellable
{
	public var name:String
	public var volume:Double = 1.0
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	public func execute()
	{
		self.queue.async
		{
			DispatchQueue.main.asyncIfNeeded
			{
				var volume = Float(self.volume)
				
				if let controller = BXScriptWindowController.shared, controller.muteAudio
				{
					volume = 0.0
				}

				guard let sound = NSSound(named:name) else { return }
				sound.volume = volume
				sound.play()
			}
			
			self.completionHandler?()
		}
	}
	
	public func cancel()
	{

	}
 }


//----------------------------------------------------------------------------------------------------------------------


// MARK: - Builder


// The following functions provide the high-level syntax for the commands above. They simply forward to the low-level
// factory functions. Capitalized function names are necessary, because a command cannot be written with leading dot
// syntax as a statement inside a @BXScriptBuilder body - the compiler would parse consecutive lines that start with
// a dot as a single method chain.


public func PlayAudio(_ name:String, volume:Double = 1.0) -> BXScriptCommand
{
	.playAudio(name, volume:volume)
}


//----------------------------------------------------------------------------------------------------------------------
