//**********************************************************************************************************************
//
//  BXScriptCommand+displayMessageIcon.swift
//	Adds a display-message command to BXScriptCommand
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit
import SwiftUI


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_displayMessageIcon
{
	/// Creates a command that displays an icon next to the text message in the specified window.

	public static func displayMessageIcon(_ icon:NSImage? = nil, in window:NSWindow?, position:BXScriptCommand_displayMessageIcon.Position = .left) -> BXScriptCommand
	{
		BXScriptCommand_displayMessageIcon(icon:icon, window:window, position:position)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command displays a text message at the bottom of a window.

public struct BXScriptCommand_displayMessageIcon : BXScriptCommand, BXScriptCommandCancellable
{
	var icon:NSImage? = nil
	var window:NSWindow? = nil
	var position:Position = .left
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	public enum Position
	{
		case left
		case right
	}
	
	
//----------------------------------------------------------------------------------------------------------------------


	public func execute()
	{
		self.queue.async
		{
			DispatchQueue.main.asyncIfNeeded
			{
				if let icon = icon
				{
					self.setIcon(icon)
				}
				else
				{
					self.removeIcon()
				}

				self.completionHandler?()
			}
		}
	}
	
	
	public func cancel()
	{
		self.removeIcon()
	}
	
	
//----------------------------------------------------------------------------------------------------------------------


	private func setIcon(_ icon:NSImage)
	{
		guard let view = window?.contentView else { return }
		guard let layer = view.layer else { return }
		guard let textLayer = view.sublayer(named:BXScriptCommand_displayMessage.sublayerName) as? CATextLayer else { return }

		let size = icon.size 
		let textFrame = textLayer.frame
		var iconPos:CGPoint = .zero

		var iconLayer = view.sublayer(named:Self.sublayerName)
		
		if iconLayer == nil
		{
			let sublayer = CALayer()
			sublayer.name = Self.sublayerName
			sublayer.zPosition = 1000
			layer.addSublayer(sublayer)
			iconLayer = sublayer
		}

		if position == .left
		{
			iconPos = textFrame.left
			iconPos.x -= 14 + 0.5 * size.width
		}
		else
		{
			iconPos = textFrame.right
			iconPos.x += 14 + 0.5 * size.width
		}
		

		iconLayer?.contents = icon
		iconLayer?.bounds = CGRect(origin:.zero, size:icon.size)
		iconLayer?.position = iconPos
	}
	
	
	private func removeIcon()
	{
		guard let view = window?.contentView else { return }
		view.removeSublayer(named:Self.sublayerName)
	}
	

	static let sublayerName = "\(Self.self).iconLayer"
}


//----------------------------------------------------------------------------------------------------------------------
