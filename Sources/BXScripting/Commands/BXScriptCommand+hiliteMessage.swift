//**********************************************************************************************************************
//
//  BXScriptCommand+displayMessage.swift
//	Adds a display-message command to BXScriptCommand
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_displayMessage
{
	public static func hiliteMessage(in window:@escaping @autoclosure ()->NSWindow?, color:NSColor = .systemGreen, duration:Double = 0.15) -> BXScriptCommand
	{
		BXScriptCommand_hiliteMessage(window:window, color:color, duration:duration)
	}
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: - Command


/// This command displays a text message at the bottom of a window.

public struct BXScriptCommand_hiliteMessage : BXScriptCommand, BXScriptCommandCancellable
{
	var window:()->NSWindow?
	var color:NSColor
	var duration:Double
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	public func execute()
	{
		self.queue.async
		{
			DispatchQueue.main.asyncIfNeeded
			{
				self.updateLayers()
				self.completionHandler?()
			}
		}
	}
	
	public func cancel()
	{
		self.cleanup()
	}
	
	/// Adds a color tint to the message background layer
	
	private func updateLayers()
	{
		guard let window = self.window() ?? BXScriptCommand_displayMessageWindow.standaloneWindow else { return }
		guard let view = window.contentView else { return }
		guard let textLayer = view.sublayer(named:BXScriptCommand_displayMessage.textLayerName) as? CATextLayer else { return }
		guard let backgroundLayer = view.sublayer(named:BXScriptCommand_displayMessage.backgroundLayerName) else { return }
		
		let hiliteLayer:CALayer = view.createSublayer(named:Self.hiliteLayerName)
		{
			let newLayer = CALayer()
			newLayer.zPosition = 985
			return newLayer
		}
		
		hiliteLayer.backgroundColor = color.cgColor
		hiliteLayer.bounds = backgroundLayer.bounds
		hiliteLayer.position = backgroundLayer.position
		hiliteLayer.cornerRadius = backgroundLayer.cornerRadius

        CATransaction.begin()
        let animation = CABasicAnimation(keyPath:"transform.scale.xy")
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name:.easeOut) 
        animation.repeatCount = 1
        animation.autoreverses = true
        animation.fromValue = 1.0
        animation.toValue = 1.1
        textLayer.add(animation, forKey:"scale")
        CATransaction.commit()
	}
	
	/// Removes the color tint from the message background layer
	
	private func cleanup()
	{
		guard let window = self.window() else { return }
		guard let view = window.contentView else { return }
		view.removeSublayer(named:Self.hiliteLayerName)
	}
	

	static let hiliteLayerName = "\(Self.self).hiliteLayer"
}


//----------------------------------------------------------------------------------------------------------------------
