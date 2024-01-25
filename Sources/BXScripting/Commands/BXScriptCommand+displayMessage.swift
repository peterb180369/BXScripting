//**********************************************************************************************************************
//
//  BXScriptCommand+displayMessage.swift
//	Adds a displayMessage command to BXScriptCommand
//  Copyright ©2023-2024 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import BXSwiftUtils
import BXSwiftUI
import BXUIKit
import AppKit


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_displayMessage
{
	/// Creates a command that displays a text message in the specified window.

	public static func displayMessage(_ message:@escaping @autoclosure ()->String, textAlignment:CATextLayerAlignmentMode = .center, in view:@escaping @autoclosure ()->NSView?, anchor:MessageLayerAnchor = .center, inset:CGFloat = 0.0, backgroundWithPadding:NSEdgeInsets? = NSEdgeInsets(top:12, left:32, bottom:12, right:32), cornerRadius:CGFloat = 12.0, pointerWithLength:CGFloat? = nil) -> BXScriptCommand
	{
		let position = { view()?.position(for:anchor,inset) ?? .zero }
		return BXScriptCommand_displayMessage(message:message, textAlignment:textAlignment, view:view, window:{nil}, position:position, anchor:anchor, backgroundPadding:backgroundWithPadding, cornerRadius:cornerRadius, pointerLength:pointerWithLength)
	}

	public static func displayMessage(_ message:@escaping @autoclosure ()->String, textAlignment:CATextLayerAlignmentMode = .center, in view:@escaping @autoclosure ()->NSView?, at position:@escaping @autoclosure ()->CGPoint, anchor:MessageLayerAnchor = .center, backgroundWithPadding:NSEdgeInsets? = NSEdgeInsets(top:12, left:32, bottom:12, right:32), cornerRadius:CGFloat = 12.0, pointerWithLength:CGFloat? = nil) -> BXScriptCommand
	{
		BXScriptCommand_displayMessage(message:message, textAlignment:textAlignment, view:view, window:{nil}, position:position, anchor:anchor, backgroundPadding:backgroundWithPadding, cornerRadius:cornerRadius, pointerLength:pointerWithLength)
	}

	public static func displayMessage(_ message:@escaping @autoclosure ()->String, textAlignment:CATextLayerAlignmentMode = .center, in window:@escaping @autoclosure ()->NSWindow?, at position:@escaping @autoclosure ()->CGPoint, anchor:MessageLayerAnchor = .center, backgroundWithPadding:NSEdgeInsets? = NSEdgeInsets(top:12, left:32, bottom:12, right:32), cornerRadius:CGFloat = 12.0, pointerWithLength:CGFloat? = nil) -> BXScriptCommand
	{
		BXScriptCommand_displayMessage(message:message, textAlignment:textAlignment, view:{nil}, window:window, position:position, anchor:anchor, backgroundPadding:backgroundWithPadding, cornerRadius:cornerRadius, pointerLength:pointerWithLength)
	}

	/// Creates a command that displays a styled text message in the specified window.
	
	public static func displayMessage(_ message:@escaping @autoclosure ()->NSAttributedString, textAlignment:CATextLayerAlignmentMode = .center, in view:@escaping @autoclosure ()->NSView?, anchor:MessageLayerAnchor = .center, inset:CGFloat = 0.0, backgroundWithPadding:NSEdgeInsets? = NSEdgeInsets(top:12, left:32, bottom:12, right:32), cornerRadius:CGFloat = 12.0, pointerWithLength:CGFloat? = nil) -> BXScriptCommand
	{
		let position = { view()?.position(for:anchor,inset) ?? .zero }
		return BXScriptCommand_displayMessage(message:message, textAlignment:textAlignment, view:view, window:{nil}, position:position, anchor:anchor, backgroundPadding:backgroundWithPadding, cornerRadius:cornerRadius, pointerLength:pointerWithLength)
	}

	public static func displayMessage(_ message:@escaping @autoclosure ()->NSAttributedString, textAlignment:CATextLayerAlignmentMode = .center, in view:@escaping @autoclosure ()->NSView?, at position:@escaping @autoclosure ()->CGPoint, anchor:MessageLayerAnchor = .center, backgroundWithPadding:NSEdgeInsets? = NSEdgeInsets(top:12, left:32, bottom:12, right:32), cornerRadius:CGFloat = 12.0, pointerWithLength:CGFloat? = nil) -> BXScriptCommand
	{
		BXScriptCommand_displayMessage(message:message, textAlignment:textAlignment, view:view, window:{nil}, position:position, anchor:anchor, backgroundPadding:backgroundWithPadding, cornerRadius:cornerRadius, pointerLength:pointerWithLength)
	}

	public static func displayMessage(_ message:@escaping @autoclosure ()->NSAttributedString, textAlignment:CATextLayerAlignmentMode = .center, in window:@escaping @autoclosure ()->NSWindow?, at position:@escaping @autoclosure ()->CGPoint, anchor:MessageLayerAnchor = .center, backgroundWithPadding:NSEdgeInsets? = NSEdgeInsets(top:12, left:32, bottom:12, right:32), cornerRadius:CGFloat = 12.0, pointerWithLength:CGFloat? = nil) -> BXScriptCommand
	{
		BXScriptCommand_displayMessage(message:message, textAlignment:textAlignment, view:{nil}, window:window, position:position, anchor:anchor, backgroundPadding:backgroundWithPadding, cornerRadius:cornerRadius, pointerLength:pointerWithLength)
	}

	/// Creates a command that displays a styled text message in the specified window.
	
	@available(macOS 12,*) public static func displayMessage(_ message:@escaping @autoclosure ()->AttributedString, textAlignment:CATextLayerAlignmentMode = .center, in view:@escaping @autoclosure ()->NSView?, anchor:MessageLayerAnchor = .center, inset:CGFloat = 0.0, backgroundWithPadding:NSEdgeInsets? = NSEdgeInsets(top:12, left:32, bottom:12, right:32), cornerRadius:CGFloat = 12.0, pointerWithLength:CGFloat? = nil) -> BXScriptCommand
	{
		let position = { view()?.position(for:anchor,inset) ?? .zero }
		return BXScriptCommand_displayMessage(message:message, textAlignment:textAlignment, view:view, window:{nil}, position:position, anchor:anchor, backgroundPadding:backgroundWithPadding, cornerRadius:cornerRadius, pointerLength:pointerWithLength)
	}

	@available(macOS 12,*) public static func displayMessage(_ message:@escaping @autoclosure ()->AttributedString, textAlignment:CATextLayerAlignmentMode = .center, in view:@escaping @autoclosure ()->NSView?, at position:@escaping @autoclosure ()->CGPoint, anchor:MessageLayerAnchor = .center, backgroundWithPadding:NSEdgeInsets? = NSEdgeInsets(top:12, left:32, bottom:12, right:32), cornerRadius:CGFloat = 12.0, pointerWithLength:CGFloat? = nil) -> BXScriptCommand
	{
		BXScriptCommand_displayMessage(message:message, textAlignment:textAlignment, view:view, window:{nil}, position:position, anchor:anchor, backgroundPadding:backgroundWithPadding, cornerRadius:cornerRadius, pointerLength:pointerWithLength)
	}

	@available(macOS 12,*) public static func displayMessage(_ message:@escaping @autoclosure ()->AttributedString, textAlignment:CATextLayerAlignmentMode = .center, in window:@escaping @autoclosure ()->NSWindow?, at position:@escaping @autoclosure ()->CGPoint, anchor:MessageLayerAnchor = .center, backgroundWithPadding:NSEdgeInsets? = NSEdgeInsets(top:12, left:32, bottom:12, right:32), cornerRadius:CGFloat = 12.0, pointerWithLength:CGFloat? = nil) -> BXScriptCommand
	{
		BXScriptCommand_displayMessage(message:message, textAlignment:textAlignment, view:{nil}, window:window, position:position, anchor:anchor, backgroundPadding:backgroundWithPadding, cornerRadius:cornerRadius, pointerLength:pointerWithLength)
	}

	/// Creates a command that hides the text message in the specified window.

	public static func hideMessage(in view:@escaping @autoclosure ()->NSView?) -> BXScriptCommand
	{
		BXScriptCommand_displayMessage(message:{nil}, view:view, window:{nil}, position:{.zero})
	}

	public static func hideMessage(in window:@escaping @autoclosure ()->NSWindow?) -> BXScriptCommand
	{
		BXScriptCommand_displayMessage(message:{nil}, view:{nil}, window:window, position:{.zero})
	}
}


