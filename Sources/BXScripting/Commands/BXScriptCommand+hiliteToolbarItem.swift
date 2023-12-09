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

	public static func hiliteToolbarItem(withID id:String, visible:Bool = true, in window:NSWindow?) -> BXScriptCommand
	{
		BXScriptCommand_hiliteToolbarItem(id:id, visible:visible, window:window)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command shows or hides a highlight on the view with the specified identifier. You can also supply an optional view label.

public struct BXScriptCommand_hiliteToolbarItem : BXScriptCommand, BXScriptCommandCancellable
{
	var id:String
	var visible:Bool
	var window:NSWindow? = nil
	
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
				guard let view = window?.toolbarItemView(withIdentifier:id) else { return }
				guard let layer = view.layer else { return }
				let bounds = view.bounds
			
				let frameLayer = view.sublayer(named:frameLayerName) ?? CALayer()
				frameLayer.name = frameLayerName
				layer.addSublayer(frameLayer)
					
				guard let environment = scriptEngine?.environment else { return }
				let strokeColor:NSColor = environment[.hiliteStrokeColorKey] ?? .systemYellow
				let fillColor:NSColor = environment[.hiliteFillColorKey] ?? .systemYellow.withAlphaComponent(0.1)

				frameLayer.bounds = bounds
				frameLayer.position = bounds.center
				frameLayer.borderColor = strokeColor.cgColor
				frameLayer.backgroundColor = fillColor.cgColor
				frameLayer.borderWidth = 3
				frameLayer.zPosition = 1000
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
		guard let view = window?.toolbarItemView(withIdentifier:id) else { return }
		view.removeSublayer(named:frameLayerName)
	}


	private let frameLayerName = "\(Self.self).frame"
}


//----------------------------------------------------------------------------------------------------------------------
