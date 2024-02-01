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

	public static func displayLottie(_ animation:LottieAnimation?, size:@escaping @autoclosure ()->CGSize, anchor:BXAnchorPoint = .center, in view:@escaping @autoclosure ()->NSView?, at position:@escaping @autoclosure ()->CGPoint, wait:Bool = true) -> BXScriptCommand
	{
		BXScriptCommand_displayLottie(animation:animation, size:size, anchor:anchor, view:view, position:position, wait:wait)
	}
	
	/// Creates a command that hides the last Lottie animation

	public static func hideLottie() -> BXScriptCommand
	{
		BXScriptCommand_displayLottie(animation:nil, size:{.zero}, view:nil, position:{.zero}, wait:false)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command displays a text message at the bottom of a window.

public struct BXScriptCommand_displayLottie : BXScriptCommand, BXScriptCommandCancellable
{
	// Params
	
	var animation:LottieAnimation? = nil
	var size:()->CGSize
	var anchor:BXAnchorPoint = .center
	var view:(()->NSView?)? = nil
	var position:()->CGPoint
	var wait:Bool
	
	// Execution support
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	// Internal
	
	private static var hostView:NSView? = nil
	
	// Execute
	
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
	
}


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand_displayLottie
{
	private func addLottieLayer(with animation:LottieAnimation)
	{
		guard let targetView = self.targetView else { return }
		guard let rootView = self.rootView else { return }
		Self.hostView = rootView
		
		let lottieLayer:LottieAnimationLayer = rootView.createSublayer(named:Self.lottieLayerName)
		{
			let newLayer = LottieAnimationLayer(animation:animation)
			newLayer.zPosition = 2000
//			newLayer.borderColor = NSColor.systemGreen.cgColor
//			newLayer.borderWidth = 1.0
			return newLayer
		}

		let pos = targetView.convert(position(), to:nil)
		let size = size()

		lottieLayer.bounds = CGRect(origin:.zero, size:size)
		lottieLayer.position = Self.adjustPosition(pos, size:size, anchor:anchor)
		
		var transform = CATransform3DMakeScale(1,-1,1)
		transform = CATransform3DTranslate(transform,0.5*size.width,0.5*size.height,0)
		lottieLayer.transform = transform

		lottieLayer.play()
		{
			didFinish in
			
			if didFinish
			{
				self.removeLottieLayer(in:rootView)
			}
			
			if wait
			{
				self.completionHandler?()
			}
		}
	}
	
	private func removeLottieLayer()
	{
		guard let view = Self.hostView else { return }
		self.removeLottieLayer(in:view)
	}

	private func removeLottieLayer(in view:NSView)
	{
		view.removeSublayer(named:Self.lottieLayerName)
	}

	static let lottieLayerName = "\(Self.self).lottieLayer"
}


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand_displayLottie
{
	/// Returns the view that the message layer appear to be connected to.
	///
	/// In reality the layer will not be added to this view, because it (or one of its ancenstors) may be clipped)
	
	private var targetView:NSView?
	{
		self.view?()
	}
	
	
	/// Returns the root view of the window.
	///
	/// This is where the layers are actually added. Here we have no danger of being clipped.
	
	private var rootView:NSView?
	{
		self.targetView?.rootView
	}
	

	/// Adjusts the position according to the specified anchor.
	
	static func adjustPosition(_ position:CGPoint, size:CGSize, anchor:BXAnchorPoint) -> CGPoint
	{
		var position = position

		switch anchor
		{
			case .topLeft:
			
				position.x += 0.5 * size.width
				position.y -= 0.5 * size.height

			case .top:
			
				position.y -= 0.5 * size.height

			case .topRight:
			
				position.x -= 0.5 * size.width
				position.y -= 0.5 * size.height

			case .left:
			
				position.x += 0.5 * size.width
				
			case .center:
			
				break
				
			case .right:
			
				position.x -= 0.5 * size.width
				
			case .bottomLeft:
			
				position.x += 0.5 * size.width
				position.y += 0.5 * size.height

			case .bottom:
			
				position.y += 0.5 * size.height

			case .bottomRight:
			
				position.x -= 0.5 * size.width
				position.y += 0.5 * size.height
		}

		position.x = round(position.x)
		position.y = round(position.y)
		
		return position
	}
}


//----------------------------------------------------------------------------------------------------------------------
