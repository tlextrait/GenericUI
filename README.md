<div style="text-align:center"><img alt="Generic User Interface" src="Media/preview.gif" width="300"/></div>

#  GenericUI

GenericUI provides you with beautiful and generic UI elements for your iOS projects. For now it just focuses on inputs and forms but there's a lot more to come.

## Contents
* [GenericUI](#genericui)
    * [Background](#background)
* [Components](#components)
    * [Inputs](#inputs)
    * [Forms](#forms)
* [Examples](#examples)
    * [Input for a `String`](#input-for-a-string)
    * [Input for a `UInt`](#input-for-a-uint)
    * [Input for a custom object `T`](#input-for-a-custom-object-t)
    * [Customize the `UIActiveInput`](#customize-the-uiactiveinput)
        * [Styles](#styles)
        * [Text Input Delegate](#text-input-delegate)
        * [Touch Events](#touch-events)
        * [Accessibility](#accessibility)

## Background

I decided to start with inputs and forms because I feel like we tend to write a lot of boiler plate code there. We use `UITextField` a lot to
gather information from the user, even information that shouldn't be represented as a string. Then we do conversions, sanitization, error
handling and so forth. We usually duplicate this code for every text input, and from a project to another. Then we assemble all the values
from our inputs to build a model, which may involve some boiler plate code too. Generic UI also solves the problem of laying out your
views using AutoLayout. Laying out a form is very complex because we have a lot of inputs of varying dimensions. GenericUI solves
both the problem of laying things out for you using a simple high level API as well as guaranteeing type safety at compile time using
generics.

# Components

Only a few components are available at this time. They're super customizable and should enable you to save a lot of time and code.

## Inputs
### `UIInputField<OutputType>`

This is a very simple generic extension to the `UITextField`  that attempts to convert the input to the generic type.

### `UIActiveInput<OutputType>`

This is a more sophisticated input that combines multiple views, based on the `UIInputField<OutputType>`. It is highly customizable
but by default comes with a nice design, a label, an animated indicator showing if the input is active and more. It exposes the raw
text field's API including accessibility features.

## Forms
### `UIQuickForm<ModelType>`

A simple component that allows you to build beautiful forms that can gather a generic type of model from the user for you. `UIQuickForm` takes
care of all the layout for you.

## more...
a lot more to come...

# Examples

## Input for a `String`

The code below will make an input labeled "Firstname". It allows the user to enter text and the output will be a `String`.

```swift
let input = UIActiveInput<String>("Firstname")
addSubview(input)
let firstname: String = input.output // returns String?
```

## Input for a `UInt`

Below is an example of an input that gathers an unsigned integer from the user. The ouput is a `UInt`. The `UIActiveInput` is
smart and automatically sets the keyboard to a numeric pad with no decimal point.

```swift
let input = UIActiveInput<UInt>("Age")
addSubview(input)
let age: UInt = input.output // returns UInt?
```

## Input for a custom object `T`

You may gather your own type of model from a `UIActiveInput`, however it will need to conform with a couple protocols,
namely: `StringTwoWayConvertible` and `BestKeyboardType`. The purpose of these protocols is to ensure your object provides
a way to be converted to and from a `String` (since `UIActiveInput` is based on top of the native `UITextField`) and
specifies the best type of iOS keyboard to be used. The `StringTwoWayConvertible`  is a way for you to provide a custom
String transform.

Using extensions, you may also enable existing or third party types to be returned by the `UIActiveInput`.

Example:

```swift
class MyCustomType : StringTwoWayConvertible, BestKeyboardType {
    var number: Double
    
    init?(_ text: String) {
        // Write your own String -> Object transform
        guard let n = Double(text) else {
            return
        }
        number = n
    }
    
    var description: String {
        // Write your own Object -> String transform
        return "\(number)"
    }
    
    static var bestKeyboardType: UIKeyboardType {
        return .decimalPad
    }
}

let input = UIActiveInput<MyCustomType>()
```

## Customize the `UIActiveInput`

<img alt="Generic User Interface" src="Media/firstname-field.png" width="300"/>

`UIActiveInput` is deeply customizable and is built right on top of the native `UITextField`.

### Styles

Here are some of the properties you have access to that allow you to customize the style:
* `input.label` exposes the `UILabel` object, which you may directly customize or even remove.
* `input.inputColor` is the background color of the text field.
* `input.backgroundColor` is the background color of the whole element.
* `input.activeColor` is the color of the little vertical indicator, blue by default.
* `input.indicatorWidth` is the width of the active indicator, 2.0 by default.
* `input.forcedLabelWidth` allows you to force the label to be a certain width. This is useful when you have multiple inputs and you want the left edge of all text fields to align.
* `input.placeHolder` sets the placeholder for the text input.
* `input.font` sets the font for the text input.
* `input.textColor` sets the text color for the text input.
* `input.layer` gives you access to the design layer of the whole element if you'd like to make deeper customizations.
* `input.inputLayer` gives you access to the design layer of the text input.
* `input.keyboardType` lets you set a keyboard type for the text input (note this is always set automatically, but you may override it by setting it manually).
* `input.layoutMargins` lets you customize the margins within the element (space between the label and text input from the edges of the `UIActiveInput`).

*A lot more that I won't get into here...* `UIActiveInput` is a subclass of `UITextField`, which is a sublcass of `UIView` so all the properties and methods you
expect to find on those you will find on `UIActiveInput`.

### Text Input Delegate

`input.delegate` lets you designate a delegate for the embedded text field.

### Touch Events

By default, the text field will become `firstResponder` if the user taps anywhere on the `UIActiveInput`, including the label. You may also do so
programmatically by simply calling `input.becomeFirstResponder()` and `input.resignFirstResponder()`.

### Accessibility

The `UIActiveInput` provides you with all the standard accessbility functionality and relays all those calls to the embedded text input
(blind users should "see" the `UIActiveInput` the same as a regular `UITextField`).
