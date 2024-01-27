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
	/// Returns the absolute location of a relative point in a view. The relative coordinates are specified in the range [0 ... 1]. 
	
	public static func relativePoint(_ relative:CGPoint, in view:NSView) -> CGPoint
	{
		let bounds = view.bounds
		
		let p = CGPoint(
			bounds.minX + relative.x * bounds.width,
			bounds.minY + relative.y * bounds.height)
			
		return p
	}

	/// Returns the topLeft point in a view  (with specified inset)
	
	public static func topLeft(of view:@escaping @autoclosure ()->NSView?, inset:CGSize = .zero) -> CGPoint
	{
		guard let view = view() else { return .zero }
		let p = view.bounds.insetBy(dx:inset.width, dy:inset.height).topLeft
		return p
	}

	/// Returns the top point in a view  (with specified inset)
	
	public static func top(of view:@escaping @autoclosure ()->NSView?, inset:CGSize = .zero) -> CGPoint
	{
		guard let view = view() else { return .zero }
		let p = view.bounds.insetBy(dx:inset.width, dy:inset.height).top
		return p
	}

	/// Returns the topRight point in a view  (with specified inset)
	
	public static func topRight(of view:@escaping @autoclosure ()->NSView?, inset:CGSize = .zero) -> CGPoint
	{
		guard let view = view() else { return .zero }
		let p = view.bounds.insetBy(dx:inset.width, dy:inset.height).topRight
		return p
	}

	/// Returns the left point in a view  (with specified inset)
	
	public static func left(of view:@escaping @autoclosure ()->NSView?, inset:CGSize = .zero) -> CGPoint
	{
		guard let view = view() else { return .zero }
		let p = view.bounds.insetBy(dx:inset.width, dy:inset.height).left
		return p
	}

	/// Returns the center point in a view  (with specified inset)
	
	public static func center(of view:@escaping @autoclosure ()->NSView?) -> CGPoint
	{
		guard let view = view() else { return .zero }
		let p = view.bounds.center
		return p
	}

	/// Returns the right point in a view  (with specified inset)
	
	public static func right(of view:@escaping @autoclosure ()->NSView?, inset:CGSize = .zero) -> CGPoint
	{
		guard let view = view() else { return .zero }
		let p = view.bounds.insetBy(dx:inset.width, dy:inset.height).right
		return p
	}

	/// Returns the bottomLeft point in a view  (with specified inset)
	
	public static func bottomLeft(of view:@escaping @autoclosure ()->NSView?, inset:CGSize = .zero) -> CGPoint
	{
		guard let view = view() else { return .zero }
		let p = view.bounds.insetBy(dx:inset.width, dy:inset.height).bottomLeft
		return p
	}

	/// Returns the bottom point in a view  (with specified inset)
	
	public static func bottom(of view:@escaping @autoclosure ()->NSView?, inset:CGSize = .zero) -> CGPoint
	{
		guard let view = view() else { return .zero }
		let p = view.bounds.insetBy(dx:inset.width, dy:inset.height).bottom
		return p
	}

	/// Returns the bottomRight point in a view  (with specified inset)
	
	public static func bottomRight(of view:@escaping @autoclosure ()->NSView?, inset:CGSize = .zero) -> CGPoint
	{
		guard let view = view() else { return .zero }
		let p = view.bounds.insetBy(dx:inset.width, dy:inset.height).bottomRight
		return p
	}
}


extension CGPoint
{
	/// Returns the absolute location of a relative point in a window. The relative coordinates are specified in the range [0 ... 1]
	
	public static func relativePoint(_ relative:CGPoint, in window:@escaping @autoclosure ()->NSWindow?) -> CGPoint
	{
		guard let view = window()?.contentView else { return .zero }
		return self.relativePoint(relative, in:view)
	}

	/// Returns the mouse location in a window.
	
	public static func mousePoint(in window:@escaping @autoclosure ()->NSWindow?, offset:CGPoint = .zero) -> CGPoint
	{
		guard let window = window() else { return .zero }
		return window.convertPoint(fromScreen:NSEvent.mouseLocation) + offset
	}

	/// Returns the topLeft point in a window (with specified inset)
	
	public static func topLeft(of window:@escaping @autoclosure ()->NSWindow?, inset:CGSize = CGSize(width:64,height:64)) -> CGPoint
	{
		guard let view = window()?.contentView else { return .zero }
		return self.topLeft(of:view, inset:inset)
	}

	/// Returns the top point in a window (with specified inset)
	
