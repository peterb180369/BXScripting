//**********************************************************************************************************************
//
//  NSView+subviewWithIdentifier.swift
//	Finds a NSView in the hierarchy by its identifier
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit


//----------------------------------------------------------------------------------------------------------------------


extension NSView
{
	/// Searches the view hierarchy in a window for a view with the specified identifier. Returns nil if not found.
	
    func subviewWithIdentifier(_ identifier:String) -> NSView?
    {
		if (self.identifier?.rawValue ?? "") == identifier || self.accessibilityIdentifier() == identifier
		{
			return self
		}
            
        for view in self.subviews
        {
            if let subview = view.subviewWithIdentifier(identifier)
            {
                return subview
            }
        }
        
        return nil
    }
}


extension NSWindow
{
	/// Searches the view hierarchy in a window for a view with the specified identifier. Returns nil if not found.
	
    public func subviewWithIdentifier(_ identifier:String) -> NSView?
    {
		if let subview = self.contentView?.subviewWithIdentifier(identifier)
		{
			return subview
		}
		
		for childWindow in self.childWindows ?? []
		{
			if let subview = childWindow.contentView?.subviewWithIdentifier(identifier)
			{
				return subview
			}
		}

		if let sheet = self.attachedSheet
		{
			if let subview = sheet.contentView?.subviewWithIdentifier(identifier)
			{
				return subview
			}
		}
		
		return nil
    }
}


//----------------------------------------------------------------------------------------------------------------------
