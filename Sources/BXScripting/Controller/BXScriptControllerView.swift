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
		VStack(spacing:9)
		{
				HStack
				{
					Spacer()
					Text(controller.currentStepName)
					Text(controller.currentStepNumber).opacity(0.33)
					Spacer()
				}
				
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
						#else
						BXScriptStepsView(controller:controller)
						#endif
					}

//					Button(action:controller.abort)
//					{
//						SwiftUI.Image(systemName:"xmark.circle")
//					}
//					.buttonStyle(.borderless)
//					.controlSize(.large)
				}
				
				HStack
				{
					Spacer()
					
					Button("Repeat", systemImage:"arrow.counterclockwise")
					{
						controller.back()
					}
					Spacer()
				}

		}
		.padding()
		.controlSize(.regular)
		.colorScheme(.dark)
		
		#if canImport(BXSwiftUI)
		.buttonStyle(BXStrokedButtonStyle())
		#endif
		
		.frame(minWidth:240)
	}
}


//----------------------------------------------------------------------------------------------------------------------


struct BXScriptStepsView : View
{
	@ObservedObject var controller:BXScriptWindowController
	
	public var body: some View
	{
		print("BXScriptStepsView.body")
		
		return HStack(alignment:.center, spacing:0)
		{
			ForEach(0...controller.stepCount-1, id:\.self)
			{
				i in
				
				BXScriptStepView(/*controller:controller,*/ name:controller.labels[i], isCurrent:controller.stepIndex==i)
					.frame(width:10, height:10)
					
				if i < controller.stepCount-1
				{
					Rectangle()
						.frame(width:4, height:1)
						.opacity(0.5)
				}
			}
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------


struct BXScriptStepView : View
{
	var name:String
	var isCurrent:Bool
	
	public var body: some View
	{
		if isCurrent
		{
			Circle()
				.fill(Color.primary)
		}
		else
		{
			Circle()
				.stroke(lineWidth:1)
				.opacity(0.5)
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------


