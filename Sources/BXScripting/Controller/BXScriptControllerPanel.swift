//**********************************************************************************************************************
//
//  BXScriptWindowController.swift
//	Displays a small floating window with a controller for the BXScriptEngine
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import SwiftUI


//----------------------------------------------------------------------------------------------------------------------


class BXScriptControllerPanel : NSPanel
{
	override open var canBecomeMain:Bool
	{
		false
	}

	override open var canBecomeKey:Bool
	{
		false
	}

	override open var acceptsFirstResponder:Bool
	{
		false
	}
}

//----------------------------------------------------------------------------------------------------------------------
