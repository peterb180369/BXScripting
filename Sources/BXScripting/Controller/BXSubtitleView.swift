//**********************************************************************************************************************
//
//  BXSubtitleView.swift
//	Displays the subtitles for narrated text
//  Copyright ©2024 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import SwiftUI


//----------------------------------------------------------------------------------------------------------------------


/// The content view for the BXScriptWindowController panel

struct BXSubtitleView : View
{
	@ObservedObject var controller:BXSubtitleWindowController
	
	public var body: some View
	{
		Text(controller.displayedText)
			.lineLimit(nil)
			.foregroundColor(.white)
			.font(.title)
			.padding()
	}
}


//----------------------------------------------------------------------------------------------------------------------
