//**********************************************************************************************************************
//
//  BXScriptCommand+displayLottie.swift
//	Adds a displayLottie command to BXScriptCommand
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit
import Lottie


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_displayImage
{
	/// Creates a command that displays an Lottie animation in the specified window.

	public static func displayLottie(_ animation:LottieAnimation?, in window:@escaping @autoclosure ()->NSWindow?, at position:@escaping @autoclosure ()->CGPoint, size:@escaping @autoclosure ()->CGSize, wait:Bool = true) -> BXScriptCommand
	{
		BXScriptCommand_displayLottie(animation:animation, window:window, position:position, size:size, wait:wait)
	}
	
	/// Creates a command that hides a Lottie animation in the specified window.

	public static func hideLottie(in window:@escaping @autoclosure ()->NSWindow?) -> BXScriptCommand
	{
		BXScriptCommand_displayLottie(animation:nil, window:window, position:{.zero}, size:{.zero}, wait:false)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command displays a text message at the bottom of a window.

public struct BXScriptCommand_displayLottie : BXScriptCommand, BXScriptCommandCancellable
{
	var animation:LottieAnimation? = nil
	var window:(()->NSWindow?)? = nil
	var position:()->CGPoint
	var size:()->CGSize
	var wait:Bool
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	public func execute()
	{
		self.queue.async
		{
			DispatchQueue.main.asyncIfNeeded
			{
				if let animation = animation
				{
					self.addLottieLayer(with:animation)
				}
				else
				{
					self.removeLottieLayer()
				}
				
				if !wait
				{
					self.completionHandler?()
				}
			}
		}
	}
	
	public func cancel()
	{
		self.removeLottieLayer()
	}
	
	private func addLottieLayer(with animation:LottieAnimation)
	{
		guard let window = self.window?() else { return }
		guard let view = window.contentView else { return }
		
		let lottieLayer:LottieAnimationLayer = view.createSublayer(named:Self.lottieLayerName)
		{
			let newLayer = LottieAnimationLayer(animation:animation)
			newLayer.zPosition = 2000
//			newLayer.borderColor = NSColor.systemGreen.cgColor
//			newLayer.borderWidth = 1.0
			return newLayer
		}

//		lottieLayer.animation = animation
		lottieLayer.bounds = CGRect(origin:.zero, size:size())
		lottieLayer.position = position()
		
		let size = size()
		var transform = CATransform3DMakeScale(1,-1,1)
		transform = CATransform3DTranslate(transform,0.5*size.width,0.5*size.height,0)
		lottieLayer.transform = transform

		lottieLayer.play()
		{
			didFinish in
			
			if didFinish
			{
				self.removeLottieLayer()
			}
			
			if wait
			{
				self.completionHandler?()
			}
		}
	}
	
	private func removeLottieLayer()
	{
		guard let window = self.window?() else { return }
		guard let view = window.contentView else { return }
		view.removeSublayer(named:Self.lottieLayerName)
	}

	static let lottieLayerName = "\(Self.self).lottieLayer"
}


//----------------------------------------------------------------------------------------------------------------------
