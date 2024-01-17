//**********************************************************************************************************************
//
//  BXScriptCommand+hiliteToolbarItem.swift
//	Adds a hiliteView command to BXScriptCommand
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit
import Accessibility


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_hiliteToolbarItem
{
	/// Creates a command that shows or hides a highlight on the view with the specified identifier. You can also supply an optional view label.

	public static func hiliteToolbarItem(withID id:String, in window:@escaping @autoclosure ()->NSWindow?, visible:Bool = true, inset:CGFloat = 0.0, cornerRadius:CGFloat = 4.0) -> BXScriptCommand
	{
		BXScriptCommand_hiliteToolbarItem(id:id, visible:visible, window:window, inset:inset, cornerRadius:cornerRadius)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command shows or hides a highlight on the view with the specified identifier. You can also supply an optional view label.

public struct BXScriptCommand_hiliteToolbarItem : BXScriptCommand, BXScriptCommandCancellable
{
	var id:String
	var visible:Bool
	var window:()->NSWindow?
	var inset:CGFloat = 0.0
	var cornerRadius:CGFloat = 0.0
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	
	public func execute()
	{
		self.queue.async
		{
			defer { self.completionHandler?() }
			
			if visible
			{
				guard let window = self.window() else { return }
				guard let view = window.toolbarItemView(withIdentifier:id) else { return }

				let frameLayer:CALayer = view.createSublayer(named:frameLayerName)
				{
					return CALayer()
				}

				guard let environment = scriptEngine?.environment else { return }
				let strokeColor:NSColor = environment[.hiliteStrokeColorKey] ?? .systemYellow
				let fillColor:NSColor = environment[.hiliteFillColorKey] ?? .systemYellow.withAlphaComponent(0.1)
				let bounds = view.bounds

				frameLayer.bounds = bounds.insetBy(dx:inset, dy:inset)
				frameLayer.position = bounds.center
				frameLayer.backgroundColor = fillColor.cgColor
				frameLayer.borderColor = strokeColor.cgColor
				frameLayer.borderWidth = 3
				frameLayer.cornerRadius = cornerRadius
				frameLayer.zPosition = 1000
		
				let critical = view.screenRect(for:frameLayer.frame)
				BXScriptWindowController.shared?.setCriticalRegion(critical)
			}
			else
			{
				self.cleanup()
			}
		}
	}

	public func cancel()
	{
		self.cleanup()
	}

	private func cleanup()
	{
		guard let window = self.window() else { return }
		guard let view = window.toolbarItemView(withIdentifier:id) else { return }
		view.removeSublayer(named:frameLayerName)
		window.contentView?.removeSublayer(named:BXScriptCommand_displayMessage.pointerLayerName)

		BXScriptWindowController.shared?.setCriticalRegion(.zero)
	}


	private let frameLayerName = "\(Self.self).frame"
}


//----------------------------------------------------------------------------------------------------------------------
