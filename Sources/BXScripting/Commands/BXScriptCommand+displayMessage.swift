//**********************************************************************************************************************
//
//  BXScriptCommand+displayMessage.swift
//	Adds a display-message command to BXScriptCommand
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit
import BXSwiftUtils
import BXSwiftUI
import BXUIKit


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_displayMessage
{
	/// Creates a command that displays a text message in the specified window.

	public static func displayMessage(_ message:@escaping @autoclosure ()->String, in window:@escaping @autoclosure ()->NSWindow?, at position:@escaping @autoclosure ()->CGPoint, autoPosition:Bool = true, backgroundWithPadding:NSEdgeInsets? = NSEdgeInsets(top:12, left:32, bottom:12, right:32), cornerRadius:CGFloat = 12.0, pointerWithLength:CGFloat? = nil, alignmentMode:CATextLayerAlignmentMode = .center) -> BXScriptCommand
	{
		BXScriptCommand_displayMessage(message:message, window:window, position:position, autoPosition:autoPosition, backgroundPadding:backgroundWithPadding, cornerRadius:cornerRadius, pointerLength:pointerWithLength, alignmentMode:alignmentMode)
	}

	public static func displayMessage(_ message:@escaping @autoclosure ()->String, at position:@escaping @autoclosure ()->CGPoint, autoPosition:Bool = true, backgroundWithPadding:NSEdgeInsets? = NSEdgeInsets(top:12, left:32, bottom:12, right:32), cornerRadius:CGFloat = 12.0, pointerWithLength:CGFloat? = nil, alignmentMode:CATextLayerAlignmentMode = .center) -> BXScriptCommand
	{
		BXScriptCommand_displayMessageWindow(message:message, position:position, backgroundPadding:backgroundWithPadding, cornerRadius:cornerRadius, alignmentMode:alignmentMode)
	}

	/// Creates a command that displays a styled text message in the specified window.
	
	public static func displayMessage(_ message:@escaping @autoclosure ()->NSAttributedString, in window:@escaping @autoclosure ()->NSWindow?, at position:@escaping @autoclosure ()->CGPoint, autoPosition:Bool = true, backgroundWithPadding:NSEdgeInsets? = NSEdgeInsets(top:12, left:32, bottom:12, right:32), cornerRadius:CGFloat = 12.0, pointerWithLength:CGFloat? = nil, alignmentMode:CATextLayerAlignmentMode = .center) -> BXScriptCommand
	{
		BXScriptCommand_displayMessage(message:message, window:window, position:position, autoPosition:autoPosition, backgroundPadding:backgroundWithPadding, cornerRadius:cornerRadius, pointerLength:pointerWithLength, alignmentMode:alignmentMode)
	}

	public static func displayMessage(_ message:@escaping @autoclosure ()->NSAttributedString, at position:@escaping @autoclosure ()->CGPoint, autoPosition:Bool = true, backgroundWithPadding:NSEdgeInsets? = NSEdgeInsets(top:12, left:32, bottom:12, right:32), cornerRadius:CGFloat = 12.0, pointerWithLength:CGFloat? = nil, alignmentMode:CATextLayerAlignmentMode = .center) -> BXScriptCommand
	{
		BXScriptCommand_displayMessageWindow(message:message, position:position, backgroundPadding:backgroundWithPadding, cornerRadius:cornerRadius, alignmentMode:alignmentMode)
	}

	/// Creates a command that displays a styled text message in the specified window.
	
	@available(macOS 12,*) public static func displayMessage(_ message:@escaping @autoclosure ()->AttributedString, in window:@escaping @autoclosure ()->NSWindow?, at position:@escaping @autoclosure ()->CGPoint, autoPosition:Bool = true, backgroundWithPadding:NSEdgeInsets? = NSEdgeInsets(top:12, left:32, bottom:12, right:32), cornerRadius:CGFloat = 12.0, pointerWithLength:CGFloat? = nil, alignmentMode:CATextLayerAlignmentMode = .center) -> BXScriptCommand
	{
		BXScriptCommand_displayMessage(message:message, window:window, position:position, autoPosition:autoPosition, backgroundPadding:backgroundWithPadding, cornerRadius:cornerRadius, pointerLength:pointerWithLength, alignmentMode:alignmentMode)
	}

	@available(macOS 12,*) public static func displayMessage(_ message:@escaping @autoclosure ()->AttributedString, at position:@escaping @autoclosure ()->CGPoint, autoPosition:Bool = true, backgroundWithPadding:NSEdgeInsets? = NSEdgeInsets(top:12, left:32, bottom:12, right:32), cornerRadius:CGFloat = 12.0, pointerWithLength:CGFloat? = nil, alignmentMode:CATextLayerAlignmentMode = .center) -> BXScriptCommand
	{
		BXScriptCommand_displayMessageWindow(message:message, position:position, backgroundPadding:backgroundWithPadding, cornerRadius:cornerRadius, alignmentMode:alignmentMode)
	}

	/// Creates a command that hides the text message in the specified window.

	public static func hideMessage(in window:@escaping @autoclosure ()->NSWindow?) -> BXScriptCommand
	{
		BXScriptCommand_displayMessage(message:{nil}, window:window, position:{.zero})
	}

	public static func hideMessage() -> BXScriptCommand
	{
		BXScriptCommand_displayMessageWindow(message:{nil}, position:{.zero})
	}
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: - Command


/// This command displays a text message at the bottom of a window.

public struct BXScriptCommand_displayMessage : BXScriptCommand, BXScriptCommandCancellable
{
	var message:()->Any?
	var window:()->NSWindow?
	var position:()->CGPoint
	var autoPosition:Bool = true
	var backgroundPadding:NSEdgeInsets? = NSEdgeInsets(top:12, left:72, bottom:12, right:72)
	var cornerRadius:CGFloat = 12.0
	var pointerLength:CGFloat? = nil
	var alignmentMode:CATextLayerAlignmentMode = .center
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	public func execute()
	{
		self.queue.async
		{
			DispatchQueue.main.asyncIfNeeded
			{
				var message = message()
				
				if let string = message as? String
				{
					guard let environment = scriptEngine?.environment else { return }
					let font = environment[.fontKey] ?? NSFont.boldSystemFont(ofSize:36)
					let textColor:NSColor = environment[.hiliteTextColorKey] ?? .systemYellow
					let attributes:[NSAttributedString.Key:Any] = [ .font:font, .foregroundColor:textColor.cgColor ]
					message = NSAttributedString(string:string, attributes:attributes)
				}

				if #available(macOS 12,*)
				{
					if let attributedString = message as? AttributedString
					{
						message = NSAttributedString(attributedString)
					}
				}

				if let message = message as? NSAttributedString
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
	
	
	private func prepareForUpdates()
	{
		guard let view = self.window()?.contentView else { return }
		view.removeSublayer(named:BXScriptCommand_displayMessageIcon.sublayerName) // Remove previous message icon
		view.removeSublayer(named:BXScriptCommand_hiliteMessage.hiliteLayerName) 	// Remove previous hilite
	}
	
	
	private func updateLayers(with text:NSAttributedString)
	{
		guard let window = self.window() else { return }
		guard let view = window.contentView else { return }

		// Determine correct layout properties depending on position within the view
		
		var pos = position()
		let bounds = view.bounds
		if view.isFlipped { pos.y = bounds.maxY - pos.y }
		
		let padding = backgroundPadding ?? NSEdgeInsets()
		let margin = pointerLength ?? 0.0
		let lineWidth:CGFloat = 3.0
		let anchorPoint = Self.anchorPoint(for:bounds, position:pos)
		let autoresizingMask = Self.autoresizingMask(for:bounds, position:pos)
		let size = text.size()
		let position = Self.adjustPosition(condition:autoPosition, bounds:bounds, position:pos, size:size, t:margin+padding.top, l:margin+padding.left, b:margin+padding.bottom, r:margin+padding.right)
		let showsBackground = backgroundPadding != nil
		
		// Create and update a CATextLayer to display the message
		
		self.updateTextLayer(with:text, in:view, position:position, anchorPoint:anchorPoint, autoresizingMask:autoresizingMask)

		// Create and update various other sublayers to display a frosted glass background and an optional pointer line
		
		Self.updateBackgroundLayer(in:view, visible:showsBackground, padding:padding, cornerRadius:cornerRadius, autoresizingMask:autoresizingMask)
		self.updatePointerLayer(in:view, bounds:bounds, position:position, margin:margin, lineWidth:lineWidth, autoresizingMask:autoresizingMask)
		Self.updateShadowLayer(in:view, autoresizingMask:autoresizingMask)
	}
	
	
	public func cancel()
	{
		self.cleanup()
	}
	
	
	private func cleanup()
	{
		guard let window = self.window() else { return }
		guard let view = window.contentView else { return }
		
		view.removeSublayer(named:Self.textLayerName)
		view.removeSublayer(named:Self.backgroundLayerName)
		view.removeSublayer(named:Self.shadowLayerName)
		view.removeSublayer(named:Self.pointerLayerName)
		
		view.removeSublayer(named:BXScriptCommand_displayMessageIcon.sublayerName)
		view.removeSublayer(named:BXScriptCommand_hiliteMessage.hiliteLayerName)
	}
	

	static let textLayerName = "\(Self.self).textLayer"
	static let backgroundLayerName = "\(Self.self).backgroundLayer"
	static let shadowLayerName = "\(Self.self).shadowLayer"
	static let pointerLayerName = "\(Self.self).pointerLayer"
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: - Drawing


extension BXScriptCommand_displayMessage
{
	/// Creates/Updates a CATextLayer with the specified text and layout parameters
		
	func updateTextLayer(with text:NSAttributedString, in view:NSView, position:CGPoint, anchorPoint:CGPoint, autoresizingMask:CAAutoresizingMask)
	{
		// Create a CATextLayer to display the message
		
		let textLayer:CATextLayer = view.createSublayer(named:Self.textLayerName)
		{
			let newLayer = CATextLayer()
			newLayer.zPosition = 1000
			newLayer.isWrapped = true
			newLayer.shadowColor = NSColor.black.cgColor
			newLayer.shadowOpacity = 0.5
			newLayer.shadowOffset = CGSize(0,0)
			newLayer.shadowRadius = 2
			return newLayer
		}
		

		textLayer.string = text
		textLayer.alignmentMode = alignmentMode

		textLayer.position = position
		textLayer.anchorPoint = anchorPoint
		textLayer.autoresizingMask = autoresizingMask
		textLayer.bounds = CGRect(origin:.zero, size:text.size())
		
//		textLayer.borderColor = NSColor.gray.cgColor
//		textLayer.borderWidth = 1.0
	}
	
	
	/// Creates/Updates a background layer with a frosted glass look behind the CATextLayer
		
	static func updateBackgroundLayer(in view:NSView, visible:Bool, padding:NSEdgeInsets, cornerRadius:CGFloat, autoresizingMask:CAAutoresizingMask)
	{
		guard let textLayer = view.sublayer(named:Self.textLayerName) as? CATextLayer else { return }
		
		if visible
		{
			let backgroundLayer:CALayer = view.createSublayer(named:Self.backgroundLayerName)
			{
				let newLayer = CALayer()
				newLayer.zPosition = 990

				newLayer.backgroundColor = CGColor(gray:0.4, alpha:0.9)
				newLayer.borderColor = CGColor(gray:1, alpha:0.35)
				newLayer.borderWidth = 1
				
				newLayer.shadowColor = NSColor.black.cgColor
				newLayer.shadowOpacity = 1.0
				newLayer.shadowOffset = CGSize(0,-5)
				newLayer.shadowRadius = 5
				
				if let blur = CIFilter(name:"CIGaussianBlur", parameters:[kCIInputRadiusKey:20])
				{
					newLayer.backgroundFilters = [blur]
					newLayer.masksToBounds = true
				}
				
				if let compositing = CIFilter(name:"CIScreenBlendMode")
				{
					newLayer.compositingFilter = compositing
				}
				
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
			backgroundLayer.autoresizingMask = autoresizingMask

//			let borderColor:NSColor = BXScriptEnvironment.shared[.hiliteStrokeColorKey] ?? .white
//			backgroundLayer.borderColor = borderColor.cgColor
//			backgroundLayer.borderWidth = lineWidth

			let critical = view.screenRect(for:backgroundLayer.frame)
			BXScriptWindowController.shared?.addCriticalRegion(critical)
		}
		else
		{
			if let backgroundLayer = view.sublayer(named:Self.backgroundLayerName)
			{
				let critical = view.screenRect(for:backgroundLayer.frame)
				BXScriptWindowController.shared?.removeCriticalRegion(critical)
			}
			
			view.removeSublayer(named:Self.backgroundLayerName)
		}
	}
	
	
	/// Creates/Updates a CALayer that draws a shadow for the frosted glass background
		
	static func updateShadowLayer(in view:NSView, autoresizingMask:CAAutoresizingMask)
	{
		guard let backgroundLayer = view.sublayer(named:Self.backgroundLayerName) else { return }

		let bounds = backgroundLayer.bounds
		let r:CGFloat = 6.0
		let d:CGFloat = 0.75 * r
		let inner = view.isFlipped ?
			bounds.insetBy(dx:d, dy:0).offsetBy(dx:0, dy:-d) :
			bounds.insetBy(dx:d, dy:0).offsetBy(dx:0, dy:d)
		
		let shadowLayer:CALayer = view.createSublayer(named:Self.shadowLayerName)
		{
			let newLayer = CALayer()
			newLayer.zPosition = 980
			return newLayer
		}

		let path1 = CGPath(roundedRect:bounds, cornerWidth:12, cornerHeight:12, transform:nil)
		let path2 = CGPath(rect:inner, transform:nil)
		var path = path1
		
		if #available(macOS 13.0,*)
		{
			path = path1.subtracting(path2)
		}

		shadowLayer.bounds = bounds
//		shadowLayer.cornerRadius = 12
		shadowLayer.position = backgroundLayer.position
		shadowLayer.autoresizingMask = autoresizingMask

		shadowLayer.shadowPath = path
		shadowLayer.shadowColor = NSColor.black.cgColor
		shadowLayer.shadowOpacity = 1.5
		shadowLayer.shadowRadius = r
		shadowLayer.shadowOffset = CGSize(0,view.isFlipped ? r : -r)
	}
	
	
	/// Creates/Updates a CALayer that draws a line from the glass background to the specified position
		
	func updatePointerLayer(in view:NSView, bounds:CGRect, position:CGPoint, margin:CGFloat, lineWidth:CGFloat, autoresizingMask:CAAutoresizingMask)
	{
		guard pointerLength != nil else { return }
		guard let backgroundLayer = view.sublayer(named:Self.backgroundLayerName) else { return }
		
		let pointerLayer:CAGradientLayer = view.createSublayer(named:Self.pointerLayerName)
		{
			let newLayer = CAGradientLayer()
			newLayer.zPosition = 970
			return newLayer
		}
	
		let frame = backgroundLayer.frame
		let inner = frame.safeInsetBy(dx:margin, dy:margin)
		let outer = frame.insetBy(dx:-margin, dy:-margin)
		let (p1,p2) = Self.pointer(for:bounds, position:position, inner:inner, outer:outer)
		let lineLength = (p2-p1).length + lineWidth
		let dx =  p2.x - p1.x
		let dy =  p2.y - p1.y
		let angle = atan2(dy,dx)
		let hiliteColor:NSColor = BXScriptEnvironment.shared[.hiliteStrokeColorKey] ?? .white
//		let white = CGColor(gray:0.6, alpha:1)
		let color = hiliteColor.cgColor
		
		pointerLayer.bounds = CGRect(x:0, y:0, width:lineLength, height:lineWidth)
		pointerLayer.anchorPoint = CGPoint(0,0.5)
		pointerLayer.transform = CATransform3DMakeRotation(angle,0,0,1)
		pointerLayer.position = p1
//		pointerLayer.autoresizingMask = autoresizingMask
		
//		pointerLayer.backgroundColor = color
		pointerLayer.colors = [color,color]
		pointerLayer.startPoint = CGPoint(0.5,0.5)
		pointerLayer.endPoint = CGPoint(0.95,0.5)
	}
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: - Layout


/// The window is divided into 9 sectors like this:
///
///  ------------
///  |   x   |        |        |
///  ------------
///  |        |        |        |
///  ------------
///  |        |        |        |
///  ------------
///
/// The following function will automatically choose various parameters depending on which sector the specified point touches within the window bounds.


extension BXScriptCommand_displayMessage
{
	/// Returns the "best" anchorPoint for the specified position within the view bounds.
	
	static func anchorPoint(for bounds:CGRect, position:CGPoint) -> CGPoint
	{
		return CGPoint(0.5,0.5)
		
//		var anchorPoint = CGPoint.zero
//
//		if position.x < bounds.width*0.33
//		{
//			anchorPoint.x = 0.0
//		}
//		else if position.x < bounds.width*0.66
//		{
//			anchorPoint.x = 0.5
//		}
//		else
//		{
//			anchorPoint.x = 1.0
//		}
//
//		if position.y < bounds.height*0.33
//		{
//			anchorPoint.y = 0.0
//		}
//		else if position.y < bounds.height*0.66
//		{
//			anchorPoint.y = 0.5
//		}
//		else
//		{
//			anchorPoint.y = 1.0
//		}
//		
//		return anchorPoint
	}


	/// Returns the "best" autoresizingMask for the specified position within the view bounds.
	
	static func autoresizingMask(for bounds:CGRect, position:CGPoint) -> CAAutoresizingMask
	{
		var autoresizingMask:CAAutoresizingMask = []
		
		if position.x < bounds.width*0.33
		{
			autoresizingMask.insert(.layerMaxXMargin)
		}
		else if position.x < bounds.width*0.66
		{
			autoresizingMask.insert(.layerMinXMargin)
			autoresizingMask.insert(.layerMaxXMargin)
		}
		else
		{
			autoresizingMask.insert(.layerMinXMargin)
		}

		if position.y < bounds.height*0.33
		{
			autoresizingMask.insert(.layerMaxYMargin)
		}
		else if position.y < bounds.height*0.66
		{
			autoresizingMask.insert(.layerMinYMargin)
			autoresizingMask.insert(.layerMaxYMargin)
		}
		else
		{
			autoresizingMask.insert(.layerMinYMargin)
		}
		
		return autoresizingMask
	}
	
	
	/// Adjusts position within the view bounds, with the specified padding values.
	
	static func adjustPosition(condition:Bool, bounds:CGRect, position:CGPoint, size:CGSize, t:CGFloat, l:CGFloat, b:CGFloat, r:CGFloat) -> CGPoint
	{
		var position = position

		if condition
		{
			if position.x < bounds.width*0.33
			{
				position.x += l + 0.5 * size.width
			}
			else if position.x > bounds.width*0.66
			{
				position.x -= r + 0.5 * size.width
			}

			if position.y < bounds.height*0.33
			{
				position.y += b + 0.5 * size.height
			}
			else if position.y > bounds.height*0.66
			{
				position.y -= t + 0.5 * size.height
			}
		}
		
		return position
	}


	/// Returns the "best" autoresizingMask for the specified position within the view bounds.
	
	static func pointer(for bounds:CGRect, position:CGPoint, inner:CGRect, outer:CGRect) -> (CGPoint,CGPoint)
	{
		var p1 = inner.center
		var p2 = outer.center
		
		if position.x < bounds.width*0.33
		{
			if position.y > bounds.height*0.66
			{
				p1 = inner.topLeft
				p2 = outer.topLeft
			}
			else if position.y > bounds.height*0.33
			{
				p1 = inner.left
				p2 = outer.left
			}
			else
			{
				p1 = inner.bottomLeft
				p2 = outer.bottomLeft
			}
		}
		else if position.x < bounds.width*0.66
		{
			if position.y > bounds.height*0.66
			{
				p1 = inner.top
				p2 = outer.top
			}
			else if position.y > bounds.height*0.33
			{
				p1 = inner.top
				p2 = outer.top
			}
			else
			{
				p1 = inner.bottom
				p2 = outer.bottom
			}
		}
		else
		{
			if position.y > bounds.height*0.66
			{
				p1 = inner.topRight
				p2 = outer.topRight
			}
			else if position.y > bounds.height*0.33
			{
				p1 = inner.right
				p2 = outer.right
			}
			else
			{
				p1 = inner.bottomRight
				p2 = outer.bottomRight
			}
		}
		
		return (p1,p2)
	}
	
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: - Standalone Window

/// This command displays a text message at the bottom of a window.

public struct BXScriptCommand_displayMessageWindow : BXScriptCommand, BXScriptCommandCancellable
{
	var message:()->Any?
	var position:()->CGPoint
	var backgroundPadding:NSEdgeInsets? = NSEdgeInsets(top:12, left:72, bottom:12, right:72)
	var cornerRadius:CGFloat = 12.0
	var alignmentMode:CATextLayerAlignmentMode = .center
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	private static var standaloneWindow:NSWindow? = nil
	
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
	
	
//----------------------------------------------------------------------------------------------------------------------


	func window() -> NSWindow?
	{
		let center = position()
		let size = self.windowSize()
		let rect = CGRect(center:center, size:size)

		let window = Self.standaloneWindow ?? createStandaloneWindow()
		window.setFrame(rect, display:true, animate:false)
		
		return window
	}
	
	
	func createStandaloneWindow() -> NSWindow
	{
		let frame = CGRect(origin:.zero, size:CGSize(1,1))
		let style:NSWindow.StyleMask = [.borderless,.fullSizeContentView]
		let window = BXScriptControllerPanel(contentRect:frame, styleMask:style, backing:.buffered, defer:true)
		window.titlebarAppearsTransparent = true
		window.isMovableByWindowBackground = false
		window.isExcludedFromWindowsMenu = true
		window.collectionBehavior.insert(.fullScreenAuxiliary)
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
	
	
	func windowSize() -> CGSize
	{
		guard let text = self.attributedString() else { return .zero }
		let padding = backgroundPadding ?? NSEdgeInsets()

		var size = text.size()
		size.width += padding.left + padding.right
		size.height += padding.top + padding.bottom
		return size
	}
	
	
	private func attributedString() -> NSAttributedString?
	{
		let message = message()
		
		if let message = message as? NSAttributedString
		{
			return message
		}
		
		if let string = message as? String
		{
			guard let environment = scriptEngine?.environment else { return nil }
			let font = environment[.fontKey] ?? NSFont.boldSystemFont(ofSize:36)
			let textColor:NSColor = environment[.hiliteTextColorKey] ?? .systemYellow
			let attributes:[NSAttributedString.Key:Any] = [ .font:font, .foregroundColor:textColor.cgColor ]
			return NSAttributedString(string:string, attributes:attributes)
		}

		if #available(macOS 12,*)
		{
			if let attributedString = message as? AttributedString
			{
				return NSAttributedString(attributedString)
			}
		}
				
		return nil
	}
	
	
//----------------------------------------------------------------------------------------------------------------------


	private func prepareForUpdates()
	{
		guard let view = self.window()?.contentView else { return }
		view.removeSublayer(named:BXScriptCommand_displayMessageIcon.sublayerName) // Remove previous message icon
		view.removeSublayer(named:BXScriptCommand_hiliteMessage.hiliteLayerName) 	// Remove previous hilite
	}
	
	
	private func updateLayers(with text:NSAttributedString)
	{
		guard let window = self.window() else { return }
		guard let view = window.contentView else { return }

		// Determine correct layout properties depending on position within the view
		
		var pos = position()
		let bounds = view.bounds
		if view.isFlipped { pos.y = bounds.maxY - pos.y }
		
		let padding = backgroundPadding ?? NSEdgeInsets()
		let position = bounds.center
		let showsBackground = backgroundPadding != nil
		
		// Create and update a CATextLayer to display the message
		
		self.updateTextLayer(with:text, in:view, position:position)

		// Create and update various other sublayers to display a frosted glass background and an optional pointer line
		
		Self.updateBackgroundLayer(in:view, visible:showsBackground, padding:padding, cornerRadius:cornerRadius)
//		Self.updateShadowLayer(in:view)
	}
	
	
	public func cancel()
	{
		self.cleanup()
	}
	
	
	private func cleanup()
	{
		guard let window = self.window() else { return }
		guard let view = window.contentView else { return }
		
		view.removeSublayer(named:BXScriptCommand_displayMessage.textLayerName)
		view.removeSublayer(named:BXScriptCommand_displayMessage.backgroundLayerName)
		view.removeSublayer(named:BXScriptCommand_displayMessage.shadowLayerName)
		
		view.removeSublayer(named:BXScriptCommand_displayMessageIcon.sublayerName)
		view.removeSublayer(named:BXScriptCommand_hiliteMessage.hiliteLayerName)
		
		self.closeStandaloneWindow()
	}


//----------------------------------------------------------------------------------------------------------------------


	/// Creates/Updates a CATextLayer with the specified text and layout parameters
		
	func updateTextLayer(with text:NSAttributedString, in view:NSView, position:CGPoint/*, anchorPoint:CGPoint, autoresizingMask:CAAutoresizingMask*/)
	{
		// Create a CATextLayer to display the message
		
		let textLayer:CATextLayer = view.createSublayer(named:BXScriptCommand_displayMessage.textLayerName)
		{
			let newLayer = CATextLayer()
			newLayer.zPosition = 1000
			newLayer.isWrapped = true
			newLayer.shadowColor = NSColor.black.cgColor
			newLayer.shadowOpacity = 0.5
			newLayer.shadowOffset = CGSize(0,0)
			newLayer.shadowRadius = 2
			return newLayer
		}
		
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		
			textLayer.string = text
			textLayer.alignmentMode = alignmentMode
			textLayer.position = position
			textLayer.bounds = CGRect(origin:.zero, size:text.size())
			
		CATransaction.commit()
	}
	
	
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

				newLayer.backgroundColor = CGColor(gray:0.4, alpha:0.9)
				newLayer.borderColor = CGColor(gray:1, alpha:0.35)
				newLayer.borderWidth = 1
				
				newLayer.shadowColor = NSColor.black.cgColor
				newLayer.shadowOpacity = 1.0
				newLayer.shadowOffset = CGSize(0,-5)
				newLayer.shadowRadius = 5
				
				if let blur = CIFilter(name:"CIGaussianBlur", parameters:[kCIInputRadiusKey:32])
				{
					newLayer.backgroundFilters = [blur]
					newLayer.masksToBounds = true
				}
				
				if let compositing = CIFilter(name:"CIScreenBlendMode")
				{
					newLayer.compositingFilter = compositing
				}
				
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
	
	
	/// Creates/Updates a CALayer that draws a shadow for the frosted glass background
		
	static func updateShadowLayer(in view:NSView)
	{
		guard let backgroundLayer = view.sublayer(named:BXScriptCommand_displayMessage.backgroundLayerName) else { return }

		let bounds = backgroundLayer.bounds
		let r:CGFloat = 6.0
		let d:CGFloat = 0.75 * r
		let inner = view.isFlipped ?
			bounds.insetBy(dx:d, dy:0).offsetBy(dx:0, dy:-d) :
			bounds.insetBy(dx:d, dy:0).offsetBy(dx:0, dy:d)
		
		let shadowLayer:CALayer = view.createSublayer(named:BXScriptCommand_displayMessage.shadowLayerName)
		{
			let newLayer = CALayer()
			newLayer.zPosition = 980
			return newLayer
		}

		let path1 = CGPath(roundedRect:bounds, cornerWidth:12, cornerHeight:12, transform:nil)
		let path2 = CGPath(rect:inner, transform:nil)
		var path = path1
		
		if #available(macOS 13.0,*)
		{
			path = path1.subtracting(path2)
		}

		shadowLayer.bounds = bounds
//		shadowLayer.cornerRadius = 12
		shadowLayer.position = backgroundLayer.position

		shadowLayer.shadowPath = path
		shadowLayer.shadowColor = NSColor.black.cgColor
		shadowLayer.shadowOpacity = 1.5
		shadowLayer.shadowRadius = r
		shadowLayer.shadowOffset = CGSize(0,view.isFlipped ? r : -r)
	}
}


//----------------------------------------------------------------------------------------------------------------------
