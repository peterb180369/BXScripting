//**********************************************************************************************************************
//
//  BXScriptWindowController.swift
//	Displays a small floating window with a controller for the BXScriptEngine
//  Copyright ©2023-2024 Peter Baumgartner. All rights reserved.
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
	
	/// The root BXScriptEngine that is being controlled by this window

	private var rootEngine:BXScriptEngine

	/// The BXScriptEngine that is currently active. In case of sub-engines (run command) this can be different from the rootEngine.

	internal var currentEngine:BXScriptEngine? = nil

	/// The controller window title
	
	private var title:String = ""
	
	/// The id of the running script. Can be used for cancelling
	
	private var scriptID:String = ""
	
	/// The number of the current step (useful for progress info)

	@Published public var stepIndex = 0
	
	/// The total number of steps (useful for progress info)

	public private(set) var stepCount = 0
	
	/// A reference to the current step in the script. If the script contains run commands (sub-scripts) then all steps in sub-script are included here.
	
	var currentStep:BXScriptCommand_step? = nil

	/// Set to true if the controller window should be automatically moved to make sure it doesn't overlap a critical region
	
	public static var autoMoveWindow = false
	
	/// Subscribers
	
	private var subscribers:[Any] = []
	

//----------------------------------------------------------------------------------------------------------------------


	/// Set to true if spoken audio should be muted

	public var muteAudio:Bool
	{
		set
		{
			self.objectWillChange.send()
			UserDefaults.standard.set(newValue, forKey:"BXScriptWindowController.muteAudio")
			NotificationCenter.default.post(name:Self.muteAudioNotification, object:newValue)
			
			// Automatically turn on subtitle when audio is being muted
			
			if newValue && BXSubtitleWindowController.shared.displaySubtitles == false
			{
				BXSubtitleWindowController.shared.displaySubtitles = true
			}
		}

		get
		{
			UserDefaults.standard.bool(forKey:"BXScriptWindowController.muteAudio")
		}
	}
	
	public static let muteAudioNotification = Notification.Name("BXScriptWindowController.muteAudio")


	/// Passes on the subtitle to BXSubtitleWindowController
	
	public var subtitle:String?
	{
		set { BXSubtitleWindowController.shared.text = newValue }
		get { BXSubtitleWindowController.shared.text }
	}


//----------------------------------------------------------------------------------------------------------------------


	// MARK: - Lifecycle
	
	
	@discardableResult public class func run(_ engine:BXScriptEngine, title:String = "", on queue:DispatchQueue = .main) -> String
	{
		// Abort any script that may currently be running

		if let shared = shared
		{
			shared.abort()
		}
		
		// Create a new controller
		
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
		self.rootEngine = engine
		self.currentEngine = engine
		self.title = title
		
		super.init(window:nil)

		// Analyze the script and load the window
		
		self.prepare(engine.scriptCommands)
		self.loadWindow()
		
		// Listen to engine notifications
		
		self.subscribers += NotificationCenter.default.publisher(for:BXScriptEngine.willExecuteCommandNotification, object:nil).sink
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
			.environmentObject(BXSubtitleWindowController.shared)
			
		let hostview = NSHostingView(rootView:view)
		let size = hostview.intrinsicContentSize

        hostview.wantsLayer = true
        hostview.layer?.cornerRadius = 8  // Adjust the corner radius as needed
        hostview.layer?.masksToBounds = true

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
		window.backgroundColor = .clear
		
		window.contentView = hostview
		window.delegate = self
		
		self.window = window
	}
	
	
	private func prepare(_ commands:BXScriptCommands)
	{
		// Gather all steps, build the label array, and the lookup table for their command indexes
		
		for (i,command) in commands.enumerated()
		{
			if let step = command as? BXScriptCommand_step
			{
				step.helper.globalStepIndex = stepCount
				step.helper.localCommandIndex = i
				self.stepCount += 1
			}
			else if let run = command as? BXScriptCommand_run
			{
				self.prepare(run.scriptCommands)
			}
		}
	}

	// Stop the script when the controller window is closed
	
	public func windowWillClose(_ notification:Notification)
	{
		self.rootEngine.cancel()
		Self.shared = nil
	}
	
	
