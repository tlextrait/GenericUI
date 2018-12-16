//
//  UIRepresentable.swift
//  FormView
//
//  Created by Thomas Lextrait on 12/19/17.
//  Copyright © 2017 LycheeApps. All rights reserved.
//

import UIKit

public protocol StringTwoWayConvertible : CustomStringConvertible {
    init?(_ text: String)
}

public protocol BestKeyboardType {
    static var bestKeyboardType: UIKeyboardType { get }
}

//
// MARK: - Pre-built conformance
//

extension Int : StringTwoWayConvertible {}
extension UInt : StringTwoWayConvertible {}
extension Int8 : StringTwoWayConvertible {}
extension Int16 : StringTwoWayConvertible {}
extension Int32 : StringTwoWayConvertible {}
extension Int64 : StringTwoWayConvertible {}
extension Double : StringTwoWayConvertible {}
extension CGFloat : StringTwoWayConvertible {
    public init?(_ text: String) {
        if let d = Double(text) {
            self.init(d)
        } else {
            return nil
        }
    }
}
extension Float : StringTwoWayConvertible {}
extension Float80 : StringTwoWayConvertible {}
extension String : StringTwoWayConvertible {
    public init?(_ text: String) {
        self.init(text as NSString)
    }
}

//
// MARK: - Keyboard type mappings
//

extension Int : BestKeyboardType {
    public static var bestKeyboardType: UIKeyboardType { return .numberPad }
}

extension UInt : BestKeyboardType {
    public static var bestKeyboardType: UIKeyboardType { return .numberPad }
}

extension Int16 : BestKeyboardType {
    public static var bestKeyboardType: UIKeyboardType { return .numberPad }
}

extension Int32 : BestKeyboardType {
    public static var bestKeyboardType: UIKeyboardType { return .numberPad }
}

extension Int64 : BestKeyboardType {
    public static var bestKeyboardType: UIKeyboardType { return .numberPad }
}

extension Double : BestKeyboardType {
    public static var bestKeyboardType: UIKeyboardType { return .decimalPad }
}

extension CGFloat : BestKeyboardType {
    public static var bestKeyboardType: UIKeyboardType { return .decimalPad }
}

extension Float : BestKeyboardType {
    public static var bestKeyboardType: UIKeyboardType { return .decimalPad }
}

extension Float80 : BestKeyboardType {
    public static var bestKeyboardType: UIKeyboardType { return .decimalPad }
}

extension String : BestKeyboardType {
    public static var bestKeyboardType: UIKeyboardType { return .asciiCapable }
}
