//
//  FormView.swift
//  FormView
//
//  Created by Thomas Lextrait on 12/19/17.
//

import UIKit

fileprivate protocol ResolvableBinding: class {
    associatedtype ModelType
    func resolve(_ model: ModelType)
    var isInput: Bool { get }
}

fileprivate class GenericFormBinding<OutputModelType> : ResolvableBinding {
    public typealias ModelType = OutputModelType
    
    public var isInput: Bool {
        fatalError("Abstract getter")
    }
    
    public func resolve(_ model: GenericFormBinding<ModelType>.ModelType) {
        // abstract
        fatalError("Abstract method")
    }
}

/**
 Binds a form input to a keypath on a model
 */
fileprivate class UIQuickFormBinding<InputType : UIView, ModelType> : GenericFormBinding<ModelType> {
    var viewElement: UIView?
    var input: InputType?
    var binding: ((ModelType, InputType)->Void)?
    var size: UInt = 1  // amount of space the view should take horizontally, as a proportion of whatever the total is for the row it is in
    let identifier = UUID()
    
    var isSpacer: Bool {
        return viewElement == nil && input == nil
    }
    
    var view: UIView {
        return (input ?? viewElement) ?? UIView()
    }
    
    public override var isInput: Bool {
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
    
    public override func resolve(_ model: ModelType) {
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

open class UIQuickFormView<OutputModel> : UIView {

    /*
    bindings organized by row, the way they should come out visually (the UUID is used to look up the bindings in the index)
    */
    private var viewsAndInputs = [[UUID]]()
    
    /*
    maps a UUID to a UIQuickFormBinding, has to be Any because there are mixed types
    */
    private var bindingIndex = [UUID : GenericFormBinding<OutputModel>]()
    
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
    func bind<Field : UIView>(input: Field, binding: @escaping (OutputModel, Field)->Void) -> UUID {
        let formBind = UIQuickFormBinding(input: input, size: 1, binding: binding)
        bindingIndex[formBind.identifier] = formBind
        return formBind.identifier
    }
    
    /**
     Binds a view
    */
    func bind(view: UIView) -> UUID {
        let binding = UIQuickFormBinding<UIView, OutputModel>(view: view, size: 1)
        bindingIndex[binding.identifier] = binding
        return binding.identifier
    }
    
    /**
     Adds a row of views to the form, by their identifiers
    */
    func addRow(_ elements: [UUID]) {
        for uuid in elements {
            assert(bindingIndex[uuid] != nil, "Tried to add an element that has no binding")
        }
        
        // In production: ditch any elements that don't have a binding
        viewsAndInputs.append(elements.filter({ (uuid: UUID) -> Bool in
            return bindingIndex[uuid] != nil
        }))
    }
    
    /**
     Resolves the output for this form by asking all its inputs to resolve their values
    */
    func resolve(model: OutputModel) -> OutputModel {
        for row in viewsAndInputs {
            
            let rowInputs = row.map({ (identifier: UUID) -> GenericFormBinding<OutputModel> in
                return bindingIndex[identifier]!
            }).filter({ (i: GenericFormBinding<OutputModel>) -> Bool in
                return i.isInput
            })
            
            for input in rowInputs {
                input.resolve(model)
            }
            
        }
        return model
    }

}
