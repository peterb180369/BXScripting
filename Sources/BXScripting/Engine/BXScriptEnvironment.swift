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
		self.setDefaultFont(NSFont.boldSystemFont(ofSize:36))
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

	/// Sets default font for message commands
	
	public func setDefaultFont(_ font:NSFont)
	{
		self[.fontKey] = font
	}
}


extension String
{
	public static let fontKey = "font"
	public static let hiliteTextColorKey = "hiliteTextColor"
	public static let hiliteStrokeColorKey = "hiliteStrokeColor"
	public static let hiliteFillColorKey = "hiliteFillColor"
}


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptEnvironment
{
	/// A lookup table for fixing words that not pronounced correcty by AVSpeechSynthesizer and its voices.
	///
	/// The first key is the language code (en,de,fr). The second key is the word that is being pronounced incorrectly or funny.
	/// The value is a modified string that forces a correct pronunciation for the language.
	
	public var speechPronunciationFixes:[String:[String:String]]
	{
		set { self[.speechPronunciationFixesKey] = newValue }
		get { self[.speechPronunciationFixesKey] ?? [:] }
	}
}


extension String
{
	public static let speechPronunciationFixesKey = "speechPronunciationFixes"
}


//----------------------------------------------------------------------------------------------------------------------
