//**********************************************************************************************************************
//
//  BXAccessibilityHelper.swift
//	A helper class that can find accessibility items via identifier
//  Copyright ©2024 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Accessibility
import AppKit


//----------------------------------------------------------------------------------------------------------------------


/// This helper class is used to find UI elements by accessibility identifier and obtain its frame (in screen coordinates)

public class BXAccessibilityHelper
{
	/// Returns the root AXUIElement in an application
	
    public static func applicationElement() -> AXUIElement
    {
		let pid = getpid()
		let application = AXUIElementCreateApplication(pid)
		return application
    }
    
    
    /// Returns the element with the specified accessibility identifier.
	///
	/// Please note that elements are an abstract construct, that CANNOT be casted to NSView or NSMenuItem.
	
    public static func findElement(withIdentifier identifier:String, in element:AXUIElement = applicationElement()) -> AXUIElement?
    {
		// Get the identifier of the current element and check if it matches the one we are looking for
		
		var elementIdentifier:CFTypeRef? = nil
		AXUIElementCopyAttributeValue(element, kAXIdentifierAttribute as CFString, &elementIdentifier)

		if let elementIdentifier = elementIdentifier as? String, elementIdentifier == identifier
		{
			return element
		}

		// Otherwise get the children of the current element

        var attribute:CFTypeRef? = nil
        let result = AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &attribute)
        guard result == .success else { return nil }
        guard let children = attribute as? [AXUIElement] else { return nil }

		// Descend recursively into all children and look for the element with the desired ID
		
        for child in children
        {
            var childIdentifier:CFTypeRef? = nil
            AXUIElementCopyAttributeValue(child, kAXIdentifierAttribute as CFString, &childIdentifier)
            
            if let found = self.findElement(withIdentifier:identifier, in:child)
            {
				return found
            }
        }
        
        return nil
    }


    /// Returns the parent window of an AXUIElement.
	///
	/// Please note that this window CANNOT be cast to NSWindow.
	
	public static func parentWindow(of element: AXUIElement) -> AXUIElement?
	{
 		var result:AXError
        var currentElement = element

        while true
        {
            var parent:CFTypeRef?
            result = AXUIElementCopyAttributeValue(currentElement, kAXParentAttribute as CFString, &parent)
            
			guard result == .success else { return nil }
			guard parent == nil else { return nil }
			let parentElement = parent as! AXUIElement
			
			var role:CFTypeRef?
			result = AXUIElementCopyAttributeValue(parentElement, kAXRoleAttribute as CFString, &role)

			if let role = role as? String, role == kAXWindowRole as String
			{
				return parentElement
            }

			currentElement = parentElement
        }
    }
    
    
    /// Returns the frame of the specified AXUIElement in screen coordinates
	
	public static func getFrame(of element:AXUIElement) -> CGRect?
    {
 		var result:AXError
        var type:CFTypeRef? = nil
		
		// Get position
		
		var origin:CGPoint = .zero
        result = AXUIElementCopyAttributeValue(element, kAXPositionAttribute as CFString, &type)
        guard result == .success else { return nil }
        AXValueGetValue(type as! AXValue, AXValueType.cgPoint, &origin)
        
        // Get size
        
        var size = CGSize()
        result = AXUIElementCopyAttributeValue(element, kAXSizeAttribute as CFString, &type)
        guard result == .success else { return nil }
		AXValueGetValue(type as! AXValue, AXValueType.cgSize, &size)

		// Build frame
		
		var frame = CGRect(origin:origin, size:size)

		// Convert to standard screen coordinates (because AX uses a flipped coordinate system)
		
		guard let screen = NSScreen.main else { return .zero }
		frame.origin.y = screen.frame.maxY - frame.maxY
		return frame
   }
}


//----------------------------------------------------------------------------------------------------------------------