//----------------------------------------------------------------------------------------------------------------------


public enum MessageLayerAnchor
{
	case topLeft
	case top
	case topRight
	case left
	case center
	case right
	case bottomLeft
	case bottom
	case bottomRight
}

extension NSView
{
	public func position(for anchor:MessageLayerAnchor,_ inset:CGFloat = 0.0) -> CGPoint
	{
		let bounds = self.bounds.insetBy(dx:inset, dy:inset)
		
		switch anchor
		{
			case .topLeft: 		return bounds.bottomRight
			case .top:			return bounds.bottom
			case .topRight:		return bounds.bottomLeft
			case .left:			return bounds.right
			case .center:		return bounds.center
			case .right:		return bounds.left
			case .bottomLeft:	return bounds.topRight
			case .bottom:		return bounds.top
			case .bottomRight:	return bounds.topLeft
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: - Command


/// This command displays a text message at the bottom of a window.

public struct BXScriptCommand_displayMessage : BXScriptCommand, BXScriptCommandCancellable
{
	// Message string
	
	var message:()->Any?
	var textAlignment:CATextLayerAlignmentMode = .center

	// Location
	
	var view:()->NSView?
	var window:()->NSWindow?
	var position:()->CGPoint
	
	// Layout
	
	var anchor:MessageLayerAnchor = .center
	var backgroundPadding:NSEdgeInsets? = NSEdgeInsets(top:12, left:32, bottom:12, right:32)
	var cornerRadius:CGFloat = 12.0
	var pointerLength:CGFloat? = nil
	
	static let textLayerName = "\(Self.self).textLayer"
	static let backgroundLayerName = "\(Self.self).backgroundLayer"
	static let shadowLayerName = "\(Self.self).shadowLayer"
	static let pointerLayerName = "\(Self.self).pointerLayer"
	
	// Execution Support
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	public class Helper
	{
		var observers:[Any] = []
	}
	
	public var helper = Helper()
	
	
	// Execute

	public func execute()
	{
		self.helper.observers.removeAll()
		
		self.helper.observers += self.targetView?.onFrameDidChange
		{
			_ in
			self.updateLayerPositons()
		}
		
		self.queue.async
		{
			DispatchQueue.main.asyncIfNeeded
			{
				self.updateLayers()
				self.completionHandler?()
			}
		}
	}
	
	
	// Cancel
	
	public func cancel()
	{
		self.cleanup()
	}
	
	private func cleanup()
	{
		guard let view = self.rootView else { return }
		
		view.removeSublayer(named:Self.textLayerName)
		view.removeSublayer(named:Self.backgroundLayerName)
		view.removeSublayer(named:Self.shadowLayerName)
		view.removeSublayer(named:Self.pointerLayerName)
		
		view.removeSublayer(named:BXScriptCommand_displayMessageIcon.sublayerName)
		view.removeSublayer(named:BXScriptCommand_hiliteMessage.hiliteLayerName)
	}
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: - Drawing


extension BXScriptCommand_displayMessage
{
	/// Builds the NSAttributedString for the message
	
	private func messageString() -> NSAttributedString?
	{
		let message = message()
		
		if #available(macOS 12,*)
		{
			if let attributedString = message as? AttributedString
			{
				return NSAttributedString(attributedString)
			}
		}
		
		if let attributedString = message as? NSAttributedString
		{
			return attributedString
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
	
	
	/// Returns the view that the message layer appear to be connected to.
	///
	/// In reality the layer will not be added to this view, because it (or one of its ancenstors) may be clipped)
	
	private var targetView:NSView?
	{
		self.view() ?? window()?.contentView
	}
	
	
	/// Returns the root view of the window.
	///
	/// This is where the layers are actually added. Here we have no danger of being clipped.
	
	private var rootView:NSView?
	{
		self.targetView?.rootView
	}
	

	/// Updates all layers for current conditions
	
	private func updateLayers()
	{
		if let message = messageString()
		{
			self.prepareForUpdates()
			self.updateLayers(with:message)
		}
		else
		{
			self.cleanup()
		}
	}
	
	
	/// Performs cleanup for any leftover states from previous commands
	
	func prepareForUpdates()
	{
		guard let view = self.rootView else { return }
		view.removeSublayer(named:BXScriptCommand_displayMessageIcon.sublayerName)	// Remove previous message icon
		view.removeSublayer(named:BXScriptCommand_hiliteMessage.hiliteLayerName) 	// Remove previous hilite
	}
	
	
	func updateLayers(with text:NSAttributedString)
	{
		guard let rootView = self.rootView else { return }

		let position = self.positionInWindow(with:text)
		let autoresizingMask:CAAutoresizingMask = [] // Self.autoresizingMask(for:bounds, position:pos)
		
		// Create and update a sublayers to display the message with optional glass background and a pointer line
		
		Self.updateTextLayer(with:text, textAlignment:textAlignment, in:rootView, position:position, /*anchorPoint:anchorPoint,*/ autoresizingMask:autoresizingMask)
		self.updateAdornmentLayers(in:rootView, position:position)
	}
	
	
	/// Creates/Updates a CATextLayer with the specified text and layout parameters
		
	static func updateTextLayer(with text:NSAttributedString, textAlignment:CATextLayerAlignmentMode, in view:NSView, position:CGPoint, autoresizingMask:CAAutoresizingMask)
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
		textLayer.alignmentMode = textAlignment
		textLayer.bounds = CGRect(origin:.zero, size:text.size())
		textLayer.autoresizingMask = autoresizingMask
		
		Self.updateTextLayer(in:view, position:position)
	}
	
	
	/// Updates the position of the textLayer. The position must be specified in window coordinates.
	
	static func updateTextLayer(in view:NSView, position:CGPoint)
	{
		guard let textLayer = view.sublayer(named:Self.textLayerName) as? CATextLayer else { return }

		textLayer.position = position
	}
	
	
	/// Updates the other layers (background, shadow, pointer) depending on the current position of the textLayer.
	
	func updateAdornmentLayers(in view:NSView, position:CGPoint)
	{
		let showsBackground = backgroundPadding != nil
		let padding = backgroundPadding ?? NSEdgeInsets()
		let lineWidth:CGFloat = 3.0
		let margin = pointerLength ?? 0.0
		let autoresizingMask:CAAutoresizingMask = [] // Self.autoresizingMask(for:bounds, position:pos)

		Self.updateBackgroundLayer(in:view, visible:showsBackground, padding:padding, cornerRadius:cornerRadius, autoresizingMask:autoresizingMask)
		Self.updateShadowLayer(in:view, autoresizingMask:autoresizingMask)
		self.updatePointerLayer(in:view, position:position, margin:margin, lineWidth:lineWidth, autoresizingMask:autoresizingMask)
	}
	
	
	func updateLayerPositons()
	{
		guard let rootView = rootView else { return }
		guard let textLayer = rootView.sublayer(named:Self.textLayerName) as? CATextLayer else { return }
		guard let text = textLayer.string as? NSAttributedString else { return }
		
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		defer { CATransaction.commit() }

		let position = self.positionInWindow(with:text)
		Self.updateTextLayer(in:rootView, position:position)
		self.updateAdornmentLayers(in:rootView, position:position)
	}
	
	/// Creates/Updates a background layer with a frosted glass look behind the CATextLayer
		
	static func updateBackgroundLayer(in view:NSView, visible:Bool, padding:NSEdgeInsets, cornerRadius:CGFloat, autoresizingMask:CAAutoresizingMask)
	{
		guard let textLayer = view.sublayer(named:Self.textLayerName) as? CATextLayer else { return }
		
		if visible
		{
			// Create a layer that blurs the stuff behind it - achieving a frosted glass look
			
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
			
			// Apply padding to textLayer bounds
			
			var bounds = textLayer.bounds
			bounds.origin.x -= padding.left
			bounds.origin.y -= padding.bottom
			bounds.size.width += padding.left + padding.right
			bounds.size.height += padding.bottom + padding.top
			
			backgroundLayer.bounds = bounds
			backgroundLayer.cornerRadius = cornerRadius
			
			// Set position. Please note the delta (if padding is asymmetric)
			
			let dx = 0.5 * (padding.right - padding.left)
			let dy = 0.5 * (padding.top - padding.bottom)
			backgroundLayer.position = textLayer.frame.center + CGPoint(dx,dy)
			
			// Optional resizing mask
			
			backgroundLayer.autoresizingMask = autoresizingMask

			// Debugging
			
//			let borderColor:NSColor = BXScriptEnvironment.shared[.hiliteStrokeColorKey] ?? .white
//			backgroundLayer.borderColor = borderColor.cgColor
//			backgroundLayer.borderWidth = lineWidth
		}
		else
		{
			// Remove the background layer
			
			view.removeSublayer(named:Self.backgroundLayerName)
		}
		
		// Update the critical regions for the BXScriptWindowController window
		
		Self.updateCriticalRegions(in:view, visible:visible)
	}
	
	
	/// Creates/Updates a CALayer that draws a shadow for the frosted glass background
		
	static func updateShadowLayer(in view:NSView, autoresizingMask:CAAutoresizingMask)
	{
		guard let backgroundLayer = view.sublayer(named:Self.backgroundLayerName) else { return }

		// Create the shadowLayer
		
		let shadowLayer:CALayer = view.createSublayer(named:Self.shadowLayerName)
		{
			let newLayer = CALayer()
			newLayer.zPosition = 980
			return newLayer
		}

		// Get geometry of backgroundLayer
		
		let bounds = backgroundLayer.bounds
		let r:CGFloat = 6.0
		let d:CGFloat = 0.75 * r
		let inner = view.isFlipped ?
			bounds.insetBy(dx:d, dy:0).offsetBy(dx:0, dy:-d) :
			bounds.insetBy(dx:d, dy:0).offsetBy(dx:0, dy:d)
		
		// Build the shadow path
		
		let path1 = CGPath(roundedRect:bounds, cornerWidth:12, cornerHeight:12, transform:nil)
		let path2 = CGPath(rect:inner, transform:nil)
		var path = path1
		
		if #available(macOS 13.0,*)
		{
			path = path1.subtracting(path2)
		}

		// Set size and position of shadowLayer
		
		shadowLayer.bounds = bounds
//		shadowLayer.cornerRadius = 12
		shadowLayer.position = backgroundLayer.position
		shadowLayer.autoresizingMask = autoresizingMask

		// Configure the shadow
		
		shadowLayer.shadowPath = path
		shadowLayer.shadowColor = NSColor.black.cgColor
		shadowLayer.shadowOpacity = 1.5
		shadowLayer.shadowRadius = r
		shadowLayer.shadowOffset = CGSize(0,view.isFlipped ? r : -r)
	}
	
	
	/// Creates/Updates a CALayer that draws a line from the glass background to the specified position
		
	func updatePointerLayer(in view:NSView, /*bounds:CGRect,*/ position:CGPoint, margin:CGFloat, lineWidth:CGFloat, autoresizingMask:CAAutoresizingMask)
	{
		// Only do this if we have a backgroundLayer and want a pointer
		
		guard let backgroundLayer = view.sublayer(named:Self.backgroundLayerName) else { return }
		guard pointerLength != nil else { return }
		
		// Build the pointerLayer
		
		let pointerLayer:CAGradientLayer = view.createSublayer(named:Self.pointerLayerName)
		{
			let newLayer = CAGradientLayer()
			newLayer.zPosition = 970
			return newLayer
		}
	
		let frame = backgroundLayer.frame
		let inner = frame.safeInsetBy(dx:margin, dy:margin)
		let outer = frame.insetBy(dx:-margin, dy:-margin)
		let (p1,p2) = Self.pointer(for:position, anchor:anchor, inner:inner, outer:outer)
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


extension BXScriptCommand_displayMessage
{
	/// Returns the position in the coordinate system of the targetView
	
	private func getPosition() -> CGPoint
	{
		guard let view = self.targetView else { return .zero }
		var p = position()
		if view.isFlipped { p.y = view.bounds.maxY - p.y }
		return p
	}
	
	
	private func positionInWindow(with text:NSAttributedString) -> CGPoint
	{
		guard let targetView = self.targetView else { return .zero }
		guard let rootView = self.rootView else { return .zero }
		
		let margin = pointerLength ?? 0.0
		let padding = backgroundPadding ?? NSEdgeInsets()
		
		// Calculate correct layer position
		
		var position = Self.adjustPosition(
			getPosition(),
			anchor: anchor,
			textSize: text.size(),
			t:margin+padding.top,
			l:margin+padding.left,
			b:margin+padding.bottom,
			r:margin+padding.right)
		
		// Convert to window coordinates
		
		position = targetView.convert(position, to:rootView)
		
		return position
	}
	
	
	/// Adjusts the position according to the specified layerAlignment, with the specified padding values.
	
	static func adjustPosition(_ position:CGPoint, anchor:MessageLayerAnchor, textSize:CGSize, t:CGFloat, l:CGFloat, b:CGFloat, r:CGFloat) -> CGPoint
	{
		var position = position

		switch anchor
		{
			case .topLeft:
			
				position.x += l + 0.5 * textSize.width
				position.y -= t + 0.5 * textSize.height

			case .top:
			
				position.y -= t + 0.5 * textSize.height

			case .topRight:
			
				position.x -= r + 0.5 * textSize.width
				position.y -= t + 0.5 * textSize.height

			case .left:
			
				position.x += l + 0.5 * textSize.width
				
			case .center:
			
				break
				
			case .right:
			
				position.x -= r + 0.5 * textSize.width
				
			case .bottomLeft:
			
				position.x += l + 0.5 * textSize.width
				position.y += b + 0.5 * textSize.height

			case .bottom:
			
				position.y += b + 0.5 * textSize.height

			case .bottomRight:
			
				position.x -= r + 0.5 * textSize.width
				position.y += b + 0.5 * textSize.height
		}

		position.x = round(position.x)
		position.y = round(position.y)
		
		return position
	}


	/// Returns the start and end point for the pointer, given a position and layerAlignment. The inner and outer rects define the length of the pointer..
	
	static func pointer(for position:CGPoint, anchor:MessageLayerAnchor, inner:CGRect, outer:CGRect) -> (CGPoint,CGPoint)
	{
		var p1 = inner.center
		var p2 = outer.center
		
		switch anchor
		{
			case .topLeft:
			
				p1 = inner.topLeft
				p2 = outer.topLeft

			case .top:
			
				p1 = inner.top
				p2 = outer.top

			case .topRight:
			
				p1 = inner.topRight
				p2 = outer.topRight

			case .left:
			
				p1 = inner.left
				p2 = outer.left
				
			case .center:
			
				p1 = inner.center
				p2 = outer.center
				
			case .right:
			
				p1 = inner.right
				p2 = outer.right
				
			case .bottomLeft:
			
				p1 = inner.bottomLeft
				p2 = outer.bottomLeft

			case .bottom:
			
				p1 = inner.bottom
				p2 = outer.bottom

			case .bottomRight:
			
				p1 = inner.bottomRight
				p2 = outer.bottomRight
		}

		return (p1,p2)
	}
	

	/// Updates the critical regions for the BXScriptWindowController window
		
	static func updateCriticalRegions(in view:NSView, visible:Bool)
	{
		guard let backgroundLayer = view.sublayer(named:Self.backgroundLayerName) else { return }
		let criticalRegion = view.screenRect(for:backgroundLayer.frame)
		
		if visible
		{
			BXScriptWindowController.shared?.addCriticalRegion(criticalRegion)
		}
		else
		{
			BXScriptWindowController.shared?.removeCriticalRegion(criticalRegion)
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------
