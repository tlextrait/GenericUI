//
//  FormView.swift
//  FormView
//
//  Created by Thomas Lextrait on 12/19/17.
//

import UIKit

//
// MARK: - Quick Form
//

open class UIQuickFormView<OutputModel> : UIView {
    
    /*
     bindings organized by row, the way they should come out visually (the UUID is used to look up the bindings in the index)
     */
    private var viewsAndInputs = [[FormElement]]()
    
    /*
     maps a UUID to a UIQuickFormBinding, has to be Any because there are mixed types
     */
    private var bindingIndex = [UUID : AbstractGenericFormBinding<OutputModel>]()
    
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
        let formBind = UIQuickFormBinding(input: input, binding: binding)
        bindingIndex[formBind.identifier] = formBind
        return formBind.identifier
    }
    
    /**
     Binds a view
     */
    func bind(view: UIView) -> UUID {
        let binding = UIQuickFormBinding<UIView, OutputModel>(view: view)
        bindingIndex[binding.identifier] = binding
        return binding.identifier
    }
    
    /**
     Adds a row of views to the form, by their identifiers
     */
    func addRow(_ elements: [FormElement]) {
        for el in elements {
            assert(el.isSpacer || hasBinding(for: el), "Tried to add an input that has no binding")
        }
        
        // In production: ditch any inputs that don't have a binding
        viewsAndInputs.append(elements.filter({ (el: FormElement) -> Bool in
            return el.isSpacer || hasBinding(for: el)
        }))
    }
    
    /**
     Resolves the output for this form by asking all its inputs to resolve their values
     */
    func resolve(model: OutputModel) -> OutputModel {
        for row in viewsAndInputs {
            
            let rowInputs = row.filter({ (el: FormElement) -> Bool in
                // Filter out spacers
                return !el.isSpacer
            }).map({ (el: FormElement) -> AbstractGenericFormBinding<OutputModel> in
                // Map form elements to bindings
                return binding(for: el)!
            }).filter({ (i: AbstractGenericFormBinding<OutputModel>) -> Bool in
                // Filter out non-inputs
                return i.isInput
            })
            
            for input in rowInputs {
                input.resolve(model)
            }
            
        }
        return model
    }
    
    private func hasBinding(for element: FormElement) -> Bool {
        guard let id = element.identifier else {
            return false
        }
        return bindingIndex[id] != nil
    }
    
    private func binding(for element: FormElement) -> AbstractGenericFormBinding<OutputModel>? {
        guard let id = element.identifier else {
            return nil
        }
        return bindingIndex[id]
    }
    
}

//
// MARK: UI & Public API
//

public struct FormElement {
    var identifier: UUID?
    var size: UInt
    
    init(_ identifier: UUID, size: UInt) {
        assert(size > 0, "Size should be greater than 0")
        self.identifier = identifier
        self.size = size
    }
    
    // Only used for making spacers
    private init(size: UInt) {
        self.size = size
    }
    
    static func spacer(size: UInt) -> FormElement {
        return FormElement(size: size)
    }
    
    var isSpacer: Bool {
        return identifier == nil
    }
}

//
// MARK: Private API
//

fileprivate protocol ResolvableBinding: class {
    associatedtype ModelType
    func resolve(_ model: ModelType)
    var isInput: Bool { get }
}

/**
 AbstractGenericFormBinding is used as an abstract that only carries the OutputModel generic.
 This allows UIQuickFormView to reference multiple bindings for mixed types of inputs but the same output model
 */
fileprivate class AbstractGenericFormBinding<OutputModelType> : ResolvableBinding {
    public typealias ModelType = OutputModelType
    
    init() {
        // do nothing
    }
    
    public var isInput: Bool {
        fatalError("Abstract getter")
    }
    
    public func resolve(_ model: AbstractGenericFormBinding<ModelType>.ModelType) {
        // abstract
        fatalError("Abstract method")
    }
}

/**
 Binds a form input to a keypath on a model
 */
fileprivate class UIQuickFormBinding<InputType : UIView, ModelType> : AbstractGenericFormBinding<ModelType> {
    var viewElement: UIView?
    var input: InputType?
    var binding: ((ModelType, InputType)->Void)?
    let identifier = UUID()
    
    var view: UIView {
        return (input ?? viewElement) ?? UIView()
    }
    
    public override var isInput: Bool {
        return input != nil
    }
    
    convenience init(view: UIView?) {
        self.init() // may call the abstract initializer if 'self' is believed to be a AbstractGenericFormBinding
        self.viewElement = view
    }
    
    convenience init(input: InputType, binding: @escaping (ModelType, InputType)->Void) {
        self.init() // may call the abstract initializer if 'self' is believed to be a AbstractGenericFormBinding
        self.input = input
        self.binding = binding
    }
    
    public override func resolve(_ model: ModelType) {
        guard let b = binding,
            let i = input else {
            assert(false, "Failed to find the input for a binding")
            return
        }
        b(model, i)
    }
}
