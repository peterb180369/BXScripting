//**********************************************************************************************************************
//
//  BXScriptWindowController.swift
//	Displays a small floating window with a controller for the BXScriptEngine
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit
import SwiftUI


//----------------------------------------------------------------------------------------------------------------------


/// BXScriptWindowController displays a small floating window with a controller for the BXScriptEngine

public class BXScriptWindowController : NSWindowController, ObservableObject, NSWindowDelegate
{
	/// Singleton instance of the prefs window
	
	public static var shared:BXScriptWindowController? = nil
	
	/// The BXScriptEngine that is being controlled by this window

	private var engine:BXScriptEngine

	/// The controller window title
	
	private var title:String = ""
	
	/// The id of the running script. Can be used for cancelling
	
	private var scriptID:String = ""
	
	/// The number of the current step (useful for progress info)

	@Published public var stepIndex = 0
	
	/// The total number of steps (useful for progress info)

	public private(set) var stepCount = 0
	
	/// The labels for all steps
	
	public private(set) var labels:[String] = []
	
	/// A lookup table to find first command index for a step
	
	private var commandIndexes:[Int] = []
	
	private var stepIndexes:[Int] = []
	
	/// Subscribers
	
	private var subscribers:[Any] = []
	
	
//----------------------------------------------------------------------------------------------------------------------


	// MARK: - Lifecycle
	
	
	@discardableResult public class func run(_ engine:BXScriptEngine, title:String = "", on queue:DispatchQueue = .main) -> String
	{
		if shared == nil
		{
			self.shared = BXScriptWindowController(engine:engine, title:title)
		}
		
		self.shared?.loadWindow()
		
		if let screen = NSScreen.main, let window = self.shared?.window
		{
			let bounds = screen.visibleFrame.insetBy(dx:48, dy:48)
			var p = bounds.bottomRight
			p.x -= window.frame.width
			
			window.orderFront(nil)
			window.setFrameOrigin(p)
		}
		
		let scriptID = engine.run(on:queue)
		self.shared?.scriptID = scriptID
		return scriptID
	}
	
	
	public init(engine:BXScriptEngine, title:String = "")
	{
		self.engine = engine
		self.title = title
		
		super.init(window:nil)

		// Analyze the script and load the window
		
		self.prepare()
		self.loadWindow()
		
		// Listen to engine notifications
		
		self.subscribers += NotificationCenter.default.publisher(for:BXScriptEngine.willExecuteCommandNotification, object:engine).sink
		{
			[weak self] _ in self?.willExecuteCommand()
		}
		
		self.subscribers += NotificationCenter.default.publisher(for:BXScriptEngine.didEndNotification, object:engine).sink
		{
			[weak self] _ in self?.close()
		}
	}
	
	
	required init?(coder:NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}


	override public func loadWindow()
	{
		// Create the view

		let view = BXScriptControllerView(controller:self)
		let hostview = NSHostingView(rootView:view)
		let size = hostview.intrinsicContentSize

		// Create window

		let frame = CGRect(origin:.zero, size:size)
		let style:NSWindow.StyleMask = [.hudWindow,.nonactivatingPanel,.fullSizeContentView]
		let window = BXScriptControllerPanel(contentRect:frame, styleMask:style, backing:.buffered, defer:true)
		window.titlebarAppearsTransparent = true
		window.isMovableByWindowBackground = true
		window.isExcludedFromWindowsMenu = true 
		window.collectionBehavior.insert(.fullScreenAuxiliary)
		window.isFloatingPanel = true
		window.becomesKeyOnlyIfNeeded = true
		window.hasShadow = true
		
		window.contentView = hostview
		window.delegate = self
		
		self.window = window
	}
	
	
	private func prepare()
	{
		// Gather all steps, build the label array, and the lookup table for their command indexes
		
		for (i,command) in engine.scriptCommands.enumerated()
		{
			if let step = command as? BXScriptCommand_step
			{
				self.commandIndexes += i
				self.labels += step.label
				self.stepCount += 1
			}
			
			self.stepIndexes += stepCount-1
		}
	}

