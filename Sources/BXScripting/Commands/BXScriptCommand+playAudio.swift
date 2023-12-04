//**********************************************************************************************************************
//
//  BXScriptCommand+playAudio.swift
//	Adds a playAudio
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_playAudio
{
	public static func playAudio(_ name:String) -> BXScriptCommand
	{
		BXScriptCommand_playAudio(name:name)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command speaks the specified text.

public struct BXScriptCommand_playAudio : BXScriptCommand
{
	public var name:String
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	public func execute()
	{
		self.queue.async
		{
			DispatchQueue.main.asyncIfNeeded
			{
				NSSound(named:name)?.play()
			}
			
			self.completionHandler?()
		}
	}
	
	public func cancel()
	{

	}
 }


//----------------------------------------------------------------------------------------------------------------------
