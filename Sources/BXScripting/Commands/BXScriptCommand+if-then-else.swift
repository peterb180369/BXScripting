//**********************************************************************************************************************
//
//  BXScriptCommand+if.swift
//	Adds a if-then-else command to BXScriptCommand
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


extension BXScriptCommand where Self == BXScriptCommand_if
{
	public static func `if`(_ condition:@escaping ()->Bool, label:String) -> BXScriptCommand
	{
		BXScriptCommand_if(condition:condition, label:label)
	}

	public static func `if`(_ condition:@escaping ()->Bool, label:any RawRepresentable<String>) -> BXScriptCommand
	{
		BXScriptCommand_if(condition:condition, label:label.rawValue)
	}

	public static func `if`(_ conditionName:String, label:String) -> BXScriptCommand
	{
		let condition:()->Bool = BXScriptEnvironment.shared[conditionName] ?? { false }
		return BXScriptCommand_if(condition:condition, label:label)
	}

	public static func `if`(_ conditionName:String, label:any RawRepresentable<String>) -> BXScriptCommand
	{
		let condition:()->Bool = BXScriptEnvironment.shared[conditionName] ?? { false }
		return BXScriptCommand_if(condition:condition, label:label.rawValue)
	}
}


extension BXScriptCommand where Self == BXScriptCommand_then
{
	public static func then(_ label:String) -> BXScriptCommand
	{
		BXScriptCommand_then(label:label)
	}

	public static func then(_ label:any RawRepresentable<String>) -> BXScriptCommand
	{
		BXScriptCommand_then(label:label.rawValue)
	}
}


extension BXScriptCommand where Self == BXScriptCommand_else
{
	public static func `else`(_ label:String) -> BXScriptCommand
	{
		BXScriptCommand_else(label:label)
	}

	public static func `else`(_ label:any RawRepresentable<String>) -> BXScriptCommand
	{
		BXScriptCommand_else(label:label.rawValue)
	}
}


extension BXScriptCommand where Self == BXScriptCommand_endif
{
	public static func endif(_ label:String) -> BXScriptCommand
	{
		BXScriptCommand_endif(label:label)
	}

	public static func endif(_ label:any RawRepresentable<String>) -> BXScriptCommand
	{
		BXScriptCommand_endif(label:label.rawValue)
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command checks a condition and jumps to the then or else label

public struct BXScriptCommand_if : BXScriptCommand, BXLabeledScriptCommand
{
	var condition:()->Bool
	public var label:String
	
	public weak var scriptEngine:BXScriptEngine? = nil
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	
	
	public func execute()
	{
		self.queue.async
		{
			if condition()
			{
				if let thenIndex = self.index(for:label, type:BXScriptCommand_then.self)			// Jump to "then"
				{
					scriptEngine?.commandIndex = thenIndex
				}
			}
			else
			{
				if let elseIndex = self.index(for:label, type:BXScriptCommand_else.self)			// Jump to "else"
				{
					scriptEngine?.commandIndex = elseIndex + 1 // Important: jump to index AFTER "else", because else command jumps to "endif"
				}
				else if let endifIndex = self.index(for:label, type:BXScriptCommand_endif.self)		// If there is no "else" then jump to "endif" instead
				{
					scriptEngine?.commandIndex = endifIndex
				}
			}
			
			completionHandler?()
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command provides a label for the "then"

public struct BXScriptCommand_then : BXScriptCommand, BXLabeledScriptCommand
{
	public var label:String
	
	public weak var scriptEngine:BXScriptEngine? = nil
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	
	public func execute()
	{
		self.queue.async
		{
			completionHandler?() // Nothing to do here, just call completionHandler
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command  provides a label for the "else" and jumps directly to the "endif"

public struct BXScriptCommand_else : BXScriptCommand, BXLabeledScriptCommand
{
	public var label:String
	
	public weak var scriptEngine:BXScriptEngine? = nil
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	
	public func execute()
	{
		if let endifIndex = self.index(for:label, type:BXScriptCommand_endif.self)
		{
			scriptEngine?.commandIndex = endifIndex	// Jump to "endif"
		}
			
		completionHandler?()
	}
}


//----------------------------------------------------------------------------------------------------------------------


/// This command provides a label for the "endif"

public struct BXScriptCommand_endif : BXScriptCommand, BXLabeledScriptCommand
{
	public var label:String
	
	public weak var scriptEngine:BXScriptEngine? = nil
	public var queue:DispatchQueue = .main
	public var completionHandler:(()->Void)? = nil
	
	public func execute()
	{
		self.queue.async
		{
			completionHandler?() // Nothing to do here, just call completionHandler
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------
