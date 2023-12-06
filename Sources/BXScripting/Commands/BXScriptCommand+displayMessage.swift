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

	public static func displayMessage(_ message:String, in window:NSWindow?, at position:CGPoint) -> BXScriptCommand
	{
		BXScriptCommand_displayMessage(message:message, window:window, position:position)
	}
	
	/// Creates a command that hides the text message in the specified window.

	public static func hideMessage(in window:NSWindow?) -> BXScriptCommand
	{
		BXScriptCommand_displayMessage(message:nil, window:window, position:.zero)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command displays a text message at the bottom of a window.

public struct BXScriptCommand_displayMessage : BXScriptCommand, BXScriptCommandCancellable
{
	var message:String? = nil
	var window:NSWindow? = nil
	var position:CGPoint
	
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
					self.updateTextLayer(with:message)
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
		guard let view = window?.contentView else { return }
		guard let layer = view.layer else { return }

		view.removeSublayer(named:BXScriptCommand_displayMessageIcon.sublayerName)

		let bounds = view.bounds.insetBy(dx:64, dy:64)
		var textLayer = view.sublayer(named:Self.sublayerName) as? CATextLayer
		
		if textLayer == nil
		{
			let sublayer = CATextLayer()
			sublayer.name = Self.sublayerName
			sublayer.zPosition = 1000
			sublayer.isWrapped = true
			sublayer.shadowColor = NSColor.black.cgColor
			sublayer.shadowOpacity = 1.0
			sublayer.shadowOffset = CGSize(0,-1)
			sublayer.shadowRadius = 3

			layer.addSublayer(sublayer)
			textLayer = sublayer
		}
		
		guard let environment = scriptEngine?.environment else { return }
		guard let textLayer = textLayer else { return }
		
		let font = environment[.fontKey] ?? NSFont.boldSystemFont(ofSize:24)
		let textColor:NSColor = environment[.hiliteTextColorKey] ?? .systemYellow
		var anchorPoint = CGPoint.zero
		var alignmentMode = CATextLayerAlignmentMode.center
		var autoresizingMask:CAAutoresizingMask = []
		
		textLayer.string = message
		textLayer.font = font
		textLayer.foregroundColor = textColor.cgColor
		
		if position.x < bounds.width*0.33
		{
			alignmentMode = .left
			anchorPoint.x = 0.0
			autoresizingMask.insert(.layerMaxXMargin)
		}
		else if position.x < bounds.width*0.66
		{
			alignmentMode = .center
			anchorPoint.x = 0.5
			autoresizingMask.insert(.layerMinXMargin)
			autoresizingMask.insert(.layerMaxXMargin)
		}
		else
		{
			alignmentMode = .right
			anchorPoint.x = 1.0
			autoresizingMask.insert(.layerMinXMargin)
		}

		if position.y < bounds.height*0.33
		{
			anchorPoint.y = 0.0
			autoresizingMask.insert(.layerMaxYMargin)
		}
		else if position.y < bounds.height*0.66
		{
			anchorPoint.y = 0.5
			autoresizingMask.insert(.layerMinYMargin)
			autoresizingMask.insert(.layerMaxYMargin)
		}
		else
		{
			anchorPoint.y = 1.0
			autoresizingMask.insert(.layerMinYMargin)
		}
		
		textLayer.autoresizingMask = autoresizingMask
		textLayer.alignmentMode = alignmentMode
		textLayer.anchorPoint = anchorPoint
		textLayer.position = position
		
//		textLayer.borderColor = NSColor.gray.cgColor
//		textLayer.borderWidth = 1.0
		
		textLayer.transform = CATransform3DIdentity
		let text = NSAttributedString(string:message, attributes:[.font:font])
		var size = text.size()
		size.width *= 1.5 // Not sure why this is necessary
		size.height *= 1.5
//		let size2 = Self.size(of:textLayer)
		let size3 = self.bounds(for:text, width:1e10)
		textLayer.bounds = CGRect(origin:.zero, size:size)
	}
	
	
	private func cleanup()
	{
		guard let view = window?.contentView else { return }
		view.removeSublayer(named:Self.sublayerName)
		view.removeSublayer(named:BXScriptCommand_displayMessageIcon.sublayerName)
	}
	

	static let sublayerName = "\(Self.self).textLayer"
}


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand_displayMessage
{
	public func bounds(for text:NSAttributedString, width:CGFloat) -> CGSize
	{
		let frameSetter = CTFramesetterCreateWithAttributedString(text)
		let size = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0,0), nil, CGSize(width,1e10), nil)
//		CFRelease(frameSetter)
		return size
	}
}

//extension BXScriptCommand_displayMessage
//{
//	static func size(of textLayer:CATextLayer) -> CGSize
//	{
//		var storage = NSTextStorage()
//		
//		if let text = textLayer.string as? NSAttributedString
//		{
//			storage = NSTextStorage(attributedString:text)
//		}
//		else if let string = textLayer.string as? String, let font = textLayer.font as? NSFont
//		{
//			storage = NSTextStorage(string:string, attributes:[.font:font])
//		}
//		
//		let container = NSTextContainer(containerSize:CGSize(1e10,1e10))
//		let manager = NSLayoutManager()
//		
//		manager.addTextContainer(container)
//		storage.addLayoutManager(manager)
//		container.lineFragmentPadding = 0
//		manager.glyphRange(for:container)
//		let rect = manager.usedRect(for:container)
//		return rect.size
//	}
//}


//----------------------------------------------------------------------------------------------------------------------
