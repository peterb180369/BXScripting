//**********************************************************************************************************************
//
//  NSView+subylayer.swift
//	Function for finding sublayer by name
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit


//----------------------------------------------------------------------------------------------------------------------


extension NSView
{
	/// Returns the sublayer with the specified name
	
	public func sublayer(named:String) -> CALayer?
	{
		guard let layer = self.layer else { return nil }

		for sublayer in layer.sublayers ?? []
		{
			if sublayer.name == named
			{
				return sublayer
			}
		}
		
		return nil
	}

	/// Removes the first sublayer with the specified name
	
	public func removeSublayer(named:String)
	{
		guard let sublayer = self.sublayer(named:named) else { return }
		sublayer.removeFromSuperlayer()
	}
}


//----------------------------------------------------------------------------------------------------------------------
