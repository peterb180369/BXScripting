//**********************************************************************************************************************
//
//  BXScriptCommand+displayMessageIcon.swift
//	Adds a display-message command to BXScriptCommand
//  Copyright ©2023-2026 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit
import SwiftUI


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_displayMessageIcon
{
	/// Creates a command that displays an icon next to the text message in the specified window.

	public static func displayMessageIcon(_ icon:NSImage? = nil, in window:@escaping @autoclosure ()->NSWindow?, position:BXScriptCommand_displayMessageIcon.Position = .left) -> BXScriptCommand
	{
		BXScriptCommand_displayMessageIcon(icon:icon, window:window, position:position)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command displays a text message at the bottom of a window.

public struct BXScriptCommand_displayMessageIcon : BXScriptCommand, BXScriptCommandCancellable
{
	var icon:NSImage? = nil
	var window:()->NSWindow?
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
		guard let window = self.window() else { return }
		guard let view = window.contentView else { return }
		guard let layer = view.layer else { return }
		guard let textLayer = view.sublayer(named:BXScriptCommand_displayMessage.textLayerName) as? CATextLayer else { return }

		var iconLayer = view.sublayer(named:Self.sublayerName)
		
		if iconLayer == nil
		{
			let sublayer = CALayer()
			sublayer.name = Self.sublayerName
			sublayer.zPosition = 1000
			layer.addSublayer(sublayer)
			iconLayer = sublayer
		}

		iconLayer?.contents = icon
		iconLayer?.bounds = CGRect(origin:.zero, size:icon.size)
		iconLayer?.position = Self.iconPosition(for:textLayer, size:icon.size, position:position)
	}
	
	
	/// Moves the icon layer back to the edge of the message text.
	///
	/// The displayMessage command calls this whenever it re-lays out the message, so that the icon follows
	/// along instead of staying behind where the message used to be. Which side the icon belongs on is derived
	/// from where it currently sits, so that no extra state has to be kept around just for this. Does nothing
	/// when no icon is displayed.
	
	static func updateIconLayer(in view:NSView)
	{
		guard let iconLayer = view.sublayer(named:Self.sublayerName) else { return }
		guard let textLayer = view.sublayer(named:BXScriptCommand_displayMessage.textLayerName) as? CATextLayer else { return }
		
		let position:Position = iconLayer.position.x < textLayer.position.x ? .left : .right
		iconLayer.position = Self.iconPosition(for:textLayer, size:iconLayer.bounds.size, position:position)
	}
	
	
	/// Returns the center of an icon of the specified size, just outside the left or right edge of the message
	
	static func iconPosition(for textLayer:CATextLayer, size:CGSize, position:Position) -> CGPoint
	{
		let textFrame = textLayer.frame
		var iconPos = position == .left ? textFrame.left : textFrame.right
		iconPos.x += position == .left ? -(6 + 0.5 * size.width) : (6 + 0.5 * size.width)
		
		return iconPos
	}
	
	
	private func removeIcon()
	{
		guard let window = self.window() else { return }
		guard let view = window.contentView else { return }
		view.removeSublayer(named:Self.sublayerName)
	}
	

	static let sublayerName = "\(Self.self).iconLayer"
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: - Builder


// The following functions provide the high-level syntax for the commands above. They simply forward to the low-level
// factory functions. Capitalized function names are necessary, because a command cannot be written with leading dot
// syntax as a statement inside a @BXScriptBuilder body - the compiler would parse consecutive lines that start with
// a dot as a single method chain.


public func DisplayMessageIcon(_ icon:NSImage? = nil, in window:@escaping @autoclosure ()->NSWindow?, position:BXScriptCommand_displayMessageIcon.Position = .left) -> BXScriptCommand
{
	.displayMessageIcon(icon, in:window(), position:position)
}


//----------------------------------------------------------------------------------------------------------------------
