//**********************************************************************************************************************
//
//  BXScriptCommand+hiliteView.swift
//	Adds a hiliteView command to BXScriptCommand
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit
//import Accessibility
//import Darwin


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptCommand where Self == BXScriptCommand_hiliteView
{
	/// Creates a command that shows or hides a highlight on the view with the specified identifier. You can also supply an optional view label.

	public static func hiliteView(withID id:String, visible:Bool = true, label:String? = nil, in window:@escaping @autoclosure ()->NSWindow?, inset:CGFloat = 0.0, cornerRadius:CGFloat = 4.0) -> BXScriptCommand
	{
		BXScriptCommand_hiliteView(id:id, visible:visible, label:label, window:window, inset:inset, cornerRadius:cornerRadius)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command shows or hides a highlight on the view with the specified identifier. You can also supply an optional view label.

public struct BXScriptCommand_hiliteView : BXScriptCommand, BXScriptCommandCancellable
{
	var id:String
	var visible:Bool
	var label:String?
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
				self.addHilite()
			}
			else
			{
				self.removeHilite()
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
	}


	private func removeHilite()
	{
		guard let window = self.window() else { return }
		guard let view = window.contentView?.subviewWithIdentifier(id) else { return }
		view.removeSublayer(named:frameLayerName)
		view.removeSublayer(named:labelLayerName)
		window.contentView?.removeSublayer(named:BXScriptCommand_displayMessage.pointerLayerName)
	}


	private let frameLayerName = "\(Self.self).frame"
	private let labelLayerName = "\(Self.self).label"
}


//----------------------------------------------------------------------------------------------------------------------


//class AccessibilityHelper
//{
//    
//    static func applicationElement() -> AXUIElement
//    {
////		let pid = ProcessInfo.processInfo.processIdentifier
//		let pid = getpid()
//		let application = AXUIElementCreateApplication(pid)
//		return application
//    }
//    
//    
//    static func findElement(by identifier:String, in element:AXUIElement = applicationElement()) -> AXUIElement?
//    {
//		// Get the identifier of the current element and check if it matches the one we are looking for
//		
//		var elementIdentifier:CFTypeRef? = nil
//		AXUIElementCopyAttributeValue(element, kAXIdentifierAttribute as CFString, &elementIdentifier)
//
//		if let elementIdentifier = elementIdentifier as? String, elementIdentifier == identifier
//		{
//			return element
//		}
//
//		// Otherwise get the children of the current element
//
//        var attribute:CFTypeRef? = nil
//        let result = AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &attribute)
//        guard result == .success else { return nil }
//        guard let children = attribute as? [AXUIElement] else { return nil }
//
//		// Descend recursively into all children and look for the element with the desired ID
//		
//        for child in children
//        {
//            var childIdentifier:CFTypeRef? = nil
//            AXUIElementCopyAttributeValue(child, kAXIdentifierAttribute as CFString, &childIdentifier)
//            
//            if let found = self.findElement(by:identifier, in:child)
//            {
//				return found
//            }
//        }
//        
//        return nil
//    }
//
//
//	static func parentWindow(of element: AXUIElement) -> AXUIElement?
//	{
// 		var result:AXError
//        var currentElement = element
//
//        while true
//        {
//            var parent:CFTypeRef?
//            result = AXUIElementCopyAttributeValue(currentElement, kAXParentAttribute as CFString, &parent)
//            
//			guard result == .success else { return nil }
//			guard parent == nil else { return nil }
//			let parentElement = parent as! AXUIElement
//			
//			var role:CFTypeRef?
//			result = AXUIElementCopyAttributeValue(parentElement, kAXRoleAttribute as CFString, &role)
//
//			if let role = role as? String, role == kAXWindowRole as String
//			{
//				return parentElement
//            }
//
//			currentElement = parentElement
//        }
//    }
//    
//    
//	static func getFrame(of element:AXUIElement) -> CGRect?
//    {
// 		var result:AXError
//        var type:CFTypeRef? = nil
//		
//		var origin:CGPoint = .zero
//        result = AXUIElementCopyAttributeValue(element, kAXPositionAttribute as CFString, &type)
//        guard result == .success else { return nil }
//        AXValueGetValue(type as! AXValue, AXValueType.cgPoint, &origin)
//        
//        var size = CGSize()
//        result = AXUIElementCopyAttributeValue(element, kAXSizeAttribute as CFString, &type)
//        guard result == .success else { return nil }
//		AXValueGetValue(origin as! AXValue, AXValueType.cgSize, &size)
//		
//		return CGRect(origin:origin, size:size)
//    }
//
//}


//----------------------------------------------------------------------------------------------------------------------
