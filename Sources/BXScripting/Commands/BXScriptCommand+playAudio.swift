//**********************************************************************************************************************
//
//  BXScriptCommand+playAudio.swift
//	Adds a playAudio command
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
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
				guard let sound = NSSound(named:name) else { return }
				sound.volume = Float(volume)
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