	// Stop the script when the controller window is closed
	
	public func windowWillClose(_ notification:Notification)
	{
		self.engine.cancel()
		Self.shared = nil
	}
	
	
//----------------------------------------------------------------------------------------------------------------------
	
	
	// MARK: - Actions
	
	public func willExecuteCommand()
	{
		self.stepIndex = stepIndexes[engine.commandIndex]
	}
	
	
	public func repeatCurrentStep()
	{
		engine.cancelAllCommands()
		engine.commandIndex = commandIndexes[stepIndex]
		engine.executeNextCommand()
	}
	
	
	public func abort()
	{
		engine.cancel()
		self.close()
		Self.shared = nil
	}
	
	
//----------------------------------------------------------------------------------------------------------------------
	
	
	// MARK: - Progress
	
	
	public var progressFraction:Float
	{
		Float(stepIndex+1) / Float(stepCount)
	}
	
	
	public var currentStepName:String
	{
		guard stepIndex>=0 && stepIndex<stepCount else { return "" }
		return self.labels[stepIndex]
	}


	public var currentStepNumber:String
	{
		"\(stepIndex+1)/\(stepCount)"
	}


//----------------------------------------------------------------------------------------------------------------------
	
	
	// MARK: - Auto-Move
	
	/// This function automatically moves the controller window if it covers a critical region (specified in screen coordinates).
	///
	/// Script authors can set this critical region to make sure that parts of the UI that must be visible are not covered by the controller window.
	/// The window is automatically moved in a way that the critical region no longer overlaps the window frame.
	
	public func setCriticalRegion(_ rect:CGRect)
	{
		self.criticalRegion = rect
		
		guard let window = self.window else { return }
		guard let screen = window.screen else { return }
		
		let screenFrame = screen.frame
		let windowFrame = window.frame
		let criticalFrame = criticalRegion.insetBy(dx:-32, dy:-32)
		let windowPos = windowFrame.center
		
		// We only need to do something if the window actually overlaps the critical region
		
		guard windowFrame.intersects(criticalFrame) else { return }
		
		// Window in top half of screen => try to move down
		
		if windowPos.y >= screenFrame.midY
		{
			let dy = -abs(windowFrame.maxY - criticalFrame.minY)
			let newFrame = windowFrame.offsetBy(dx:0, dy:dy)

			if screenFrame.contains(newFrame)
			{
				window.setFrame(newFrame, display:true, animate:true)
				return
			}
		}

		// Window in bottom half of screen => try to move up
		
		if windowPos.y < screenFrame.midY
		{
			let dy = abs(windowFrame.minY - criticalFrame.maxY)
			let newFrame = windowFrame.offsetBy(dx:0, dy:dy)

			if screenFrame.contains(newFrame)
			{
				window.setFrame(newFrame, display:true, animate:true)
				return
			}
		}

		// Window in left half of screen => try to move right
		
		if windowPos.x < screenFrame.midX
		{
			let dx = abs(windowFrame.minX - criticalFrame.maxX)
			let newFrame = windowFrame.offsetBy(dx:dx, dy:0)

			if screenFrame.contains(newFrame)
			{
				window.setFrame(newFrame, display:true, animate:true)
				return
			}
		}

		// Window in right half of screen => try to move left
		
		if windowPos.x >= screenFrame.midX
		{
			let dx = -abs(windowFrame.maxX - criticalFrame.minX)
			let newFrame = windowFrame.offsetBy(dx:dx, dy:0)

			if screenFrame.contains(newFrame)
			{
				window.setFrame(newFrame, display:true, animate:true)
				return
			}
		}
		
		// Oops, couldn't find any place to move window, so leave it were it is
	}
	
	private var criticalRegion = CGRect.zero
}


//----------------------------------------------------------------------------------------------------------------------


extension NSView
{
	func screenRect(for viewRect:CGRect) -> CGRect
	{
		guard let window = self.window else { return .zero }
		let windowRect = self.convert(viewRect, to:nil)
		let screenRect = window.convertToScreen(windowRect)
		return screenRect
	}
}


//----------------------------------------------------------------------------------------------------------------------
