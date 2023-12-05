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
			sublayer.autoresizingMask = [.layerMinXMargin,.layerMaxXMargin]
			sublayer.zPosition = 1000
			sublayer.isWrapped = true

			layer.addSublayer(sublayer)
			textLayer = sublayer
		}
		
		guard let environment = scriptEngine?.environment else { return }
		guard let textLayer = textLayer else { return }
		
		let font = environment[.fontKey] ?? NSFont.boldSystemFont(ofSize:24)
		let textColor:NSColor = environment[.hiliteTextColorKey] ?? .systemYellow
		var anchorPoint = CGPoint.zero
		var alignmentMode = CATextLayerAlignmentMode.center

		textLayer.string = message
		textLayer.font = font
		textLayer.foregroundColor = textColor.cgColor
		
		if position.x < bounds.width*0.33
		{
			alignmentMode = .left
			anchorPoint.x = 0.0
		}
		else if position.x < bounds.width*0.66
		{
			alignmentMode = .center
			anchorPoint.x = 0.5
		}
		else
		{
			alignmentMode = .right
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
		
		textLayer.alignmentMode = alignmentMode
		textLayer.anchorPoint = anchorPoint
		
		textLayer.position = position
		
//		textLayer.borderColor = NSColor.gray.cgColor
//		textLayer.borderWidth = 1.0
		
		textLayer.transform = CATransform3DIdentity
//		let size = textLayer.preferredFrameSize()
		let text = NSAttributedString(string:message, attributes:[.font:font])
		var size = text.size()
		size.width *= 1.5 // Not sure why this is necessary
		size.height *= 1.5
//		let size2 = Self.size(of:textLayer)
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
	static func size(of textLayer:CATextLayer) -> CGSize
	{
		var storage = NSTextStorage()
		
		if let text = textLayer.string as? NSAttributedString
		{
			storage = NSTextStorage(attributedString:text)
		}
		else if let string = textLayer.string as? String, let font = textLayer.font as? NSFont
		{
			storage = NSTextStorage(string:string, attributes:[.font:font])
		}
		
		let container = NSTextContainer(containerSize:CGSize(1e10,1e10))
		let manager = NSLayoutManager()
		
		manager.addTextContainer(container)
		storage.addLayoutManager(manager)
		container.lineFragmentPadding = 0
		manager.glyphRange(for:container)
		let rect = manager.usedRect(for:container)
		return rect.size
	}
}


//----------------------------------------------------------------------------------------------------------------------


//extension BXScriptCommand_displayMessage
//{
//	static func createAttributedString(from string:String, visibleTextColor:NSColor = .systemYellow, hiddenTextColor:NSColor = .clear) -> NSMutableAttributedString
//	{
//		let pattern = "\\[(.*?)\\]"
//		let regex = try! NSRegularExpression(pattern:pattern)
//		let nsString = string as NSString
//		
//		var rangesOfHiddenText = [NSRange]()
//		
//		// Find ranges of text within brackets
//		let matches = regex.matches(in: string, range: NSRange(location: 0, length: nsString.length))
//		
//		for match in matches.reversed()
//		{
//			rangesOfHiddenText.append(match.range(at: 1))
//			nsString.deleteCharacters(in: match.range)
//		}
//		// Create an attributed string with visible text color
//		let attributedString = NSMutableAttributedString(string: nsString as String, attributes: [.foregroundColor: visibleTextColor])
//		// Apply clear color to the text that was within brackets
//		for range in rangesOfHiddenText {
//			attributedString.addAttribute(.foregroundColor, value: hiddenTextColor, range: NSRange(location: range.location, length: range.length))
//		}
//		return attributedString
//	}
//}


//----------------------------------------------------------------------------------------------------------------------
