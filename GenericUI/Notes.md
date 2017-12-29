#  Notes

Fully generic input:

```

InputViewProtocol {
    setValue(value : RawInputType)
    getValue() -> RawOutputType
    valueChanged()
    gainedFocus()
    lostFocus()
}

Input<IdealOutputType, InputView<RawInputType, RawOutputType> : InputViewProtocol>


// Example:

UIActiveInput : Input<Person, UITextField<String, String>>

```
