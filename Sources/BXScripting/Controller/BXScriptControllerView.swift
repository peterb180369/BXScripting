//**********************************************************************************************************************
//
//  BXScriptWindowController.swift
//	Displays a small floating window with a controller for the BXScriptEngine
//  Copyright ©2023-2026 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import SwiftUI


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
				HStack
				{
					Spacer()
					Text(controller.currentStepName)
					Spacer()
				}
				
				HStack
				{
					Text(controller.currentStepNumber)
						.font(.system(size:10, design:.monospaced))
						.opacity(0.65)
					Spacer()
				}
				
				HStack
				{
					Spacer()
					self.audioButtons()
				}
			}
			.padding(.top,-6)
			
			// Progress Bar
			
			BXScriptControllerProgressBar(controller:controller)
			
			// Buttons
			
			HStack
			{
				BXScriptControllerButton(systemName:"arrow.counterclockwise", title:"Repeat", borderOpacity:chromeOpacity)
				{
					controller.repeatCurrentStep()
				}
				
				BXScriptControllerButton(systemName:"pause.fill", title:"Pause", fillColor: controller.isPaused ? Color.accentColor.opacity(0.85) : .clear, borderOpacity:chromeOpacity)
				{
					controller.isPaused = !controller.isPaused
				}
				
				BXScriptControllerButton(systemName:"square.fill", iconScale:0.8, title:"Stop Tutorial", borderOpacity:chromeOpacity)
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
		
		// Centered shadows are a soft halo around the glyphs, not a drop shadow. They must be applied BEFORE
		// the background, so that they halo the content and not the panel rectangle - in which case they would
		// merely stack another window shadow onto the one that the window already draws.
		//
		// The halo is what lets the panel stay as light as it is. The material follows the brightness of the
		// backdrop, so over light content the white glyphs cannot rely on the panel for their contrast and
		// have to bring it with them. Two passes do that better than one: a tight dark edge that keeps the
		// letterforms crisp, plus a wider soft bloom that lifts them off whatever shows through the panel.
		
		.shadow(color:Color.black.opacity(0.8), radius:1, x:0, y:0)
		.shadow(color:Color.black.opacity(0.35), radius:3, x:0, y:0)
		.background(VisualEffectView(scrimAlpha:scrimAlpha))
		
		// strokeBorder (instead of stroke) draws the line INSIDE the shape. Since the hosting view clips to
		// its rounded corners, a centered stroke would lose its outer half and appear at half the density.
		
		.overlay(RoundedRectangle(cornerRadius:8).strokeBorder(Color.primary.opacity(borderOpacity), lineWidth:1))
	}
	
	
	// MARK: - Hover
	
	// While the pointer is elsewhere, the panel recedes: the glass gets lighter and the button outlines
	// fade away, leaving nothing but the step name, the progress bar and a faint rim. When the user reaches
	// for the panel, it firms up again. Note that only the chrome is dimmed, never the text - the step name,
	// the step counter and the progress bar keep their full contrast in both states, so the panel stays
	// readable at a glance without having to touch the mouse.
	
	/// The opacity of the dark tint that is composited on top of the frosted glass.
	///
	/// While idle there is none at all: the material alone is what the panel should look like, and every
	/// attempt at darkening it further ended up with a panel that drew more attention than the content it was
	/// explaining. The small amount on hover is only there to let the panel firm up under the pointer.
	
	private var scrimAlpha:Double
	{
		// With "Reduce Transparency" turned on the material renders opaque by itself, so leave it alone
		
		if NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency { return 0.0 }
		
		return controller.isHovering ? 0.12 : 0.0
	}
	
	/// The opacity of the rim around the panel. While idle the rim is barely there: against a light backdrop
	/// the panel is darker than its surroundings anyway and needs no outline, and a bright ring is the single
	/// most conspicuous thing that can be added to a small floating window.
	
	private var borderOpacity:Double
	{
		controller.isHovering ? 0.55 : 0.25
	}
	
	/// The opacity of the outlines around the buttons
	
	private var chromeOpacity:Double
	{
		controller.isHovering ? 0.6 : 0.2
	}
	
	
	// MARK: - Subviews
	
	
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
			
			// The track spans the full width and the elapsed part is drawn on top of it, so that both are
			// the same color and differ only in opacity.
			
			ZStack(alignment:.leading)
			{
				RoundedRectangle(cornerRadius:2)
					.fill(Color.primary.opacity(0.25))
				
				RoundedRectangle(cornerRadius:2)
					.fill(Color.primary)
					.frame(width:elapsedWidth(for:geometry))
			}
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
}


//----------------------------------------------------------------------------------------------------------------------


fileprivate struct BXScriptControllerButton : View
{
	var systemName:String
	var iconScale:CGFloat = 1.0
	var title:String
	var fillColor:Color = .clear
	var borderOpacity:Double = 0.5
	var action:()->Void
	
	@State private var isPressed = false
	
	var color:Color
	{
		isPressed ? .primary.opacity(0.25) : fillColor
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
		.overlay(RoundedRectangle(cornerRadius:4).strokeBorder(Color.primary.opacity(borderOpacity), lineWidth:1))
		
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
			EmptyView()
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
				.foregroundColor(.primary)
				.padding(.horizontal,2)
				.background(shape)
		}
	}
	
	@ViewBuilder var shape: some View
	{
		ZStack
		{
			if subtitleController.displaySubtitles
			{
				RoundedRectangle(cornerRadius:3)
					.fill(Color.accentColor.opacity(0.85))
			}

			RoundedRectangle(cornerRadius:3)
				.strokeBorder(Color.primary.opacity(0.55), lineWidth:1)
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// Creates a NSVisualEffectView that blurs whatever is BEHIND the window, similar to what a sidebar is doing.
///
/// The hudWindow material in a dark appearance was picked by comparing all materials side by side over light,
/// dark and saturated backdrops. It is the one AppKit provides for a small floating control surface, and it is
/// the only one that both blurs the backdrop and still follows its brightness.
///
/// ATTENTION: it needs no help. Darkening it with an additional tint is what turned the panel into an opaque
/// chip in the first place - the material is already dark, and the two multiply.

struct VisualEffectView : NSViewRepresentable
{
	var appearance:NSAppearance.Name = .darkAqua
	var material:NSVisualEffectView.Material = .hudWindow
	var scrimAlpha:CGFloat = 0.0
	
    func makeNSView(context:Context) -> NSVisualEffectView
    {
		NSVisualEffectView.frostedGlassView(appearance:appearance, material:material, scrimAlpha:scrimAlpha)
    }

    func updateNSView(_ nsView:NSVisualEffectView, context:Context)
    {
		nsView.appearance = NSAppearance(named:appearance)
		nsView.material = material
		(nsView as? BXScrimmedVisualEffectView)?.scrimAlpha = scrimAlpha
    }
}


//----------------------------------------------------------------------------------------------------------------------
