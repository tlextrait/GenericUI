//
//  UIActiveInput.swift
//  FormView
//
//  Created by Thomas Lextrait on 12/19/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import UIKit

/**
 UIActiveInput is a cool customizable text-based input. Best used in a form with multiple inputs as it displays
 in a user-friendly manner which input is "active"
 */
open class UIActiveInput<OutputType : StringTwoWayConvertible & BestKeyboardType> : UIView, UITextFieldDelegate {
    
    /**
     User this initializer if you have a custom frame you want to use for the input
     @param frame
    */
    public convenience override init(frame: CGRect) {
        self.init(frame: frame, label: "INPUT")
    }
    
    /**
     Use this initializer if you're planning on using autolayout
     @param label (optional)
    */
    public convenience init(label: String = "INPUT") {
        self.init(frame: .zero, label: label)
    }
    
    /**
     User this initializer if you have a custom frame you want to use for the input
     @param frame
     @param label
     */
    public init(frame: CGRect, label: String) {
        super.init(frame: frame)
        
        setupViews()
        setupGestures()
        
        // Auto-setup keyboard
        keyboardType = OutputType.bestKeyboardType
        
        // Label
        self.label.text = label
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var inputField = UIInputField<OutputType>(frame: .zero)
    private var activeIndicatorView = UIView(frame: .zero)
    
    /**
     Text label
    */
    open var label = UILabel(frame: .zero) {
        didSet {
            label.removeConstraints(label.constraints)
            setupLabelConstraints()
            layoutSubviews()
        }
    }
    
    /**
     Width for the indicator
    */
    open var indicatorWidth: CGFloat = UIActiveInput.defaultIndicatorWidth {
        didSet {
            activeIndicatorView.removeConstraints(activeIndicatorView.constraints)
            setupIndicatorConstraints()
        }
    }
    
    /**
     Color for the indicator
    */
    open var activeColor: UIColor = UIActiveInput.defaultIndicatorColor {
        didSet {
            activeIndicatorView.backgroundColor = activeColor
        }
    }
    
    /**
     Background color for the text field
     */
    open var inputColor: UIColor = UIActiveInput.defaultInputBackgroundColor {
        didSet {
            inputField.backgroundColor = inputColor
        }
    }
    
    /**
     Text Field delegate
    */
    open var delegate: UITextFieldDelegate?
    
    /**
     This forces a width on the label for the input. This is used for when we have multiple inputs with different label lengths and we want all inputs to be perfectly aligned.
    */
    open var forcedLabelWidth: CGFloat? {
        didSet {
            label.removeConstraints(label.constraints)
            setupLabelConstraints()
        }
    }
    
    //
    // MARK: - Actions & Gestures
    //
    
    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapLabel(_:)))
        tap.cancelsTouchesInView = true
        tap.isEnabled = true
        
        label.addGestureRecognizer(tap) // gestures on the label
        addGestureRecognizer(tap)       // gestures on the background view
    }
    
    @objc func didTapLabel(_ sender: UIGestureRecognizer) {
        let _ = becomeFirstResponder()
    }
    
    //
    // MARK: - Design Overrides
    //
    
    override open var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: totalHeight)
    }
    
    
    //
    // MARK: - Responder Overrides (can't go into an extension because of the generic)
    //
    
    override open func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        if !inputField.becomeFirstResponder() {
            return false
        }
        return true
    }
    
    override open func resignFirstResponder() -> Bool {
        if !inputField.resignFirstResponder() {
            return false
        }
        super.resignFirstResponder()
        return true
    }
    
    //
    // MARK: - UITextFieldDelegate (can't go into an extension because of the generic)
    //
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldBeginEditing?(textField) ?? true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // Custom logic
        hasGainedFocus()
        //
        
        delegate?.textFieldDidBeginEditing?(textField)
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldEndEditing?(textField) ?? true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        
        // Custom logic
        hasLostFocus()
        //
        
        delegate?.textFieldDidEndEditing?(textField)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        
        // Custom logic
        hasLostFocus()
        //
        
        delegate?.textFieldDidEndEditing?(textField, reason: reason)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldClear?(textField) ?? true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldReturn?(textField) ?? true
    }
    
    //
    // MARK: - Accessibility
    //
    
    override open var accessibilityHint: String? {
        set { inputField.accessibilityHint = newValue }
        get { return inputField.accessibilityHint }
    }
    
    override open var accessibilityValue: String? {
        set { inputField.accessibilityValue = newValue }
        get { return inputField.accessibilityValue }
    }
    
    override open var accessibilityLabel: String? {
        set { inputField.accessibilityLabel = newValue }
        get { return inputField.accessibilityLabel }
    }
    
    @available(iOS 11, *)
    override open var accessibilityAttributedHint: NSAttributedString? {
        set { inputField.accessibilityAttributedHint = newValue }
        get { return inputField.accessibilityAttributedHint }
    }
    
    @available(iOS 11, *)
    override open var accessibilityAttributedValue: NSAttributedString? {
        set { inputField.accessibilityAttributedValue = newValue }
        get { return inputField.accessibilityAttributedValue }
    }
    
    @available(iOS 11, *)
    override open var accessibilityAttributedLabel: NSAttributedString? {
        set { inputField.accessibilityAttributedLabel = newValue }
        get { return inputField.accessibilityAttributedLabel }
    }
    
    override open var accessibilityLanguage: String? {
        set { inputField.accessibilityLanguage = newValue }
        get { return inputField.accessibilityLanguage }
    }
    
    @available(iOS 11, *)
    override open var accessibilityContainerType: UIAccessibilityContainerType {
        set { inputField.accessibilityContainerType = newValue }
        get { return inputField.accessibilityContainerType }
    }
    
    override open var isAccessibilityElement: Bool {
        set { inputField.isAccessibilityElement = newValue }
        get { return inputField.isAccessibilityElement }
    }
}