	public static func top(of window:@escaping @autoclosure ()->NSWindow?, inset:CGSize = CGSize(width:64,height:64)) -> CGPoint
	{
		guard let view = window()?.contentView else { return .zero }
		return self.top(of:view, inset:inset)
	}

	/// Returns the topRight point in a window (with specified inset)
	
	public static func topRight(of window:@escaping @autoclosure ()->NSWindow?, inset:CGSize = CGSize(width:64,height:64)) -> CGPoint
	{
		guard let view = window()?.contentView else { return .zero }
		return self.topRight(of:view, inset:inset)
	}

	/// Returns the left point in a window (with specified inset)
	
	public static func left(of window:@escaping @autoclosure ()->NSWindow?, inset:CGSize = CGSize(width:64,height:64)) -> CGPoint
	{
		guard let view = window()?.contentView else { return .zero }
		return self.left(of:view, inset:inset)
	}

	/// Returns the center point in a window (with specified inset)
	
	public static func center(of window:@escaping @autoclosure ()->NSWindow?) -> CGPoint
	{
		guard let view = window()?.contentView else { return .zero }
		return self.center(of:view)
	}

	/// Returns the right point in a window (with specified inset)
	
	public static func right(of window:@escaping @autoclosure ()->NSWindow?, inset:CGSize = CGSize(width:64,height:64)) -> CGPoint
	{
		guard let view = window()?.contentView else { return .zero }
		return self.right(of:view, inset:inset)
	}

	/// Returns the bottomLeft point in a window (with specified inset)
	
	public static func bottomLeft(of window:@escaping @autoclosure ()->NSWindow?, inset:CGSize = CGSize(width:64,height:64)) -> CGPoint
	{
		guard let view = window()?.contentView else { return .zero }
		return self.bottomLeft(of:view, inset:inset)
	}

	/// Returns the bottom point in a window (with specified inset)
	
	public static func bottom(of window:@escaping @autoclosure ()->NSWindow?, inset:CGSize = CGSize(width:64,height:64)) -> CGPoint
	{
		guard let view = window()?.contentView else { return .zero }
		return self.bottom(of:view, inset:inset)
	}

	/// Returns the bottomRight point in a window (with specified inset)
	
	public static func bottomRight(of window:@escaping @autoclosure ()->NSWindow?, inset:CGSize = CGSize(width:64,height:64)) -> CGPoint
	{
		guard let view = window()?.contentView else { return .zero }
		return self.bottomRight(of:view, inset:inset)
	}
}


extension CGPoint
{
	public static func topLeft(of screen:NSScreen?) -> CGPoint
	{
		screen?.frame.topLeft ?? .zero
	}

	public static func top(of screen:NSScreen?) -> CGPoint
	{
		screen?.frame.top ?? .zero
	}

	public static func topRight(of screen:NSScreen?) -> CGPoint
	{
		screen?.frame.topRight ?? .zero
	}

	public static func left(of screen:NSScreen?) -> CGPoint
	{
		screen?.frame.left ?? .zero
	}

	public static func center(of screen:NSScreen?) -> CGPoint
	{
		screen?.frame.center ?? .zero
	}

	public static func right(of screen:NSScreen?) -> CGPoint
	{
		screen?.frame.right ?? .zero
	}

	public static func bottomLeft(of screen:NSScreen?) -> CGPoint
	{
		screen?.frame.bottomLeft ?? .zero
	}

	public static func bottom(of screen:NSScreen?) -> CGPoint
	{
		screen?.frame.bottom ?? .zero
	}

	public static func bottomRight(of screen:NSScreen?) -> CGPoint
	{
		screen?.frame.bottomRight ?? .zero
	}

	/// Returns a point that it definately offscreen
	
	public static func offscreen() -> CGPoint
	{
		CGPoint(1e6,1e6)
	}
}


//----------------------------------------------------------------------------------------------------------------------


extension NSMenuItem
{
	/// Returns the frame of the specified NSMenuItem
	
	public static func frameOfItem(withIdentifier identifier:String) -> CGRect
	{
		BXScriptCommand_hiliteMenuItem.menuItemFrame(withIdentifier:identifier)
	}
}


//----------------------------------------------------------------------------------------------------------------------


extension NSScreen
{
	public static func frame(inset:CGSize = .zero) -> CGRect
	{
		guard let screen = NSScreen.main else { return .zero }
		return screen.frame.insetBy(dx:inset.width, dy:inset.height)
	}
}


//----------------------------------------------------------------------------------------------------------------------
