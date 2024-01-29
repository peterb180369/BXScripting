//**********************************************************************************************************************
//
//  BXScriptWindowController.swift
//	Displays a small floating window with a controller for the BXScriptEngine
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import SwiftUI

#if canImport(BXSwiftUI)
import BXSwiftUI
#endif


//----------------------------------------------------------------------------------------------------------------------


/// The content view for the BXScriptWindowController panel

struct BXScriptControllerView : View
{
	@ObservedObject var controller:BXScriptWindowController
//	@EnvironmentObject var subtitleController:BXSubtitleWindowController
	
	public var body: some View
	{
		VStack(spacing:5)
		{
			// Title
			
			ZStack
			{
				Text(controller.currentStepName).centerAligned()
				Text(controller.currentStepNumber).leftAligned().opacity(0.33)
				self.audioButtons().rightAligned()
			}
			.padding(.top,-6)
			
			// Progress Bar
			
			BXScriptControllerProgressBar(controller:controller)
			
			// Buttons
			
			HStack
			{
				BXScriptControllerButton(systemName:"arrow.counterclockwise", title:"Repeat")
				{
					controller.repeatCurrentStep()
				}
				
				BXScriptControllerButton(systemName:"pause.fill", title:"Pause", fillColor: controller.isPaused ? .accentColor : .clear)
				{
					controller.isPaused = !controller.isPaused
				}
				
				BXScriptControllerButton(systemName:"square.fill", iconScale:0.8, title:"Stop Tutorial")
				{
					controller.abort()
				}
			}
		}
		
		// Layout
		
		.padding(12)
		.frame(minWidth:200)
		
		// Styling
		
		.colorScheme(.dark)
		.controlSize(.small)
		.background(VisualEffectView())
		.overlay(RoundedRectangle(cornerRadius:8).stroke(Color.primary.opacity(0.33)))
	}
	
	func audioButtons() -> some View
	{
		HStack(spacing:3)
		{
			Button(action:{controller.muteAudio.toggle()})
			{
				BXScriptControllerIcon(systemName:controller.muteAudio ? "speaker.slash.fill" : "speaker.fill")
			}

			BXScriptControllerSubtitleButton()
		}
		.buttonStyle(.borderless)
	}
}


//----------------------------------------------------------------------------------------------------------------------


fileprivate struct BXScriptControllerProgressBar : View
{
	@ObservedObject var controller:BXScriptWindowController

	var body: some View
	{
		GeometryReader
		{
			geometry in
			
			HStack(spacing:0)
			{
				Color.primary.frame(width:elapsedWidth(for:geometry))
				Color.primary.opacity(0.25).frame(width:remainingWidth(for:geometry))
			}
			.cornerRadius(2)
			.frame(height:4)
		}
	}
	
	var fraction:CGFloat
	{
		CGFloat(controller.stepIndex+1) / CGFloat(controller.stepCount)
	}
	
	func elapsedWidth(for geometry:GeometryProxy) -> CGFloat
	{
		fraction * geometry.size.width
	}
	
	func remainingWidth(for geometry:GeometryProxy) -> CGFloat
	{
		(1.0 - fraction) * geometry.size.width
	}
}


//----------------------------------------------------------------------------------------------------------------------


fileprivate struct BXScriptControllerButton : View
{
	var systemName:String
	var iconScale:CGFloat = 1.0
	var title:String
	var fillColor:Color = .clear
	var action:()->Void
	
	@State private var isPressed = false
	
	var color:Color
	{
		isPressed ? .primary.opacity(0.2) : fillColor
	}
	
	var body: some View
	{
		HStack(spacing:3)
		{
			BXScriptControllerIcon(systemName:systemName)
				.scaleEffect(iconScale)
				
			Text(title)
				.lineLimit(1)
				.fixedSize()
		}
		
		// Layout
		
		.padding(.vertical,2)
		.padding(.horizontal,4)
		.cornerRadius(4)
		
		// Styling
		
		.background(color)
		.overlay(RoundedRectangle(cornerRadius:4).stroke(Color.primary.opacity(0.33)))
		
		// Clicking
		
		.gesture( DragGesture(minimumDistance:0.0)
			.onChanged
			{
				_ in
				isPressed = true
			}
			.onEnded
			{
				_ in
				isPressed = false
				self.action()
			}
		)
	}
}


//----------------------------------------------------------------------------------------------------------------------


fileprivate struct BXScriptControllerIcon : View
{
	var systemName:String
	
	var body: some View
	{
		if #available(macOS 11,*)
		{
			SwiftUI.Image(systemName:systemName)
		}
		else
		{
			#if canImport(BXSwiftUI)
			BXImage(systemName:systemName)
			#endif
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------


fileprivate struct BXScriptControllerSubtitleButton : View
{
	@EnvironmentObject var subtitleController:BXSubtitleWindowController

	var body: some View
	{
		Button(action:{subtitleController.displaySubtitles.toggle()})
		{
			Text("CC")
				.controlSize(.mini)
				.foregroundColor(textColor)
				.padding(.horizontal,2)
				.background(shape)
		}
	}
	
	@ViewBuilder var shape: some View
	{
		if subtitleController.displaySubtitles
		{
			RoundedRectangle(cornerRadius:3)
				.fill(Color.primary.opacity(0.8))
		}
		else
		{
			RoundedRectangle(cornerRadius:3)
				.stroke(Color.primary.opacity(0.5))
		}
	}
	
	var textColor:Color
	{
		subtitleController.displaySubtitles ? .black : .primary
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// Creates a NSVisualEffectView that blurs whatever is BEHIND the window, similar to what a sidebar is doing.

struct VisualEffectView: NSViewRepresentable
{
    func makeNSView(context: Context) -> NSVisualEffectView
    {
		NSVisualEffectView.frostedGlassView()
    }

    func updateNSView(_ nsView:NSVisualEffectView, context: Context) { }
}


//----------------------------------------------------------------------------------------------------------------------
