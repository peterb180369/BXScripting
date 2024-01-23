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
	
	public var body: some View
	{
		VStack(spacing:5)
		{
			// Title
			
			ZStack
			{
				Text(controller.currentStepName).centerAligned()
				Text(controller.currentStepNumber).rightAligned().opacity(0.33)
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


/// Creates a NSVisualEffectView that blurs whatever is BEHIND the window, similar to what a sidebar is doing.

struct VisualEffectView: NSViewRepresentable
{
    func makeNSView(context: Context) -> NSVisualEffectView
    {
        let effectView = NSVisualEffectView()
        effectView.appearance = NSAppearance(named:.vibrantLight)
        effectView.state = .active
        effectView.material = .mediumLight // This material is deprecated, but I haven't found a visual equivalent yet, so until I do, do not change
        effectView.blendingMode = .behindWindow
        effectView.isEmphasized = true
        return effectView
    }

    func updateNSView(_ nsView:NSVisualEffectView, context: Context) { }
}


//----------------------------------------------------------------------------------------------------------------------
