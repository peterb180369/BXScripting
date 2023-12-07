//**********************************************************************************************************************
//
//  NSImage+systemSymbol.swift
//	Convenience function to create NSImages with SFSymbols
//  Copyright ©2021 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit
import SwiftUI


//----------------------------------------------------------------------------------------------------------------------


extension NSImage
{
	@available(macOS 12,*) public convenience init?(_ systemName:String, color:NSColor? = nil, size:CGSize = CGSize(width:64,height:64))
	{
		let effectiveColor = color ?? BXScriptEnvironment.shared[.hiliteTextColorKey] ?? .systemYellow
		
		let view = SwiftUI.Image(systemName:systemName)
			.resizable()
			.aspectRatio(contentMode:.fit)
			.frame(width:size.width, height:size.height)
			.foregroundColor(SwiftUI.Color(nsColor:effectiveColor))

		guard let nsimage = view.renderImage() else { return nil }
		guard let cgimage = nsimage.CGImage else { return nil }
		self.init(cgImage:cgimage, size:nsimage.size)
	}


	@available(macOS 12,*) public convenience init?(_ systemName:String, primaryColor:Color = .white, secondaryColor:Color = .green, size:CGFloat = 32)
	{
		let view = SwiftUI.Image(systemName:systemName)
			.symbolRenderingMode(.palette)
			.foregroundStyle(primaryColor,secondaryColor)
			.font(.system(size:size))
    
		guard let nsimage = view.renderImage() else { return nil }
		guard let cgimage = nsimage.CGImage else { return nil }
		self.init(cgImage:cgimage, size:nsimage.size)
	}


	@available(macOS 12,*) public static func symbolImage(_ systemName:String, primaryColor:Color = .white, secondaryColor:Color = .green, size:CGFloat = 32) -> NSImage?
	{
		NSImage(systemName, primaryColor:primaryColor, secondaryColor:secondaryColor, size:size)
	}


	/// Returns a bitmap CGImage
	
	internal var CGImage:CGImage?
	{
		self.cgImage(forProposedRect:nil, context:nil, hints:nil)
	}

}


//----------------------------------------------------------------------------------------------------------------------