//
// MARK: - Text Field Getters & Setters
//

extension UIActiveInput {
    
    /**
     Returns the text field's output in the generic type specified for the input
     */
    open var output: OutputType? {
        get {
            return inputField.output
        }
        set {
            text = newValue?.description
        }
    }
    
    /**
     Gets or sets the text for the text field
     */
    open var text: String? {
        get {
            return inputField.text
        }
        set {
            inputField.text = newValue
        }
    }
    
    /**
     Gets or sets the placeholder for the text field
     */
    open var placeholder: String? {
        get {
            return inputField.placeholder
        }
        set {
            inputField.placeholder = newValue
        }
    }
    
    /**
     Gets or sets the font of the text field
    */
    open var font: UIFont? {
        get {
            return inputField.font
        }
        set {
            inputField.font = newValue
        }
    }
    
    /**
     Gets or sets the text color for the text field
    */
    open var textColor: UIColor? {
        get {
            return inputField.textColor
        }
        set {
            inputField.textColor = textColor
        }
    }
    
    /**
     Returns the CALayer for the text field
    */
    open var inputLayer: CALayer {
        return inputField.layer
    }
    
    /**
     Gets or sets the keyboardType for the text field
    */
    open var keyboardType: UIKeyboardType {
        get {
            return inputField.keyboardType
        }
        set {
            inputField.keyboardType = newValue
        }
    }
    
}

//
// MARK: - Design & Sizes
//

fileprivate extension UIActiveInput {
 
    var inputHeight: CGFloat {
        return (font?.pointSize ?? UIActiveInput.defaultFontSize) * 2.0
    }
    
    var totalHeight: CGFloat {
        return inputHeight + layoutMargins.top + layoutMargins.bottom
    }
    
    // MARK: Defaults
    
    static var defaultFontSize: CGFloat { return 13.0 }
    static var defaultBackgroundColor: UIColor { return .white }
    static var defaultCornerRadius: CGFloat { return 3.0 }
    static var defaultLabelColor: UIColor { return .gray }
    static var defaultInputTextColor: UIColor { return .black }
    static var defaultInputBackgroundColor: UIColor { return .white }
    static var defaultIndicatorCornerRadius: CGFloat { return 1.0 }
    static var defaultIndicatorWidth: CGFloat { return 3.0 }
    static var defaultIndicatorColor: UIColor { return UIButton().tintColor }
    static var defaultLayoutMargins: UIEdgeInsets { return UIEdgeInsets(top: 5.0, left: 8.0, bottom: 5.0, right: 8.0) }
}

