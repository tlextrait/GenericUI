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

/**
 UIQuickFormView allows to easily setup a complex form for gathering OutputModel from the user
 Simply initialize the form, use bind() to bind your inputs and views to the form, addRow() to
 tell the form where to put the inputs/views and how to lay them, and just call resolve()
 when you want to produce the OutputModel from the values in the inputs
 */
open class UIQuickFormView<OutputModel> : UIView {
    
    /*
     bindings organized by row, the way they should come out visually (the UUID is used to look up the bindings in the index)
     */
    private var viewsAndInputs = [[FormElement]]()
    
    /*
     maps a UUID to a UIQuickFormBinding, has to be Any because there are mixed types
     */
    private var bindingIndex = [UUID : AbstractGenericFormBinding<OutputModel>]()
    
    // UI Settings
    var viewVerticalSpacing: CGFloat = 5.0
    var viewHorizontalSpacing: CGFloat = 5.0
    var defaultSpacerHeight: CGFloat = 10.0
    
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
    func bind<Field : UIView>(input: Field, binding: @escaping (inout OutputModel, Field)->Void) -> UUID {
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
    func resolve(model: inout OutputModel) -> OutputModel {
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
                input.resolve(&model)
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
// MARK: Form UI
//

extension UIQuickFormView {
    
    func setRecommendedContentPriorities() {
        setRecommendedContentCompressionPriorities()
        setRecommendedContentHuggingPriorities()
    }
    
    func setRecommendedContentCompressionPriorities() {
        setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    func setRecommendedContentHuggingPriorities() {
        setContentHuggingPriority(.defaultHigh, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .vertical)
    }
    
    /**
     This effectively builds the UI. Do not call this to refresh the UI as it is destructive.
    */
    func build() {
        // Remove everything from the view to start over if necessary
        if !subviews.isEmpty {
            for view in subviews {
                view.removeFromSuperview()
            }
        }
        
        // @TODO: Needed?
        translatesAutoresizingMaskIntoConstraints = false
        
        var firstViewInPreviousRow: UIView?
        var rCounter = 0
        
        for row in mappedViews {
            
            if row.isEmpty {
                continue
            }
            
            let isFirstRow = (firstViewInPreviousRow == nil)
            let isLastRow = (rCounter == mappedViews.count - 1)
            let firstViewInThisRow = row.first!.view
            var rowTotalSize: UInt = 0
            for e in row {
                rowTotalSize += e.size
            }
            var previousViewInSameRow: UIView?
            var vCounter = 0
            
            for viewSize in row {
                let isFirstViewInThisRow = (previousViewInSameRow == nil)
                let isLastViewInThisRow = (vCounter == row.count - 1)
                
                let view = viewSize.view
                view.translatesAutoresizingMaskIntoConstraints = false
                addSubview(view)
                
                //
                // Setup constraints
                //
                
                view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
                view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
                
                // Top
                if isFirstRow {
                    view.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
                } else {
                    view.topAnchor.constraint(equalTo: firstViewInPreviousRow!.bottomAnchor, constant: viewVerticalSpacing).isActive = true
                }
                
                // Left
                if isFirstViewInThisRow {
                    view.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
                } else {
                    view.leadingAnchor.constraint(equalTo: previousViewInSameRow!.trailingAnchor, constant: viewHorizontalSpacing).isActive = true
                }
                
                // Right
                if isLastViewInThisRow {
                    view.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
                }
                
                // Bottom
                if isLastRow {
                    view.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
                }
                
                // Width
                let sizeMultiplier: CGFloat = row.count > 1 ? CGFloat(viewSize.size) / CGFloat(rowTotalSize) : 1.0
                view.widthAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.widthAnchor, multiplier: sizeMultiplier).isActive = true
                
                // Height
                if row.count == 1 && viewSize.isSpacer {
                    // if the only view in the row is a spacer, then it needs a height because the UIView has no intrinsinct height
                    view.heightAnchor.constraint(equalToConstant: defaultSpacerHeight)
                }
                
                if firstViewInPreviousRow == nil {
                    firstViewInPreviousRow = view
                }
                previousViewInSameRow = view
                vCounter+=1
            }
            
            firstViewInPreviousRow = firstViewInThisRow
            previousViewInSameRow = nil
            rCounter+=1
        }
    }
    
    /**
     Maps all the bindings and form elements into appropriate views, ordered by row. Detects spacers and converts them to UIView
    */
    var mappedViews: [[ViewSize]] {
        return viewsAndInputs.map { (farray: [FormElement]) -> [ViewSize] in
            return farray.map({ (f: FormElement) -> ViewSize in
                var view = UIView()
                if !f.isSpacer {
                    if let uuid = f.identifier,
                        let binding = bindingIndex[uuid] {
                        view = binding.view
                    } else {
                        assert(false, "Couldn't find the binding")
                    }
                }
                return ViewSize(size: f.size, view: view, isSpacer: f.isSpacer)
            })
        }
    }
    
    struct ViewSize {
        var size: UInt
        var view: UIView
        var isSpacer: Bool
        init(size: UInt, view: UIView, isSpacer: Bool = false) {
            self.size = size
            self.view = view
            self.isSpacer = isSpacer
        }
    }
    
}


//
// MARK: Public API
//

public struct FormElement {
    var identifier: UUID?
    var size: UInt
    
    init(_ identifier: UUID, size: UInt = 1) {
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
    func resolve(_ model: inout ModelType)
    var isInput: Bool { get }
    var view: UIView { get }
}

/**
 AbstractGenericFormBinding is used as an abstract that only carries the OutputModel generic.
 This allows UIQuickFormView to reference multiple bindings for mixed types of inputs but the same output model
 */
fileprivate class AbstractGenericFormBinding<OutputModelType> : ResolvableBinding {
    typealias ModelType = OutputModelType
    
    init() {
        // do nothing
    }
    
    var isInput: Bool {
        fatalError("Abstract getter")
    }
    
    var view: UIView {
        fatalError("Abstract getter")
    }
    
    func resolve(_ model: inout AbstractGenericFormBinding<ModelType>.ModelType) {
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
    var binding: ((inout ModelType, InputType)->Void)?
    let identifier = UUID()
    
    override var view: UIView {
        return (input ?? viewElement) ?? UIView()
    }
    
    override var isInput: Bool {
        return input != nil
    }
    
    convenience init(view: UIView?) {
        self.init() // may call the abstract initializer if 'self' is believed to be a AbstractGenericFormBinding
        self.viewElement = view
    }
    
    convenience init(input: InputType, binding: @escaping (inout ModelType, InputType)->Void) {
        self.init() // may call the abstract initializer if 'self' is believed to be a AbstractGenericFormBinding
        self.input = input
        self.binding = binding
    }
    
    override func resolve(_ model: inout ModelType) {
        guard let b = binding,
            let i = input else {
            assert(false, "Failed to find the input for a binding")
            return
        }
        b(&model, i)
    }
}
