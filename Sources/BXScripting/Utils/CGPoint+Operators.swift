//**********************************************************************************************************************
//
//  CGPoint+Operators.swift
//	Point and vector operators
//  Copyright ©2016-2020 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation
import CoreGraphics


//----------------------------------------------------------------------------------------------------------------------


/// This extension adds some vector math operators to CGPoint/NSPoint

extension CGPoint
{
	static func + (l:CGPoint, r:CGPoint) -> CGPoint
	{
		return CGPoint(x:l.x+r.x,y:l.y+r.y)
	}
	
	static func - (l:CGPoint, r:CGPoint) -> CGPoint
	{
		return CGPoint(x:l.x-r.x,y:l.y-r.y)
	}

	static func += (l:inout CGPoint, r:CGPoint)
	{
		l = CGPoint(x:l.x+r.x,y:l.y+r.y)
	}
}


//----------------------------------------------------------------------------------------------------------------------
