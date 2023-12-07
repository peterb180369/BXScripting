//
//  Array+Concatenation.swift
//  BXSwiftUtils
//
//  Created by Stefan Fochler on 08.03.18.
//  Copyright © 2018 Boinx Software Ltd. All rights reserved.
//


import Foundation


extension Array where Element: Any
{
    static func +=(lhs: inout [Element], rhs: Element?)
    {
        if let rhs = rhs
        {
            lhs.append(rhs)
        }
    }
    
	static func +=(lhs: inout [Element], rhs: [Element])
	{
        lhs.append(contentsOf:rhs)
	}

	static func +=(lhs: inout [Element], rhs: [Element]?)
	{
		guard let rhs = rhs else { return }
        lhs.append(contentsOf:rhs)
	}
}
