//**********************************************************************************************************************
//
//  NSWindow+toolbarItemView.swift
//	Find the view for a NSToolbarItem
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit


//----------------------------------------------------------------------------------------------------------------------


extension NSWindow
{
	/// Returns the container view for a NSToolbarItem with the specified identifier
	
	public func toolbarItemView(withIdentifier identifier:String) -> NSView?
    {
		if let toolbar = self.toolbar
		{
			for item in toolbar.items
			{
				if item.itemIdentifier.rawValue == identifier, let view = item.view
				{
					return view.superview
				}
			}
		}
		
		return nil
    }
}


//----------------------------------------------------------------------------------------------------------------------
