//
//  FormViewTests.swift
//  FormViewTests
//
//  Created by Thomas Lextrait on 12/22/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import XCTest
@testable import FormView

class FormViewTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /**
     Tests building a simple form, filling it and recovering the data
    */
    func testSimpleFormShouldResolveAnOutput() {
        class Person {
            var firstname = ""
        }
        
        let form = UIQuickFormView<Person>()
        
        let firstnameField = UIActiveInput<String>()
        
        let firstnameBinding = form.bind(input: firstnameField) { (p: Person, input: UIActiveInput<String>) in
            guard let firstname = input.output else {
                return
            }
            p.firstname = firstname
        }
        form.addRow([FormElement(firstnameBinding, size: 1)])
        
        // Pretend typing stuff into the fields
        firstnameField.output = "John"
        
        // Test string outputs
        XCTAssertEqual(firstnameField.text, "John")
        
        // Test generic outputs
        XCTAssertEqual(firstnameField.output, "John")
        
        // Ask the form to build the model
        let person = form.resolve(model: Person())
        
        XCTAssertEqual(person.firstname, "John")
    }
    
    /**
     Tests building a complex form with multiple inputs and spacers, filling it and recovering the data
     */
    func testComplexFormShouldResolveAnOutput() {
        class Person {
            var firstname = ""
            var lastname = ""
            var age = 1
        }
        
        let form = UIQuickFormView<Person>()
        
        let firstnameField = UIActiveInput<String>()
        let lastnameField = UIActiveInput<String>()
        let ageField = UIActiveInput<Int>()
        
        let firstnameBinding = form.bind(input: firstnameField) { (p: Person, input: UIActiveInput<String>) in
            guard let firstname = input.output else {
                return
            }
            p.firstname = firstname
        }
        let lastnameBinding = form.bind(input: lastnameField) { (p: Person, input: UIActiveInput<String>) in
            guard let lastname = input.output else {
                return
            }
            p.lastname = lastname
        }
        form.addRow([FormElement(firstnameBinding, size: 1), FormElement.spacer(size: 10), FormElement(lastnameBinding, size: 1)])
        
        let ageBinding = form.bind(input: ageField) { (p: Person, input: UIActiveInput<Int>) in
            guard let age = input.output else {
                return
            }
            p.age = age
        }
        form.addRow([FormElement(ageBinding, size: 1)])
        
        // Pretend typing stuff into the fields
        firstnameField.output = "John"
        lastnameField.output = "Smith"
        ageField.output = 26
        
        // Test string outputs
        XCTAssertEqual(firstnameField.text, "John")
        XCTAssertEqual(lastnameField.text, "Smith")
        XCTAssertEqual(ageField.text, "26")
        
        // Test generic outputs
        XCTAssertEqual(firstnameField.output, "John")
        XCTAssertEqual(lastnameField.output, "Smith")
        XCTAssertEqual(ageField.output, 26)
        
        // Ask the form to build the model
        let person = form.resolve(model: Person())
        
        XCTAssertEqual(person.firstname, "John")
        XCTAssertEqual(person.lastname, "Smith")
        XCTAssertEqual(person.age, 26)
    }
    
    /**
     Test building a form that uses a mix of native and generic inputs, filling it and recovering the data
    */
    func testFormUsingNativeInputsShouldResolveAnOutput() {
        class Person {
            var firstname = ""
            var lastname = ""
            var age = 1
        }
        
        let form = UIQuickFormView<Person>()
        
        let firstnameField = UIActiveInput<String>()
        let lastnameField = UITextField(frame: .zero)   // native input
        let ageField = UIActiveInput<Int>()
        
        let firstnameBinding = form.bind(input: firstnameField) { (p: Person, input: UIActiveInput<String>) in
            guard let firstname = input.output else {
                return
            }
            p.firstname = firstname
        }
        let lastnameBinding = form.bind(input: lastnameField) { (p: Person, input: UITextField) in
            guard let lastname = input.text else {
                return
            }
            p.lastname = lastname
        }
        form.addRow([FormElement(firstnameBinding, size: 1), FormElement.spacer(size: 10), FormElement(lastnameBinding, size: 1)])
        
        let ageBinding = form.bind(input: ageField) { (p: Person, input: UIActiveInput<Int>) in
            guard let age = input.output else {
                return
            }
            p.age = age
        }
        form.addRow([FormElement(ageBinding, size: 1)])
        
        // Pretend typing stuff into the fields
        firstnameField.output = "John"
        lastnameField.text = "Smith"
        ageField.output = 26
        
        // Test string outputs
        XCTAssertEqual(firstnameField.text, "John")
        XCTAssertEqual(lastnameField.text, "Smith")
        XCTAssertEqual(ageField.text, "26")
        
        // Test generic outputs
        XCTAssertEqual(firstnameField.output, "John")
        XCTAssertEqual(lastnameField.text, "Smith")
        XCTAssertEqual(ageField.output, 26)
        
        // Ask the form to build the model
        let person = form.resolve(model: Person())
        
        XCTAssertEqual(person.firstname, "John")
        XCTAssertEqual(person.lastname, "Smith")
        XCTAssertEqual(person.age, 26)
    }
    
}