//
// MARK: - View Events
//

fileprivate extension UIActiveInput {
    
    /**
     Called when the input has gained focus
    */
    func hasGainedFocus() {
        if activeIndicatorView.alpha == 1 {
            return
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            self.activeIndicatorView.alpha = 1
        }, completion: { _ in
        })
    }
    
    /**
     Called when the input has lost focus
     */
    func hasLostFocus() {
        if activeIndicatorView.alpha == 0 {
            return
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            self.activeIndicatorView.alpha = 0
        }, completion: { _ in
        })
    }
    
}

//
// MARK: - View Setup
//

fileprivate extension UIActiveInput {
    
    func setupViews() {
        layoutMargins = UIActiveInput.defaultLayoutMargins
        backgroundColor = UIActiveInput.defaultBackgroundColor
        layer.cornerRadius = UIActiveInput.defaultCornerRadius
        
        label.font = UIFont.systemFont(ofSize: UIActiveInput.defaultFontSize)
        label.textColor = UIActiveInput.defaultLabelColor
        label.text = "INPUT"
        
        font = UIFont.systemFont(ofSize: UIActiveInput.defaultFontSize)
        textColor = UIActiveInput.defaultInputTextColor
        inputColor = UIActiveInput.defaultInputBackgroundColor
        inputField.delegate = self
        
        activeIndicatorView.alpha = 0
        activeIndicatorView.backgroundColor = activeColor
        activeIndicatorView.layer.cornerRadius = UIActiveInput.defaultIndicatorCornerRadius
        
        addSubview(inputField)
        addSubview(label)
        addSubview(activeIndicatorView)
        
        setupOwnConstraints()
        setupInputConstraints()
        setupLabelConstraints()
        setupIndicatorConstraints()
    }
    
    func setupOwnConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        
        setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    func setupInputConstraints() {
        inputField.translatesAutoresizingMaskIntoConstraints = false
        let margins = layoutMarginsGuide
        
        // Alignments
        inputField.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        inputField.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        inputField.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: layoutMargins.left).isActive = true
        inputField.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        inputField.heightAnchor.constraint(equalToConstant: inputHeight).isActive = true
        
        // Content Compression Priorities
        inputField.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        inputField.setContentHuggingPriority(.defaultLow, for: .vertical)
        inputField.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        inputField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    func setupLabelConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        let margins = layoutMarginsGuide
        
        // Alignment
        label.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: indicatorWidth).isActive = true
        label.heightAnchor.constraint(equalToConstant: totalHeight - layoutMargins.top - layoutMargins.bottom)
        label.lastBaselineAnchor.constraint(equalTo: inputField.lastBaselineAnchor).isActive = true // align with the input's baseline so things are align vertically
        
        if let labelWidth = forcedLabelWidth {
            label.widthAnchor.constraint(equalToConstant: labelWidth).isActive = true
        }
        
        // Content Compression Priorities
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    func setupIndicatorConstraints() {
        activeIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        let margins = layoutMarginsGuide
        
        // Alignment
        activeIndicatorView.topAnchor.constraint(equalTo: margins.topAnchor, constant: -layoutMargins.top).isActive = true
        activeIndicatorView.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: -layoutMargins.left).isActive = true
        activeIndicatorView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: layoutMargins.bottom).isActive = true
        activeIndicatorView.widthAnchor.constraint(equalToConstant: indicatorWidth).isActive = true
        
        // Compression
        activeIndicatorView.setContentCompressionResistancePriority(.required, for: .vertical)
        activeIndicatorView.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
    }
    
}
