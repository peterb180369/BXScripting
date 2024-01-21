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


struct BXScriptControllerView : View
{
	@ObservedObject var controller:BXScriptWindowController
	
	public var body: some View
	{
		VStack(spacing:8)
		{
			// Name
			
			HStack(spacing:8)
			{
				Spacer()
				Text(controller.currentStepNumber).opacity(0.33)
				Text(controller.currentStepName).opacity(0.66)
				Spacer()
			}
			
			// Progress Bar
			
			HStack
			{
				if #available(macOS 11,*)
				{
					ProgressView(value:Double(controller.stepIndex+1), total:Double(controller.stepCount))
				}
				else
				{
					#if canImport(BXSwiftUI)
					BXProgressBar(value:Double(controller.stepIndex+1), maxValue:Double(controller.stepCount))
					#endif
				}
			}
			
			// Repeat Button
			
			Button(action:controller.repeatCurrentStep)
			{
				HStack
				{
					Spacer()
					
					if #available(macOS 11,*)
					{
						SwiftUI.Image(systemName:"arrow.counterclockwise")
					}
					else
					{
						#if canImport(BXSwiftUI)
						BXImage(systemName:"arrow.counterclockwise")
						#endif
					}

					Text("Repeat")
					Spacer()
				}
			}
			.opacity(0.6)
			
			// Pause Button
			
			Button(action:{controller.isPaused = !controller.isPaused})
			{
				HStack
				{
					Spacer()
					
					if #available(macOS 11,*)
					{
						SwiftUI.Image(systemName:"pause.fill")
					}
					else
					{
						#if canImport(BXSwiftUI)
						BXImage(systemName:"pause.fill")
						#endif
					}

					Text("Pause")
					Spacer()
				}
				.foregroundColor(controller.isPaused ? .accentColor : .primary.opacity(0.6))
			}
			
			// Stop Button
			
			Button(action:controller.abort)
			{
				HStack
				{
					Spacer()
					Text("Stop Tutorial")
					Spacer()
				}
			}
			.opacity(0.6)
		}
		
		.padding()
		.frame(minWidth:160)
		.border(Color.primary.opacity(0.07))

		.colorScheme(.dark)
		.controlSize(.small)
		
		#if canImport(BXSwiftUI)
		.buttonStyle(BXStrokedButtonStyle())
		#endif
		
	}
}


//----------------------------------------------------------------------------------------------------------------------
