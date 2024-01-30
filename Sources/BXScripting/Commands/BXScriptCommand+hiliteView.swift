//**********************************************************************************************************************
//
//  BXScriptCommand+hiliteView.swift
//	Adds a hiliteView command to BXScriptCommand
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_hiliteView
{
	/// Creates a command that shows or hides a highlight on the view with the specified identifier. You can also supply an optional view label.

	public static func hiliteView(withID id:String, method:BXIdentifierMethod = .exactMatch, in window:@escaping @autoclosure ()->NSWindow?, label:String? = nil, inset:CGFloat = 0.0, cornerRadius:CGFloat = 4.0, animated:Bool = false) -> BXScriptCommand
	{
		BXScriptCommand_hiliteView(id:id, method:method, window:window, label:label, inset:inset, cornerRadius:cornerRadius, animated:animated)
	}
	
	/// Creates a command that hides the previous highlight on the view.

	public static func unhiliteView() -> BXScriptCommand
	{
		BXScriptCommand_hiliteView(id:"", window:{nil}, label:"", inset:0, cornerRadius:0)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command shows or hides a highlight on the view with the specified identifier. You can also supply an optional view label.

public struct BXScriptCommand_hiliteView : BXScriptCommand, BXScriptCommandCancellable
{
	var id:String
	var method:BXIdentifierMethod = .exactMatch
	var window:()->NSWindow?
	var label:String?
	var inset:CGFloat = 0.0
	var cornerRadius:CGFloat = 0.0
	var animated:Bool = false
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	private static var hilitedView:NSView? = nil
	
	public func execute()
	{
		self.queue.async
		{
			defer { self.completionHandler?() }
			
			if !id.isEmpty
			{
				self.addHilite()
			}
			else
			{
				self.removeHilite(for:Self.hilitedView)
			}
		}
	}
	

	public func cancel()
	{
		self.removeHilite(for:Self.hilitedView)
	}
	
	
	private func addHilite()
	{
		guard let window = self.window() else { return }
		guard let subview = window.subviewWithIdentifier(id, method:method) else { return }
		guard let view = window.addSubviewMatchingFrame(of:subview) else { return }
		guard let layer = view.layer else { return }
		Self.hilitedView = view
		
		let bounds = view.bounds
		
		let frameLayer:CALayer = view.createSublayer(named:frameLayerName)
		{
			return CALayer()
		}
		
		guard let environment = scriptEngine?.environment else { return }
		let strokeColor:NSColor = environment[.hiliteStrokeColorKey] ?? .systemYellow
		let fillColor:NSColor = environment[.hiliteFillColorKey] ?? .systemYellow.withAlphaComponent(0.1)
		
		frameLayer.bounds = bounds.insetBy(dx:inset, dy:inset)
		frameLayer.position = bounds.center
		frameLayer.autoresizingMask = [.layerWidthSizable,.layerHeightSizable]
		frameLayer.backgroundColor = fillColor.cgColor
		frameLayer.borderColor = strokeColor.cgColor
		frameLayer.borderWidth = 3
		frameLayer.cornerRadius = cornerRadius
		frameLayer.zPosition = 1000
		
		if let string = label
		{
			let textLayer = view.sublayer(named:labelLayerName) as? CATextLayer ?? CATextLayer()
			textLayer.name = labelLayerName
			layer.addSublayer(textLayer)

			let font:NSFont = environment[.fontKey] ?? NSFont.boldSystemFont(ofSize:36)
			let textColor:NSColor = environment[.hiliteTextColorKey] ?? .systemYellow
			let attributes:[NSAttributedString.Key:Any] = [ .font:font, .foregroundColor:textColor.cgColor ]
			let text = NSAttributedString(string:string, attributes:attributes)
			
			textLayer.string = text
			textLayer.foregroundColor = textColor.cgColor
			textLayer.alignmentMode = .center
			textLayer.bounds = CGRect(origin:.zero, size:text.size())
			textLayer.position = bounds.center
			textLayer.zPosition = 1000
		}
		
		if animated { self.animate(frameLayer) }
		
		let critical = view.screenRect(for:frameLayer.frame)
		BXScriptWindowController.shared?.addCriticalRegion(critical)
	}


	private func removeHilite(for view:NSView?)
	{
		guard let view = view else { return }
		guard let window = view.window else { return }
		
		view.removeFromSuperview()
		window.contentView?.removeSublayer(named:BXScriptCommand_displayMessage.pointerLayerName)
	}


	private func animate(_ frameLayer:CALayer, duration:Double = 0.15, scaleFactor:CGFloat = 1.7)
	{
		let easeOut = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeOut)
		
		let fadeIn = CABasicAnimation(keyPath:"opacity")
        fadeIn.fromValue = 0.0
        fadeIn.toValue = 1.0
        fadeIn.duration = duration
		fadeIn.timingFunction = easeOut

		let scale = CABasicAnimation(keyPath:"transform.scale")
        scale.fromValue = scaleFactor
        scale.toValue = 1.0
        scale.duration = duration
		scale.timingFunction = easeOut

        let group = CAAnimationGroup()
        group.animations = [fadeIn, scale]
        group.duration = duration
		group.timingFunction = easeOut

        // Add the animation group to the layer
        frameLayer.add(group, forKey:"fadeAndScaleAnimation")

        // Set the final values for opacity and scale
        
        frameLayer.opacity = 1.0
        frameLayer.transform = CATransform3DIdentity
 	}


	private let frameLayerName = "\(Self.self).frame"
	private let labelLayerName = "\(Self.self).label"
}


//----------------------------------------------------------------------------------------------------------------------
