//**********************************************************************************************************************
//
//  BXScriptValue.swift
//	Provides various convenience accessors to supply arguments to BXScriptCommands
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit
import SwiftUI


//----------------------------------------------------------------------------------------------------------------------


public struct BXScriptValue
{
	/// This is a convenience call to retrieve named closures from the shared BXScriptEnvironment in a type-safe way
	///
	/// Example call:
	///
	///		let action:(()->Void)? = BXScriptValue.named("myActionClosure")
	
	public static func named<T>(_ key:String) -> T?
	{
		BXScriptEnvironment.shared[key]
	}
}


//----------------------------------------------------------------------------------------------------------------------


extension NSWindow
{
	public static func named(_ key:String) -> NSWindow?
	{
		BXScriptEnvironment.shared[key]
	}
}

extension NSColor
{
	public static func named(_ key:String) -> NSColor?
	{
		BXScriptEnvironment.shared[key]
	}
}

extension NSImage
{
	public static func named(_ key:String) -> NSImage?
	{
		BXScriptEnvironment.shared[key]
	}
}

extension CGFloat
{
	public static func named(_ key:String) -> CGFloat?
	{
		BXScriptEnvironment.shared[key]
	}
}

extension String
{
	public static func named(_ key:String) -> String?
	{
		BXScriptEnvironment.shared[key]
	}
}


//----------------------------------------------------------------------------------------------------------------------


extension CGPoint
{
	/// Returns the absolute location of a relative point in a view. The relative coordinates are specified in the range [0 ... 1]. The result is in window coordinates.
	
	public static func relativePoint(_ relative:CGPoint, in view:NSView) -> CGPoint
	{
		let bounds = view.bounds
		
		let p = CGPoint(
			bounds.minX + relative.x * bounds.width,
			bounds.minY + relative.y * bounds.height)
			
		return view.convert(p, to:nil)
	}

	/// Returns the topLeft point in a view in window coordinates (with specified inset)
	
	public static func topLeft(of view:NSView?, inset:CGSize = .zero) -> CGPoint
	{
		guard let view = view else { return .zero }
		let p = view.bounds.insetBy(dx:inset.width, dy:inset.height).topLeft
		return view.convert(p, to:nil)
	}

	/// Returns the top point in a view in window coordinates (with specified inset)
	
	public static func top(of view:NSView?, inset:CGSize = .zero) -> CGPoint
	{
		guard let view = view else { return .zero }
		let p = view.bounds.insetBy(dx:inset.width, dy:inset.height).top
		return view.convert(p, to:nil)
	}

	/// Returns the topRight point in a view in window coordinates (with specified inset)
	
	public static func topRight(of view:NSView?, inset:CGSize = .zero) -> CGPoint
	{
		guard let view = view else { return .zero }
		let p = view.bounds.insetBy(dx:inset.width, dy:inset.height).topRight
		return view.convert(p, to:nil)
	}

	/// Returns the left point in a view in window coordinates (with specified inset)
	
	public static func left(of view:NSView?, inset:CGSize = .zero) -> CGPoint
	{
		guard let view = view else { return .zero }
		let p = view.bounds.insetBy(dx:inset.width, dy:inset.height).left
		return view.convert(p, to:nil)
	}

	/// Returns the center point in a view in window coordinates (with specified inset)
	
	public static func center(of view:NSView?) -> CGPoint
	{
		guard let view = view else { return .zero }
		let p = view.bounds.center
		return view.convert(p, to:nil)
	}

	/// Returns the right point in a view in window coordinates (with specified inset)
	
	public static func right(of view:NSView?, inset:CGSize = .zero) -> CGPoint
	{
		guard let view = view else { return .zero }
		let p = view.bounds.insetBy(dx:inset.width, dy:inset.height).right
		return view.convert(p, to:nil)
	}

	/// Returns the bottomLeft point in a view in window coordinates (with specified inset)
	
