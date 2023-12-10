//**********************************************************************************************************************
//
//  BXScriptCommand+displayImage.swift
//	Adds a displayImage command to BXScriptCommand
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit
import SwiftUI


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_displayImage
{
	/// Creates a command that displays an NSImage in the specified window.

	public static func displayImage(_ image:NSImage?, in window:@escaping @autoclosure ()->NSWindow?, at position:@escaping @autoclosure ()->CGPoint, animation:BXScriptCommand_displayImage.Animation = []) -> BXScriptCommand
	{
		BXScriptCommand_displayImage(image:image, window:window, position:position, animation:animation)
	}
	
	/// Creates a command that hides a NSImage in the specified window.

	public static func hideImage(in window:@escaping @autoclosure ()->NSWindow?) -> BXScriptCommand
	{
		BXScriptCommand_displayImage(image:nil, window:window, position:{.zero}, animation:[])
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command displays a text message at the bottom of a window.

public struct BXScriptCommand_displayImage : BXScriptCommand, BXScriptCommandCancellable
{
	var image:NSImage? = nil
	var window:(()->NSWindow?)? = nil
	var position:()->CGPoint
	var animation:Animation = []
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	public struct Animation: OptionSet
	{
		public let rawValue: Int
		public init(rawValue: Int) { self.rawValue = rawValue }
		
		public static let pulse = Animation(rawValue: 1 << 0)
		public static let scale = Animation(rawValue: 1 << 1)
		public static let wiggle = Animation(rawValue: 1 << 2)
		public static let all: Animation = [.pulse,.scale,.wiggle]
	}

	public func execute()
	{
		self.queue.async
		{
			DispatchQueue.main.asyncIfNeeded
			{
				if let image = image
				{
					self.addImageLayer(with:image, position:position())
				}
				else
				{
					self.removeImageLayer()
				}
				
				self.completionHandler?()
			}
		}
	}
	
	
	public func cancel()
	{
		self.removeImageLayer()
	}
	
	
	private func addImageLayer(with image:NSImage, position:CGPoint)
	{
		guard let window = self.window?() else { return }
		guard let view = window.contentView else { return }
		guard let layer = view.layer else { return }
		
		let imageLayer = CALayer()
		imageLayer.contents = image
		imageLayer.name = sublayerName // uniqueName(for:image)
		imageLayer.position = position
		imageLayer.bounds = CGRect(origin:.zero, size:image.size)
		imageLayer.autoresizingMask = [.layerMaxXMargin,.layerMinYMargin]
		imageLayer.zPosition = 1000
		layer.addSublayer(imageLayer)
		
		if animation.contains(.pulse)
		{
			imageLayer.addPulseAnimation()
		}
		
		if animation.contains(.scale)
		{
			imageLayer.addScaleAnimation()
		}
		
		if animation.contains(.wiggle)
		{
			imageLayer.addWiggleAnimation()
		}
		
	}
	
	
	private func removeImageLayer()
	{
		guard let window = self.window?() else { return }
		guard let view = window.contentView else { return }
		view.removeSublayer(named:sublayerName)
	}
	
	
	private func uniqueName(for image:NSImage) -> String
	{
		let ptr = Unmanaged.passUnretained(image).toOpaque()
		return "\(ptr)"
	}
	
	
	private let sublayerName = "\(Self.self).imageLayer"
}


//----------------------------------------------------------------------------------------------------------------------


extension CALayer
{
	public func addPulseAnimation(duration:Double = 0.7)
	{
		let pulse = CABasicAnimation(keyPath:"opacity")

        pulse.fromValue = 1.0
        pulse.toValue = 0.5
        pulse.duration = duration
        pulse.autoreverses = true
        pulse.repeatCount = .infinity

		self.add(pulse, forKey: "opacity")
	}

	public func addScaleAnimation(duration:Double = 0.7)
	{
		let scale = CABasicAnimation(keyPath:"transform")

        scale.fromValue = CATransform3DMakeScale(1,1,1)
        scale.toValue = CATransform3DMakeScale(1.2,1.2,1.2)
        scale.duration = duration
        scale.autoreverses = true
        scale.repeatCount = .infinity

		self.add(scale, forKey: "transform")
	}

	public func addWiggleAnimation(duration:Double = 0.7)
	{
		let wiggle = CABasicAnimation(keyPath:"transform")

        wiggle.fromValue = CATransform3DMakeRotation(-0.1,0,0,1)
        wiggle.toValue = CATransform3DMakeRotation(+0.1,0,0,1)
        wiggle.duration = duration
        wiggle.autoreverses = true
        wiggle.repeatCount = .infinity

		self.add(wiggle, forKey: "transform")
	}
}


//----------------------------------------------------------------------------------------------------------------------


