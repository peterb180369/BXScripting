//**********************************************************************************************************************
//
//  View+renderImage.swift
//	Renders a SwiftUI View to a NSImage or UIImage
//  Copyright ©2021 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit
import SwiftUI


//----------------------------------------------------------------------------------------------------------------------


extension View
{
	/// Returns a rasterized Image of the original View
	
	@ViewBuilder public func asImage() -> some View
	{
		if let image = self.renderImage(colorScheme:.light, isTemplate:false)
		{
			SwiftUI.Image(nsImage:image)
		}
		else
		{
			EmptyView()
		}
	}

	/// Renders the view to an NSImage
	
	public func renderImage(colorScheme:ColorScheme = .dark, isTemplate:Bool = true) -> NSImage?
	{
		let view = NSHostingView(rootView:self.colorScheme(colorScheme))
        let size = view.intrinsicContentSize
        let bounds = CGRect(origin:.zero, size:size)
		view.frame = bounds
		
		guard let bitmap = view.bitmapImageRepForCachingDisplay(in:bounds) else { return nil }
		bitmap.size = size
		view.cacheDisplay(in:bounds, to:bitmap)

		let image = NSImage(size:size)
		image.addRepresentation(bitmap)
		image.isTemplate = isTemplate
		
		return image
	}
}


//----------------------------------------------------------------------------------------------------------------------