	public static func bottomLeft(of view:NSView?, inset:CGSize = .zero) -> CGPoint
	{
		guard let view = view else { return .zero }
		let p = view.bounds.insetBy(dx:inset.width, dy:inset.height).bottomLeft
		return view.convert(p, to:nil)
	}

	/// Returns the bottom point in a view in window coordinates (with specified inset)
	
	public static func bottom(of view:NSView?, inset:CGSize = .zero) -> CGPoint
	{
		guard let view = view else { return .zero }
		let p = view.bounds.insetBy(dx:inset.width, dy:inset.height).bottom
		return view.convert(p, to:nil)
	}

	/// Returns the bottomRight point in a view in window coordinates (with specified inset)
	
	public static func bottomRight(of view:NSView?, inset:CGSize = .zero) -> CGPoint
	{
		guard let view = view else { return .zero }
		let p = view.bounds.insetBy(dx:inset.width, dy:inset.height).bottomRight
		return view.convert(p, to:nil)
	}
}


extension CGPoint
{
	/// Returns the absolute location of a relative point in a window. The relative coordinates are specified in the range [0 ... 1]
	
	public static func relativePoint(_ relative:CGPoint, in window:NSWindow) -> CGPoint
	{
		guard let view = window.contentView else { return .zero }
		return self.relativePoint(relative, in:view)
	}

	/// Returns the topLeft point in a window (with specified inset)
	
	public static func topLeft(of window:NSWindow, inset:CGSize = CGSize(width:64,height:64)) -> CGPoint
	{
		guard let view = window.contentView else { return .zero }
		return self.topLeft(of:view, inset:inset)
	}

	/// Returns the top point in a window (with specified inset)
	
	public static func top(of window:NSWindow, inset:CGSize = CGSize(width:64,height:64)) -> CGPoint
	{
		guard let view = window.contentView else { return .zero }
		return self.top(of:view, inset:inset)
	}

	/// Returns the topRight point in a window (with specified inset)
	
	public static func topRight(of window:NSWindow, inset:CGSize = CGSize(width:64,height:64)) -> CGPoint
	{
		guard let view = window.contentView else { return .zero }
		return self.topRight(of:view, inset:inset)
	}

	/// Returns the left point in a window (with specified inset)
	
	public static func left(of window:NSWindow, inset:CGSize = CGSize(width:64,height:64)) -> CGPoint
	{
		guard let view = window.contentView else { return .zero }
		return self.left(of:view, inset:inset)
	}

	/// Returns the center point in a window (with specified inset)
	
	public static func center(of window:NSWindow) -> CGPoint
	{
		guard let view = window.contentView else { return .zero }
		return self.center(of:view)
	}

	/// Returns the right point in a window (with specified inset)
	
	public static func right(of window:NSWindow, inset:CGSize = CGSize(width:64,height:64)) -> CGPoint
	{
		guard let view = window.contentView else { return .zero }
		return self.right(of:view, inset:inset)
	}

	/// Returns the bottomLeft point in a window (with specified inset)
	
	public static func bottomLeft(of window:NSWindow, inset:CGSize = CGSize(width:64,height:64)) -> CGPoint
	{
		guard let view = window.contentView else { return .zero }
		return self.bottomLeft(of:view, inset:inset)
	}

	/// Returns the bottom point in a window (with specified inset)
	
	public static func bottom(of window:NSWindow, inset:CGSize = CGSize(width:64,height:64)) -> CGPoint
	{
		guard let view = window.contentView else { return .zero }
		return self.bottom(of:view, inset:inset)
	}

	/// Returns the bottomRight point in a window (with specified inset)
	
	public static func bottomRight(of window:NSWindow, inset:CGSize = CGSize(width:64,height:64)) -> CGPoint
	{
		guard let view = window.contentView else { return .zero }
		return self.bottomRight(of:view, inset:inset)
	}
}


//----------------------------------------------------------------------------------------------------------------------
