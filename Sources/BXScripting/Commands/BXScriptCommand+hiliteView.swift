//**********************************************************************************************************************
//
//  BXScriptCommand+hiliteView.swift
//	Adds a hiliteView command to BXScriptCommand
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_hiliteView
{
	/// Creates a command that shows or hides a highlight on the view with the specified identifier. You can also supply an optional view label.

	public static func hiliteView(withID id:String, in window:@escaping @autoclosure ()->NSWindow?, label:String? = nil, visible:Bool = true, inset:CGFloat = 0.0, cornerRadius:CGFloat = 4.0) -> BXScriptCommand
	{
		BXScriptCommand_hiliteView(id:id, window:window, label:label, visible:visible, inset:inset, cornerRadius:cornerRadius)
	}
	
	/// Creates a command that hides the previous highlight on the view.

	public static func unhiliteView() -> BXScriptCommand
	{
		BXScriptCommand_hiliteView(id:"", window:{nil}, label:"", visible:false, inset:0, cornerRadius:4)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command shows or hides a highlight on the view with the specified identifier. You can also supply an optional view label.

public struct BXScriptCommand_hiliteView : BXScriptCommand, BXScriptCommandCancellable
{
	var id:String
	var window:()->NSWindow?
	var label:String?
	var visible:Bool
	var inset:CGFloat = 0.0
	var cornerRadius:CGFloat = 0.0
	
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	public weak var scriptEngine:BXScriptEngine? = nil
	private static var hilitedView:NSView? = nil
	
	public func execute()
	{
		self.queue.async
		{
			defer { self.completionHandler?() }
			
			if visible
			{
				self.addHilite()
			}
			else
			{
				if id != ""
				{
					self.removeHilite()
				}
				else
				{
					self._removeHilite(for:Self.hilitedView)
				}
			}
		}
	}
	

	public func cancel()
	{
		self.removeHilite()
	}
	
	
	private func addHilite()
	{
		guard let window = self.window() else { return }
		guard let view = window.subviewWithIdentifier(id) else { return }
		guard let layer = view.layer else { return }
		Self.hilitedView = view
		
		let bounds = view.bounds
		
		let frameLayer:CALayer = view.createSublayer(named:frameLayerName)
		{
			return CALayer()
		}
		
		guard let environment = scriptEngine?.environment else { return }
		let strokeColor:NSColor = environment[.hiliteStrokeColorKey] ?? .systemYellow
		let fillColor:NSColor = environment[.hiliteFillColorKey] ?? .systemYellow.withAlphaComponent(0.1)
		
		frameLayer.bounds = bounds.insetBy(dx:inset, dy:inset)
		frameLayer.position = bounds.center
		frameLayer.autoresizingMask = [.layerWidthSizable,.layerHeightSizable]
		frameLayer.backgroundColor = fillColor.cgColor
		frameLayer.borderColor = strokeColor.cgColor
		frameLayer.borderWidth = 3
		frameLayer.cornerRadius = cornerRadius
		frameLayer.zPosition = 1000
		
		if let string = label
		{
			let textLayer = view.sublayer(named:labelLayerName) as? CATextLayer ?? CATextLayer()
			textLayer.name = labelLayerName
			layer.addSublayer(textLayer)

			let font:NSFont = environment[.fontKey] ?? NSFont.boldSystemFont(ofSize:36)
			let textColor:NSColor = environment[.hiliteTextColorKey] ?? .systemYellow
			let attributes:[NSAttributedString.Key:Any] = [ .font:font, .foregroundColor:textColor.cgColor ]
			let text = NSAttributedString(string:string, attributes:attributes)
			
			textLayer.string = text
			textLayer.foregroundColor = textColor.cgColor
			textLayer.alignmentMode = .center
			textLayer.bounds = CGRect(origin:.zero, size:text.size())
			textLayer.position = bounds.center
			textLayer.zPosition = 1000
		}
		
		let critical = view.screenRect(for:frameLayer.frame)
		BXScriptWindowController.shared?.addCriticalRegion(critical)
	}


	private func removeHilite()
	{
		guard let window = self.window() else { return }
		guard let view = window.subviewWithIdentifier(id) else { return }
		self._removeHilite(for:view)
	}


	private func _removeHilite(for view:NSView?)
	{
		guard let view = view else { return }
		guard let window = view.window else { return }

		if let backgroundLayer = view.sublayer(named:frameLayerName)
		{
			let critical = view.screenRect(for:backgroundLayer.frame)
			BXScriptWindowController.shared?.removeCriticalRegion(critical)
		}

		view.removeSublayer(named:frameLayerName)
		view.removeSublayer(named:labelLayerName)
		window.contentView?.removeSublayer(named:BXScriptCommand_displayMessage.pointerLayerName)
	}


	private let frameLayerName = "\(Self.self).frame"
	private let labelLayerName = "\(Self.self).label"
}


//----------------------------------------------------------------------------------------------------------------------
