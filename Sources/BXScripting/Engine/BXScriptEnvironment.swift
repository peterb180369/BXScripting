//**********************************************************************************************************************
//
//  BXScriptEnvironment.swift
//	Lightweight and extensible scripting engine for Swift based applications
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit


//----------------------------------------------------------------------------------------------------------------------


/// BXScriptEnvironment stored various variables that can be used by scripts. The variables are stored by String key.

public class BXScriptEnvironment
{
	/// The singleton shared environment is globally available
	
	public static let shared = BXScriptEnvironment()
	
	/// Creates a new BXScriptEnvironment
	
	public init()
	{
		self.setDefaultColors(with:.systemYellow)
	}
	

//----------------------------------------------------------------------------------------------------------------------


	/// This dictionary stores all variables
	
	private var storage:[String:Any] = [:]
	

//----------------------------------------------------------------------------------------------------------------------


	/// Stores a value of type T in the enviroment
	
	public func setValue<T>(_ value:T, forKey key:String)
	{
		storage[key] = value
	}


	/// Retrieves a value of type T from the enviroment. Returns nil if not available.
	
	public func value<T>(forKey key:String) -> T?
	{
		storage[key] as? T
	}


	/// Removes a value  from the enviroment. Returns nil if not available.
	
	public func removeValue(forKey key:String)
	{
		storage[key] = nil
	}


	/// Typesafe setter/getter for environment values
	
	public subscript<T>(key:String) -> T?
	{
		set
		{
        	self.setValue(newValue, forKey:key)
		}

		get
		{
			self.value(forKey:key)
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptEnvironment
{
	/// Sets default colors for various UI element hiliting commands
	
	public func setDefaultColors(with primaryColor:NSColor)
	{
		self[.hiliteTextColorKey] = primaryColor
		self[.hiliteStrokeColorKey] = primaryColor
		self[.hiliteFillColorKey] = primaryColor.withAlphaComponent(0.15)
	}
}


extension String
{
	public static let hiliteTextColorKey = "hiliteTextColor"
	public static let hiliteStrokeColorKey = "hiliteStrokeColor"
	public static let hiliteFillColorKey = "hiliteFillColor"
}


//----------------------------------------------------------------------------------------------------------------------
