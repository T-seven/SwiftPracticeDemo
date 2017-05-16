//
//  TMYExtension.swift
//  TMYSegmentController
//
//  Created by TMY on 2017/5/8.
//  Copyright © 2017年 TMY. All rights reserved.
//

import Foundation
import CoreGraphics


public protocol TMYExtension {}

extension TMYExtension where Self: Any {
    
    /*
     copy 一份数据，do something， return newValue
     
     let frame = CGRect().with { $0.x = 10 }
     */
    public func with(_ block: (inout Self) -> Void) -> Self {
        var copy = self
        block(&copy)
        return copy
    }
    
    /* 
     do something, don't return
     
     tmp.standard.do{ $0.set("tempValue" forKey:"key") }
     */
    public func `do` (_ block: (Self) -> Void) {
        block(self)
    }
}

extension TMYExtension where Self : AnyObject {
    /*
     init object, do something
     
     let label = uilabel().then { $0.text = ""}
     */
    public func then(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}

extension NSObject: TMYExtension {}
extension CGPoint: TMYExtension {}
extension CGRect: TMYExtension {}
extension CGSize: TMYExtension {}
extension CGVector: TMYExtension {}

