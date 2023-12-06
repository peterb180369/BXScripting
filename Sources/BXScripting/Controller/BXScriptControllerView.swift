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
			
			HStack
			{
				Spacer()
				Text(controller.currentStepNumber).opacity(0.33)
				Text(controller.currentStepName)
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

//				Button(action:controller.abort)
//				{
//					SwiftUI.Image(systemName:"xmark.circle")
//				}
//				.buttonStyle(.borderless)
//				.controlSize(.large)
			}
			
			// Repeat Button
			
			HStack
			{
				Spacer()
				
				if #available(macOS 11,*)
				{
					Button("Repeat", systemImage:"arrow.counterclockwise")
					{
						controller.repeatCurrentStep()
					}
					#if canImport(BXSwiftUI)
					.buttonStyle(BXStrokedButtonStyle())
					#endif
				}
				else
				{
					#if canImport(BXSwiftUI)

					Button(action:controller.repeatCurrentStep)
					{
						HStack
						{
							BXImage(systemName:"arrow.counterclockwise")
							Text("Repeat")
						}
					}
					.buttonStyle(BXStrokedButtonStyle())

					#endif
				}

				Spacer()
			}
		}
		.padding()
		.controlSize(.regular)
		.colorScheme(.dark)
		.frame(minWidth:240)
	}
}


//----------------------------------------------------------------------------------------------------------------------
