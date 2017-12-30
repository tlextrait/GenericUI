//
//  FormViewTests.swift
//  FormViewTests
//
//  Created by Thomas Lextrait on 12/22/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import XCTest
@testable import GenericUI

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
        
        let firstnameBinding = form.bind(input: firstnameField) { (p, input) in
            guard let firstname = input.output else {
                // Any error handling would go here :)
                return (false, nil)
            }
            p.firstname = firstname
            return (true, nil)
        }
        form.addRow([FormElement(firstnameBinding, size: 1)])
        
        // Pretend typing stuff into the fields
        firstnameField.output = "John"
        
        // Test string outputs
        XCTAssertEqual(firstnameField.text, "John")
        
        // Test generic outputs
        XCTAssertEqual(firstnameField.output, "John")
        
        // Ask the form to build the model
        var person = Person()
        let success = form.resolve(model: &person)
        
        XCTAssertEqual(person.firstname, "John")
        
        XCTAssertTrue(success.0)
        XCTAssertTrue(success.1.isEmpty)
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
        
        let firstnameBinding = form.bind(input: firstnameField) { (p, input) in
            guard let firstname = input.output else {
                // Any error handling would go here :)
                return (false, nil)
            }
            p.firstname = firstname
            return (true, nil)
        }
        let lastnameBinding = form.bind(input: lastnameField) { (p, input) in
            guard let lastname = input.output else {
                // Any error handling would go here :)
                return (false, nil)
            }
            p.lastname = lastname
            return (true, nil)
        }
        form.addRow([FormElement(firstnameBinding, size: 1), FormElement.spacer(size: 10), FormElement(lastnameBinding, size: 1)])
        
        let ageBinding = form.bind(input: ageField) { (p, input) in
            guard let age = input.output else {
                return (false, nil)
            }
            p.age = age
            return (true, nil)
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
        var person = Person()
        let success = form.resolve(model: &person)
        
        XCTAssertEqual(person.firstname, "John")
        XCTAssertEqual(person.lastname, "Smith")
        XCTAssertEqual(person.age, 26)
        
        XCTAssertTrue(success.0)
        XCTAssertTrue(success.1.isEmpty)
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
        
        let firstnameBinding = form.bind(input: firstnameField) { (p, input) in
            guard let firstname = input.output else {
                // Any error handling would go here :)
                return (false, nil)
            }
            p.firstname = firstname
            return (true, nil)
        }
        let lastnameBinding = form.bind(input: lastnameField) { (p, input) in
            guard let lastname = input.text else {
                // Any error handling would go here :)
                return (false, nil)
            }
            p.lastname = lastname
            return (true, nil)
        }
        form.addRow([FormElement(firstnameBinding, size: 1), FormElement.spacer(size: 10), FormElement(lastnameBinding, size: 1)])
        
        let ageBinding = form.bind(input: ageField) { (p, input) in
            guard let age = input.output else {
                // Any error handling would go here :)
                return (false, nil)
            }
            p.age = age
            return (true, nil)
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
        var person = Person()
        let success = form.resolve(model: &person)
        
        XCTAssertEqual(person.firstname, "John")
        XCTAssertEqual(person.lastname, "Smith")
        XCTAssertEqual(person.age, 26)
        
        XCTAssertTrue(success.0)
        XCTAssertTrue(success.1.isEmpty)
    }
    
    /**
     Test error handling
    */
    func testFormErrorHandling() {
        class Person {
            var firstname = ""
            var lastname = ""
            var age = 1
        }
        
        enum PersonError : Error {
            case tooLong, tooShort, conversion
        }
        
        let form = UIQuickFormView<Person>()
        let firstnameField = UIActiveInput<String>()
        
        let id = form.bind(input: firstnameField) { (person, input) -> (Bool, Error?) in
            guard let name = input.output else {
                return (false, PersonError.conversion)
            }
            if name.count < 10 {
                return (false, PersonError.tooShort)
            }
            if name.count > 20 {
                return (false, PersonError.tooLong)
            }
            person.firstname = name
            return (true, nil)
        }
        form.addRow([FormElement(id)])
        
        var john = Person()
        
        // Try too short
        firstnameField.output = "John"
        var success = form.resolve(model: &john)
        XCTAssertFalse(success.0)
        XCTAssertFalse(success.1.isEmpty)
        XCTAssertEqual(success.1.first! as! PersonError, PersonError.tooShort)
        
        // Try too long
        firstnameField.output = "John John John John John John John John John John John John John John John John"
        success = form.resolve(model: &john)
        XCTAssertFalse(success.0)
        XCTAssertFalse(success.1.isEmpty)
        XCTAssertEqual(success.1.first! as! PersonError, PersonError.tooLong)
        
        // Try correct
        firstnameField.output = "John The Best"
        success = form.resolve(model: &john)
        XCTAssertTrue(success.0)
        XCTAssertTrue(success.1.isEmpty)
    }
    
}
