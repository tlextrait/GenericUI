//
//  UIInput.swift
//  FormView
//
//  Created by Thomas Lextrait on 12/19/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import UIKit

open class UIInputField<OutputType : StringTwoWayConvertible>: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var output: OutputType? {
        guard let text = self.text else {
            return nil
        }
        if OutputType("") is String {
            return text as? OutputType
        }
        return OutputType(text)
    }
    
}
