//**********************************************************************************************************************
//
//  NSVisualEffectView+frostedGlass.swift
//	Creates a NSVisualEffectView for a frosted glass window
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit


//----------------------------------------------------------------------------------------------------------------------


extension NSVisualEffectView
{
	/// Searches the view hierarchy in a window for a view with the specified identifier. Returns nil if not found.
	
    public static func frostedGlassView() -> NSVisualEffectView
    {
        let effectView = NSVisualEffectView()
        effectView.appearance = NSAppearance(named:.vibrantLight)
        effectView.state = .active
        effectView.material = .popover
        effectView.blendingMode = .behindWindow
        effectView.isEmphasized = true
        
        return effectView
    }
}


//----------------------------------------------------------------------------------------------------------------------
