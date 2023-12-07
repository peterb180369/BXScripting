//
//  DispatchQueue+Main.swift
//  BXSwiftUtils
//
//  Created by Stefan Fochler on 23.05.18.
//  Copyright © 2018 Boinx Software Ltd. & Imagine GbR. All rights reserved.
//

import Foundation


//----------------------------------------------------------------------------------------------------------------------


extension DispatchQueue
{
    func asyncIfNeeded(_ block:@escaping ()->Void)
    {
        assert(self === DispatchQueue.main, "\(#function) is only available for the main queue.")
        
        if Thread.isMainThread
        {
            block()
        }
        else
        {
			self.async(execute: block)
        }
    }
}


//----------------------------------------------------------------------------------------------------------------------
