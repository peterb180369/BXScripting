//**********************************************************************************************************************
//
//  NSView+subviewWithIdentifier.swift
//	Finds a NSView in the hierarchy by its identifier
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit


//----------------------------------------------------------------------------------------------------------------------


public enum BXIdentifierMethod
{
	case exactMatch
	case contains
}


//----------------------------------------------------------------------------------------------------------------------


extension NSView
{
	/// Searches the view hierarchy in a window for a view with the specified identifier. Returns nil if not found.
	
    func subviewWithIdentifier(_ identifier:String, method:BXIdentifierMethod = .exactMatch) -> NSView?
    {
		if method == .exactMatch
		{
			if (self.identifier?.rawValue ?? "") == identifier || self.accessibilityIdentifier() == identifier
			{
				return self
			}
		}
		else if method == .contains
		{
			if (self.identifier?.rawValue ?? "").contains(identifier) || self.accessibilityIdentifier().contains(identifier)
			{
				return self
			}
		}
		
        for view in self.subviews
        {
            if let subview = view.subviewWithIdentifier(identifier, method:method)
            {
                return subview
            }
        }
        
        return nil
    }
}


//----------------------------------------------------------------------------------------------------------------------


extension NSWindow
{
	/// Searches the view hierarchy in a window for a view with the specified identifier. Returns nil if not found.
	
    public func subviewWithIdentifier(_ identifier:String, method:BXIdentifierMethod = .exactMatch) -> NSView?
    {
		if let subview = self.contentView?.subviewWithIdentifier(identifier, method:method)
		{
			return subview
		}
		
		for childWindow in self.childWindows ?? []
		{
			if let subview = childWindow.contentView?.subviewWithIdentifier(identifier, method:method)
			{
				return subview
			}
		}

		if let sheet = self.attachedSheet
		{
			if let subview = sheet.contentView?.subviewWithIdentifier(identifier, method:method)
			{
				return subview
			}
		}
		
		return nil
    }
}


//----------------------------------------------------------------------------------------------------------------------
