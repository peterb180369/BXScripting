//**********************************************************************************************************************
//
//  BXSubtitleView.swift
//	Displays the subtitles for narrated text
//  Copyright ©2024-2026 Peter Baumgartner. All rights reserved.
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
		
			.font(.system(size:20))
			.foregroundColor(.white)
			
			// A centered shadow is a soft halo around the glyphs. It is the second line of defense for the
			// cases that the backing alpha alone does not cover, e.g. when "Reduce Transparency" is on.
			
			.shadow(color:Color.black.opacity(0.45), radius:2, x:0, y:0)
			
			.lineLimit(nil)
			.fixedSize(horizontal:false, vertical:true)
			
			.padding(12)
			.frame(width:controller.size.width, height:controller.size.height)
	}
}


//----------------------------------------------------------------------------------------------------------------------