//----------------------------------------------------------------------------------------------------------------------
	
	
	// MARK: - Actions
	
	public func willExecuteCommand()
	{
		guard let currentStep = currentStep else { return }
		self.stepIndex = currentStep.helper.globalStepIndex
	}
	
	
	public func repeatCurrentStep()
	{
		guard let engine = currentEngine else { return }
		guard let currentStep = currentStep else { return }
		
		engine.cancelAllCommands()
		engine.commandIndex = currentStep.helper.localCommandIndex
		engine.executeNextCommand()
	}
	
	
	public func abort()
	{
		self.rootEngine.cancel()
		self.close()
		Self.shared = nil
	}
	
	@Published public var isPaused = false
	{
		didSet { self.currentEngine?.isPaused = isPaused }
	}


//----------------------------------------------------------------------------------------------------------------------
	
	
	// MARK: - Progress
	
	
	public var progressFraction:Float
	{
		Float(stepIndex+1) / Float(stepCount)
	}
	
	
	public var currentStepName:String
	{
		currentStep?.label ?? ""
	}


	public var currentStepNumber:String
	{
		"\(stepIndex+1)/\(stepCount)"
	}


//----------------------------------------------------------------------------------------------------------------------
	
	
	// MARK: - Auto-Move
	
	public func addCriticalRegion(_ rect:CGRect)
	{
		self.criticalRegions += rect
		
		for region in criticalRegions
		{
			moveControllerWindowIfNecessary(with:region)
		}
	}
	
	public func removeCriticalRegion(_ rect:CGRect)
	{
		self.criticalRegions.removeAll
		{
			$0 == rect
		}
	}
	
	public func clearCriticalRegions()
	{
		self.criticalRegions = []
	}


	private var criticalRegions:[CGRect] = []
	
	/// This function automatically moves the controller window if it covers a critical region (specified in screen coordinates).
	///
	/// Script authors can set this critical region to make sure that parts of the UI that must be visible are not covered by the controller window.
	/// The window is automatically moved in a way that the critical region no longer overlaps the window frame.
	
	private func moveControllerWindowIfNecessary(with criticalRect:CGRect)
	{
		guard Self.autoMoveWindow else { return }
		guard let window = self.window else { return }
		guard let screen = window.screen else { return }
		
		let screenFrame = screen.frame
		let windowFrame = window.frame
		let criticalFrame = criticalRect.insetBy(dx:-32, dy:-32)
		let windowPos = windowFrame.center
		
		// We only need to do something if the window actually overlaps the critical region
		
		guard windowFrame.intersects(criticalFrame) else { return }
		
		// If we window overlaps the critical region, then try to move vertically, whichever direction is closer
		
		if windowFrame.intersects(criticalFrame)
		{
			let dy1 = -abs(windowFrame.maxY - criticalFrame.minY)
			let dy2 = abs(windowFrame.minY - criticalFrame.maxY)
			
			var newFrame = windowFrame
			
			if abs(dy1) < abs(dy2)
			{
				newFrame = windowFrame.offsetBy(dx:0, dy:dy1)
			}
			else
			{
				newFrame = windowFrame.offsetBy(dx:0, dy:dy2)
			}

			if screenFrame.contains(newFrame)
			{
				window.setFrame(newFrame, display:true, animate:true)
				return
			}
		}
		
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
		
		if true // windowPos.y < screenFrame.midY
		{
			let dy = abs(windowFrame.minY - criticalFrame.maxY)
			let newFrame = windowFrame.offsetBy(dx:0, dy:dy)

			if screenFrame.contains(newFrame)
			{
				window.setFrame(newFrame, display:true, animate:true)
				return
			}
		}

		// If we window overlaps the critical region, then try to move horizontally, whichever direction is closer
		
		if windowFrame.intersects(criticalFrame)
		{
			let dx1 = abs(windowFrame.minX - criticalFrame.maxX)
			let dx2 = -abs(windowFrame.maxX - criticalFrame.minX)
			
			var newFrame = windowFrame
			
			if abs(dx1) < abs(dx2)
			{
				newFrame = windowFrame.offsetBy(dx:dx1, dy:0)
			}
			else
			{
				newFrame = windowFrame.offsetBy(dx:dx2, dy:0)
			}

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
		
		if true // windowPos.x >= screenFrame.midX
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
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: -

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
