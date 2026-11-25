//**********************************************************************************************************************
//
//  BXScriptEnvironment.swift
//	Lightweight and extensible scripting engine for Swift based applications
//  Copyright ©2023-2026 Peter Baumgartner. All rights reserved.
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
		self[.messageTintColorKey] = primaryColor.withAlphaComponent(0.7)
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
	public static let messageTintColorKey = "messageTintColor"
}


//----------------------------------------------------------------------------------------------------------------------


extension BXScriptEnvironment
{
	/// A lookup table for words that AVSpeechSynthesizer does not pronounce correctly.
	///
	/// The first key is the language code (en,de,fr). The second key is the word or phrase that comes out
	/// wrong. See BXScriptPronunciation for the two ways of fixing it.
	
	public var speechPronunciationFixes:[String:[String:BXScriptPronunciation]]
	{
		set { self[.speechPronunciationFixesKey] = newValue }
		get { self[.speechPronunciationFixesKey] ?? [:] }
	}
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: -

/// Describes how a word or phrase should be spoken.

public enum BXScriptPronunciation
{
	/// International Phonetic Alphabet notation, e.g. "ˌfoʊtoʊˈmadʒɪkoʊ" for FotoMagico.
	///
	/// The word stays in the text and the synthesizer is told which phonemes to produce for it, so this is
	/// real phonetics rather than a misspelling that happens to fool one particular voice. It was measured to
	/// work identically for premium, enhanced and compact voices.
	///
	/// ATTENTION: invalid notation is not ignored. The synthesizer renders near silence instead, so a typo
	/// here makes the word disappear rather than merely mispronouncing it. Check new notation by ear, or with
	/// the PronunciationProbe in the Experiments folder, which flags a suspiciously short rendering.
	
	case phonetic(String)
	
	/// A plain text replacement.
	///
	/// Use this where the problem is not how a word is pronounced but that the written form is not meant to
	/// be read out literally at all - "3/4" as "three quarter", or "2160p" as "21 60 P". Phonetics would be
	/// the wrong tool for those, since there is nothing wrong with how the words themselves are spoken.
	
	case spoken(String)
}


extension String
{
	public static let speechPronunciationFixesKey = "speechPronunciationFixes"
}


//----------------------------------------------------------------------------------------------------------------------
