//**********************************************************************************************************************
//
//  BXScriptCommand+displayMessageWindow.swift
//	Adds a displayMessage command to BXScriptCommand
//  Copyright ©2023-2024 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_displayMessageWindow
{
	/// Creates a command that displays a text message in the specified window.

	public static func displayMessage(_ message:@escaping @autoclosure ()->String, textAlignment:CATextLayerAlignmentMode = .center, at position:@escaping @autoclosure ()->CGPoint, anchor:BXAnchorPoint = .center, backgroundWithPadding:NSEdgeInsets? = NSEdgeInsets(top:12, left:32, bottom:12, right:32), cornerRadius:CGFloat = 12.0, pointerWithLength:CGFloat? = nil) -> BXScriptCommand
	{
		BXScriptCommand_displayMessageWindow(message:message, textAlignment:textAlignment, position:position, anchor:anchor, backgroundPadding:backgroundWithPadding, cornerRadius:cornerRadius, pointerLength:pointerWithLength)
	}

	/// Creates a command that displays a styled text message in the specified window.
	
	public static func displayMessage(_ message:@escaping @autoclosure ()->NSAttributedString, textAlignment:CATextLayerAlignmentMode = .center, at position:@escaping @autoclosure ()->CGPoint, anchor:BXAnchorPoint = .center, backgroundWithPadding:NSEdgeInsets? = NSEdgeInsets(top:12, left:32, bottom:12, right:32), cornerRadius:CGFloat = 12.0, pointerWithLength:CGFloat? = nil) -> BXScriptCommand
	{
		BXScriptCommand_displayMessageWindow(message:message, textAlignment:textAlignment, position:position, anchor:anchor, backgroundPadding:backgroundWithPadding, cornerRadius:cornerRadius, pointerLength:pointerWithLength)
	}

	/// Creates a command that displays a styled text message in the specified window.
	
	@available(macOS 12,*) public static func displayMessage(_ message:@escaping @autoclosure ()->AttributedString, textAlignment:CATextLayerAlignmentMode = .center, at position:@escaping @autoclosure ()->CGPoint, anchor:BXAnchorPoint = .center, backgroundWithPadding:NSEdgeInsets? = NSEdgeInsets(top:12, left:32, bottom:12, right:32), cornerRadius:CGFloat = 12.0, pointerWithLength:CGFloat? = nil) -> BXScriptCommand
	{
		BXScriptCommand_displayMessageWindow(message:message, textAlignment:textAlignment, position:position, anchor:anchor, backgroundPadding:backgroundWithPadding, cornerRadius:cornerRadius, pointerLength:pointerWithLength)
	}

	/// Creates a command that hides the text message in the specified window.

	public static func hideMessage() -> BXScriptCommand
	{
		BXScriptCommand_displayMessageWindow(message:{nil}, position:{.zero})
	}
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: -

/// This command displays a text message at the bottom of a window.

public struct BXScriptCommand_displayMessageWindow : BXScriptCommand, BXScriptCommandCancellable
{
	// Text
	
	var message:()->Any?
	var textAlignment:CATextLayerAlignmentMode = .center
	
	// Layout
	
	var position:()->CGPoint
	var anchor:BXAnchorPoint = .center
	var backgroundPadding:NSEdgeInsets? = NSEdgeInsets(top:12, left:72, bottom:12, right:72)
	var cornerRadius:CGFloat = 12.0
	var pointerLength:CGFloat? = nil
	
	// Execution support
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	public private(set) static var standaloneWindow:NSWindow? = nil
	
	// Execute
	
	public func execute()
	{
		self.queue.async
		{
			DispatchQueue.main.asyncIfNeeded
			{
				if let message = self.attributedString()
				{
					self.prepareForUpdates()
					self.updateLayers(with:message)
				}
				else
				{
					self.cleanup()
				}
				
				self.completionHandler?()
			}
		}
	}
	
	
	public func cancel()
	{
		self.cleanup()
	}
	
	
	private func cleanup()
	{
		if let view = Self.standaloneWindow?.contentView ?? BXScriptCommand_displayMessage.rootView
		{
			self.cleanup(in:view)
		}
	}
	
	
	private func cleanup(in view:NSView)
	{
		view.removeSublayer(named:BXScriptCommand_displayMessage.textLayerName)
		view.removeSublayer(named:BXScriptCommand_displayMessage.backgroundLayerName)
		view.removeSublayer(named:BXScriptCommand_displayMessage.shadowLayerName)
		
		view.removeSublayer(named:BXScriptCommand_displayMessageIcon.sublayerName)
		view.removeSublayer(named:BXScriptCommand_hiliteMessage.hiliteLayerName)
		
		self.closeStandaloneWindow()
	}
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: - Window

extension BXScriptCommand_displayMessageWindow
{
	/// Returns the standalone window (creating it if necessary) and moves it to the correct location
	
	func window() -> NSWindow?
	{
		guard let text = self.attributedString() else { return nil }
		let position = self.positionOnScreen(with:text)
		let size = self.windowSize(with:text)
		let rect = CGRect(center:position, size:size)

		let window = Self.standaloneWindow ?? createStandaloneWindow()
		window.setFrame(rect, display:true, animate:false)
		
		return window
	}
	
	
	/// Calculates the position of the window
	
	private func positionOnScreen(with text:NSAttributedString) -> CGPoint
	{
		let margin = pointerLength ?? 0.0
		let padding = backgroundPadding ?? NSEdgeInsets()
		
		// Calculate correct layer position
		
		let position = BXScriptCommand_displayMessage.adjustPosition(
			position(),
			anchor: anchor,
			textSize: text.size(),
			t:margin+padding.top,
			l:margin+padding.left,
			b:margin+padding.bottom,
			r:margin+padding.right)
		
		return position
	}


	/// Calculates the size of the window
	
	func windowSize(with text:NSAttributedString) -> CGSize
	{
		let padding = backgroundPadding ?? NSEdgeInsets()

		var size = text.size()
		size.width += padding.left + padding.right
		size.height += padding.top + padding.bottom
		return size
	}
	
	
	/// Creates the standalone window and configures it for a frosted glass look
	
	func createStandaloneWindow() -> NSWindow
	{
		let frame = CGRect(origin:.zero, size:CGSize(1,1))
		let style:NSWindow.StyleMask = [.borderless,.fullSizeContentView]
		let window = BXScriptControllerPanel(contentRect:frame, styleMask:style, backing:.buffered, defer:true)
		window.level = .modalPanel
		window.titlebarAppearsTransparent = true
		window.isMovableByWindowBackground = false
		window.isExcludedFromWindowsMenu = true
		window.collectionBehavior.insert(.fullScreenAuxiliary)
		window.hidesOnDeactivate = false
		window.isReleasedWhenClosed = false
		window.backgroundColor = .clear
		window.hasShadow = true

        let effectView = NSVisualEffectView.frostedGlassView()
		effectView.wantsLayer = true
        effectView.layer?.cornerRadius = cornerRadius
        effectView.layer?.masksToBounds = true
		effectView.autoresizingMask = [.width,.height]

		let rootView = NSView()
		rootView.wantsLayer = true
        rootView.layer?.cornerRadius = cornerRadius
        rootView.layer?.masksToBounds = true
		rootView.addSubview(effectView)
		
		window.contentView = rootView

		window.orderFront(nil)
		Self.standaloneWindow = window
		return window
	}
	
	
	func closeStandaloneWindow()
	{
		Self.standaloneWindow?.close()
		Self.standaloneWindow = nil
	}
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: - Rendering


extension BXScriptCommand_displayMessageWindow
{
	private func attributedString() -> NSAttributedString?
	{
		let message = message()
		
		if let message = message as? NSAttributedString
		{
			return message
		}
		
		if #available(macOS 12,*)
		{
			if let attributedString = message as? AttributedString
			{
				return NSAttributedString(attributedString)
			}
		}
				
		if let string = message as? String
		{
			guard let environment = scriptEngine?.environment else { return nil }
			let font = environment[.fontKey] ?? NSFont.boldSystemFont(ofSize:36)
			let textColor:NSColor = environment[.hiliteTextColorKey] ?? .systemYellow
			let attributes:[NSAttributedString.Key:Any] = [ .font:font, .foregroundColor:textColor.cgColor ]
			return NSAttributedString(string:string, attributes:attributes)
		}

		return nil
	}
	
	
//----------------------------------------------------------------------------------------------------------------------


	private func prepareForUpdates()
	{
		guard let view = self.window()?.contentView else { return }
		view.removeSublayer(named:BXScriptCommand_hiliteMessage.hiliteLayerName) 		// Remove previous hilite
		view.removeSublayer(named:BXScriptCommand_displayMessageIcon.sublayerName)		// Remove previous message icon
	}
	
	
	private func updateLayers(with text:NSAttributedString)
	{
		guard let window = self.window() else { return }
		guard let view = window.contentView else { return }

		// Determine correct layout properties depending on position within the view
		
		let padding = backgroundPadding ?? NSEdgeInsets()
		let position = view.bounds.center
		let showsBackground = backgroundPadding != nil
		
		// Create and update a CATextLayer to display the message
		
		BXScriptCommand_displayMessage.updateTextLayer(with:text, textAlignment:textAlignment, in:view, position:position, autoresizingMask:[])

		// Create and update various other sublayers to display a frosted glass background and an optional pointer line
		
		Self.updateBackgroundLayer(in:view, visible:showsBackground, padding:padding, cornerRadius:cornerRadius)
//		BXScriptCommand_displayMessage.updateBackgroundLayer(in:view, visible:showsBackground, padding:padding, cornerRadius:cornerRadius, autoresizingMask:[])
		BXScriptCommand_displayMessage.updatePointerLayer(in:view, position:position, anchor:anchor, pointerLength:pointerLength, lineWidth:3)
	}


//----------------------------------------------------------------------------------------------------------------------


	/// Creates/Updates a background layer with a frosted glass look behind the CATextLayer
		
	static func updateBackgroundLayer(in view:NSView, visible:Bool, padding:NSEdgeInsets, cornerRadius:CGFloat)
	{
		guard let textLayer = view.sublayer(named:BXScriptCommand_displayMessage.textLayerName) as? CATextLayer else { return }
		
		if visible
		{
			let backgroundLayer:CALayer = view.createSublayer(named:BXScriptCommand_displayMessage.backgroundLayerName)
			{
				let newLayer = CALayer()
				newLayer.zPosition = 990

				newLayer.backgroundColor = CGColor(gray:0.4, alpha:0.2)
				newLayer.borderColor = CGColor(gray:1, alpha:0.35)
				newLayer.borderWidth = 1
				
				newLayer.shadowColor = NSColor.black.cgColor
				newLayer.shadowOpacity = 1.0
				newLayer.shadowOffset = CGSize(0,-5)
				newLayer.shadowRadius = 5
				
//				if let blur = CIFilter(name:"CIGaussianBlur", parameters:[kCIInputRadiusKey:32])
//				{
//					newLayer.backgroundFilters = [blur]
//					newLayer.masksToBounds = true
//				}
//				
//				if let compositing = CIFilter(name:"CIScreenBlendMode")
//				{
//					newLayer.compositingFilter = compositing
//				}
				
				return newLayer
			}
			
			var bounds = textLayer.bounds
			bounds.origin.x -= padding.left
			bounds.origin.y -= padding.bottom
			bounds.size.width += padding.left + padding.right
			bounds.size.height += padding.bottom + padding.top
			
			let dx = 0.5 * (padding.right - padding.left)
			let dy = 0.5 * (padding.top - padding.bottom)
			
			backgroundLayer.bounds = bounds
			backgroundLayer.position = textLayer.frame.center + CGPoint(dx,dy)
			backgroundLayer.cornerRadius = cornerRadius

//			let borderColor:NSColor = BXScriptEnvironment.shared[.hiliteStrokeColorKey] ?? .white
//			backgroundLayer.borderColor = borderColor.cgColor
//			backgroundLayer.borderWidth = lineWidth

			let critical = view.screenRect(for:backgroundLayer.frame)
			BXScriptWindowController.shared?.addCriticalRegion(critical)
		}
		else
		{
			if let backgroundLayer = view.sublayer(named:BXScriptCommand_displayMessage.backgroundLayerName)
			{
				let critical = view.screenRect(for:backgroundLayer.frame)
				BXScriptWindowController.shared?.removeCriticalRegion(critical)
			}
			
			view.removeSublayer(named:BXScriptCommand_displayMessage.backgroundLayerName)
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------
