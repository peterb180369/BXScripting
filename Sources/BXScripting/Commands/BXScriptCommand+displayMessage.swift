//**********************************************************************************************************************
//
//  BXScriptCommand+displayMessage.swift
//	Adds a display-message command to BXScriptCommand
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit
import Accessibility


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_displayMessage
{
	/// Creates a command that displays a text message in the specified window.

//	public static func displayMessage(_ message:String, in window:NSWindow?, at position:CGPoint, backgroundWithPadding:NSEdgeInsets? = NSEdgeInsets(top:12, left:60, bottom:12, right:60), pointerWithLength:CGFloat? = nil) -> BXScriptCommand
	public static func displayMessage(_ message:@escaping @autoclosure ()->String, in window:@escaping @autoclosure ()->NSWindow?, at position:@escaping @autoclosure ()->CGPoint, backgroundWithPadding:NSEdgeInsets? = NSEdgeInsets(top:12, left:60, bottom:12, right:60), pointerWithLength:CGFloat? = nil, alignmentMode:CATextLayerAlignmentMode = .center) -> BXScriptCommand
	{
		BXScriptCommand_displayMessage(message:message, window:window, position:position, backgroundPadding:backgroundWithPadding, pointerLength:pointerWithLength, alignmentMode:alignmentMode)
	}
	
	/// Creates a command that hides the text message in the specified window.

	public static func hideMessage(in window:@escaping @autoclosure ()->NSWindow?) -> BXScriptCommand
	{
		BXScriptCommand_displayMessage(message:nil, window:window, position:{.zero})
	}
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: -


/// This command displays a text message at the bottom of a window.

public struct BXScriptCommand_displayMessage : BXScriptCommand, BXScriptCommandCancellable
{
	var message:(()->String)? = nil
	var window:(()->NSWindow?)? = nil
	var position:()->CGPoint
	var backgroundPadding:NSEdgeInsets? = NSEdgeInsets(top:12, left:72, bottom:12, right:72)
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
				if let message = message
				{
					let window = self.window?()
					window?.contentView?.removeSublayer(named:BXScriptCommand_displayMessageIcon.sublayerName)
					self.updateTextLayer(with:message())
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
	
	
	private func updateTextLayer(with message:String)
	{
		guard let window = self.window?() else { return }
		guard let view = window.contentView else { return }

//		view.removeSublayer(named:BXScriptCommand_displayMessageIcon.sublayerName)

		// Get text and styling properties
		
		guard let environment = scriptEngine?.environment else { return }
		let font = environment[.fontKey] ?? NSFont.boldSystemFont(ofSize:36)
		let textColor:NSColor = environment[.hiliteTextColorKey] ?? .systemYellow
		let attributes:[NSAttributedString.Key:Any] = [ .font:font, .foregroundColor:textColor.cgColor ]
		let text = NSAttributedString(string:message, attributes:attributes)
		
		// Determine correct layout properties depending on position within the view
		
		let pos = position()
		let bounds = view.bounds //.insetBy(dx:64, dy:64)
		let padding = backgroundPadding ?? NSEdgeInsets()
		let margin = pointerLength ?? 0.0
		let cornerRadius:CGFloat = 12.0
		let lineWidth:CGFloat = 3.0
		let anchorPoint = self.anchorPoint(for:bounds, position:pos)
		let autoresizingMask = self.autoresizingMask(for:bounds, position:pos)
		let position = self.adjustPosition(for:bounds, position:pos, t:margin+padding.top, l:margin+padding.left, b:margin+padding.bottom, r:margin+padding.right)

		// Create and update a CATextLayer to display the message
		
		self.updateTextLayer(with:text, in:view, position:position, anchorPoint:anchorPoint, autoresizingMask:autoresizingMask)

		// Create and update various other sublayers to display a frosted glass background and an optional pointer line
		
		self.updateBackgroundLayer(in:view, padding:padding, cornerRadius:cornerRadius)
		self.updatePointerLayer(in:view, bounds:bounds, position:position, margin:margin, lineWidth:lineWidth)
		self.updateShadowLayer(in:view)
	}
	
	
	private func cleanup()
	{
		guard let window = self.window?() else { return }
		guard let view = window.contentView else { return }
		
		view.removeSublayer(named:Self.textLayerName)
		view.removeSublayer(named:Self.backgroundLayerName)
		view.removeSublayer(named:Self.shadowLayerName)
		view.removeSublayer(named:Self.pointerLayerName)
		view.removeSublayer(named:BXScriptCommand_displayMessageIcon.sublayerName)
	}
	

	static let textLayerName = "\(Self.self).textLayer"
	static let backgroundLayerName = "\(Self.self).backgroundLayer"
	static let shadowLayerName = "\(Self.self).shadowLayer"
	static let pointerLayerName = "\(Self.self).pointerLayer"
	static let hiliteLayerName = "\(Self.self).hiliteLayer"
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: -


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
		
	func updateBackgroundLayer(in view:NSView, padding:NSEdgeInsets, cornerRadius:CGFloat)
	{
		guard let textLayer = view.sublayer(named:Self.textLayerName) as? CATextLayer else { return }
		
		if backgroundPadding != nil
		{
			let backgroundLayer:CALayer = view.createSublayer(named:Self.backgroundLayerName)
			{
				let newLayer = CALayer()
				newLayer.zPosition = 999

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
			
			backgroundLayer.bounds = bounds
			backgroundLayer.position = textLayer.frame.center + .zero
			backgroundLayer.cornerRadius = cornerRadius

//			let borderColor:NSColor = BXScriptEnvironment.shared[.hiliteStrokeColorKey] ?? .white
//			backgroundLayer.borderColor = borderColor.cgColor
//			backgroundLayer.borderWidth = lineWidth
		}
		else
		{
			view.removeSublayer(named:Self.backgroundLayerName)
		}
	}
	
	
	/// Creates/Updates a CALayer that draws a shadow for the frosted glass background
		
	func updateShadowLayer(in view:NSView)
	{
		guard let backgroundLayer = view.sublayer(named:Self.backgroundLayerName) else { return }

		let shadowLayer:CALayer = view.createSublayer(named:Self.shadowLayerName)
		{
			let newLayer = CALayer()
			newLayer.zPosition = 998
			newLayer.backgroundColor = CGColor(gray:0.0, alpha:0.25)
			newLayer.shadowColor = NSColor.black.cgColor
			newLayer.shadowOpacity = 4.0
			newLayer.shadowOffset = CGSize(0,-5)
			newLayer.shadowRadius = 5

			if let compositing = CIFilter(name:"CIDarkenBlendMode")
			{
				newLayer.compositingFilter = compositing
			}
			
			return newLayer
		}

		shadowLayer.bounds = backgroundLayer.bounds
		shadowLayer.position = backgroundLayer.position
		shadowLayer.cornerRadius = 12
	}
	
	
	/// Creates/Updates a CALayer that draws a line from the glass background to the specified position
		
	func updatePointerLayer(in view:NSView, bounds:CGRect, position:CGPoint, margin:CGFloat, lineWidth:CGFloat)
	{
		guard pointerLength != nil else { return }
		guard let backgroundLayer = view.sublayer(named:Self.backgroundLayerName) else { return }
		
		let lineLayer:CALayer = view.createSublayer(named:Self.pointerLayerName)
		{
			let newLayer = CALayer()
			newLayer.zPosition = 995
			return newLayer
		}
	
		let frame = backgroundLayer.frame
		let inner = frame.safeInsetBy(dx:margin, dy:margin)
		let outer = frame.insetBy(dx:-margin, dy:-margin)
		let (p1,p2) = self.pointer(for:bounds, position:position, inner:inner, outer:outer)
		let lineLength = (p2-p1).length + lineWidth
		let dx =  p2.x - p1.x
		let dy =  p2.y - p1.y
		let angle = atan2(dy,dx)
		let color:NSColor = BXScriptEnvironment.shared[.hiliteStrokeColorKey] ?? .white

		lineLayer.backgroundColor = color.cgColor
		lineLayer.bounds = CGRect(x:0, y:0, width:lineLength, height:lineWidth)
		lineLayer.anchorPoint = CGPoint(0,0.5)
		lineLayer.transform = CATransform3DMakeRotation(angle,0,0,1)
		lineLayer.position = p1
	}
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: -


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
	
	func anchorPoint(for bounds:CGRect, position:CGPoint) -> CGPoint
	{
		var anchorPoint = CGPoint.zero

		if position.x < bounds.width*0.33
		{
			anchorPoint.x = 0.0
		}
		else if position.x < bounds.width*0.66
		{
			anchorPoint.x = 0.5
		}
		else
		{
			anchorPoint.x = 1.0
		}

		if position.y < bounds.height*0.33
		{
			anchorPoint.y = 0.0
		}
		else if position.y < bounds.height*0.66
		{
			anchorPoint.y = 0.5
		}
		else
		{
			anchorPoint.y = 1.0
		}
		
		return anchorPoint
	}


	/// Returns the "best" autoresizingMask for the specified position within the view bounds.
	
	func autoresizingMask(for bounds:CGRect, position:CGPoint) -> CAAutoresizingMask
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
	
	func adjustPosition(for bounds:CGRect, position:CGPoint, t:CGFloat, l:CGFloat, b:CGFloat, r:CGFloat) -> CGPoint
	{
		var position = position

		if position.x < bounds.width*0.33
		{
			position.x += l
		}
		else if position.x > bounds.width*0.66
		{
			position.x -= r
		}

		if position.y < bounds.height*0.33
		{
			position.y += b
		}
		else if position.y > bounds.height*0.66
		{
			position.y -= t
		}
		
		return position
	}


	/// Returns the "best" autoresizingMask for the specified position within the view bounds.
	
	func pointer(for bounds:CGRect, position:CGPoint, inner:CGRect, outer:CGRect) -> (CGPoint,CGPoint)
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
