//**********************************************************************************************************************
//
//  CGRect+FMExtensions.swift
//	Adds convenience methods
//  Copyright ©2016-2018 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation
import CoreGraphics


//----------------------------------------------------------------------------------------------------------------------


/// This extension adds convenience accessors to NSRect

extension CGRect
{
	init(from:CGPoint, to:CGPoint)
	{
		let x = min(from.x,to.x)
		let y = min(from.y,to.y)
		let w = abs(from.x-to.x)
		let h = abs(from.y-to.y)
		self.init(x:x, y:y, width:w, height:h)
	}
	
	/// Returns the center point of a CGRect
	
	var center: CGPoint
	{
		return CGPoint( x:self.midX, y:self.midY )
	}

	/// Returns the left point of a CGRect
	
	var left: CGPoint
	{
		return CGPoint( x:self.minX, y:self.midY )
	}

	/// Returns the bottom point of a CGRect
	
	var right: CGPoint
	{
		return CGPoint( x:self.maxX, y:self.midY )
	}

	/// Returns the top point of a CGRect
	
	var top: CGPoint
	{
		return CGPoint( x:self.midX, y:self.maxY )
	}

	/// Returns the bottom point of a CGRect
	
	var bottom: CGPoint
	{
		return CGPoint( x:self.midX, y:self.minY )
	}

	/// Returns the top left point of a CGRect
	
	var topLeft: CGPoint
	{
		return CGPoint( x:self.minX, y:self.maxY )
	}

	/// Returns the top right point of a CGRect
	
	var topRight: CGPoint
	{
		return CGPoint( x:self.maxX, y:self.maxY )
	}

	/// Returns the bottom left point of a CGRect
	
	var bottomLeft: CGPoint
	{
		return CGPoint( x:self.minX, y:self.minY )
	}

	/// Returns the bottom right point of a CGRect
	
	var bottomRight: CGPoint
	{
		return CGPoint( x:self.maxX, y:self.minY )
	}

	/// Returns the length of the shorter edge
	
	var shorterEdge: CGFloat
	{
		return min( self.width, self.height )
	}
	
	/// Returns the length of the longer edge
	
	var longerEdge: CGFloat
	{
		return max( self.width, self.height )
	}
	
	/// Returns the length of the diagonal
	
	var diagonal: CGFloat
	{
		let w = self.width
		let h = self.height
		return sqrt(w*w + h*h)
	}

	/// Similar to insetBy(dx:,dy:) except that it doesn't produce bogus Inf or NaN values if the insets are too large for the CGRect
	
	func safeInsetBy(dx:CGFloat, dy:CGFloat) -> CGRect
	{
		var rect = self
		
		if rect.width > 2*dx
		{
			rect.origin.x += dx
			rect.size.width -= 2*dx
		}
		else
		{
			rect.origin.x = self.midX
			rect.size.width = 0.0
		}
		
		if rect.height > 2*dy
		{
			rect.origin.y += dy
			rect.size.height -= 2*dy
		}
		else
		{
			rect.origin.y = self.midY
			rect.size.height = 0.0
		}
		
		return rect
	}
	
}


//----------------------------------------------------------------------------------------------------------------------
