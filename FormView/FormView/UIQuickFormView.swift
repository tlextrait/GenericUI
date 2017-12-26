//
//  FormView.swift
//  FormView
//
//  Created by Thomas Lextrait on 12/19/17.
//

import UIKit

public protocol ResolvableBinding: class {
    associatedtype ModelType
    func resolve(_ model: ModelType)
}

/**
 Binds a form input to a keypath on a model
 */
open class UIQuickFormBinding<InputType : UIView, ModelType> : ResolvableBinding {
    var viewElement: UIView?
    var input: InputType?
    var binding: ((ModelType, InputType)->Void)?
    var size: UInt = 1
    
    var isSpacer: Bool {
        return viewElement == nil && input == nil
    }
    
    var view: UIView {
        return (input ?? viewElement) ?? UIView()
    }
    
    var isInput: Bool {
        return input != nil
    }
    
    convenience init(view: UIView?, size: UInt) {
        self.init()
        self.viewElement = view
        self.size = size
    }
    
    convenience init(input: InputType, size: UInt, binding: @escaping (ModelType, InputType)->Void) {
        self.init()
        self.input = input
        self.binding = binding
        self.size = size
    }
    
    static func makeSpacer(size: UInt) -> UIQuickFormBinding {
        return UIQuickFormBinding(view: nil, size: size)
    }
    
    public func resolve(_ model: ModelType) {
        guard let b = binding,
            let i = input else {
            return
        }
        b(model, i)
    }
}

//
// MARK: - Quick Form
//

open class UIQuickFormView<OutputModel, BindingType : ResolvableBinding> : UIView {

    private var inputs = [[BindingType]]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Binds an input to a setter, allowing the form to build the output model
    */
    func bind<Field : UIView>(input: Field, binding: @escaping (OutputModel, Field)->Void) -> UIQuickFormBinding<Field, OutputModel> {
        let formBind = UIQuickFormBinding(input: input, size: 1, binding: binding)
        return formBind
    }
    
    /**
     Binds a view
    */
    func bind(view: UIView) -> UIQuickFormBinding<UIView, OutputModel> {
        let binding = UIQuickFormBinding<UIView, OutputModel>(view: view, size: 1)
        return binding
    }
    
    /**
     Adds a row of views to the form
    */
    func addRow(_ elements: [BindingType]) {
        inputs.append(elements)
    }
    
    /**
     Resolves the output for this form by asking all its inputs to resolve their values
    */
    func resolve(model: OutputModel) -> OutputModel {
        for row in inputs {
            for input in row {
                input.resolve(model as! BindingType.ModelType)
            }
        }
        return model
    }

}
