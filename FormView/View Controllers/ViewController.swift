//
//  ViewController.swift
//  FormView
//
//  Created by Thomas Lextrait on 12/19/17.
//

import UIKit

fileprivate class Person {
    var firstname = ""
    var lastname = ""
    var address = ""
    var age: UInt = 0
}

class ViewController: UIViewController {
    
    fileprivate let userForm = UIQuickFormView<Person>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
    
    private func setupViews() {
        view.backgroundColor = .gray
        
        //
        // Title
        //
        
        let title = UILabel(frame: .zero)
        view.addSubview(title)
        
        title.text = "FormView"
        title.font = UIFont.systemFont(ofSize: 24)
        title.textColor = .white
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false
        title.allowsDefaultTighteningForTruncation = true
        title.adjustsFontSizeToFitWidth = false
        
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        title.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        title.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        title.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        var margins = view.layoutMarginsGuide
        if #available(iOS 11, *) {
            margins = view.safeAreaLayoutGuide
        }
        
        title.topAnchor.constraint(equalTo: margins.topAnchor, constant: 25.0).isActive = true
        title.leadingAnchor.constraint(greaterThanOrEqualTo: margins.leadingAnchor, constant: 10.0).isActive = true
        title.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        title.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        
        //
        // Form
        //
        
        view.addSubview(userForm)
        userForm.backgroundColor = .lightGray
        userForm.layer.cornerRadius = 3.0
        
        let fieldFirstname = UIActiveInput<String>(label: "FIRST NAME")
        let idFirstname = userForm.bind(input: fieldFirstname) { (person, input) in
            guard let firstname = input.output else {
                return
            }
            person.firstname = firstname
        }
        
        let fieldLastname = UIActiveInput<String>(label: "LAST NAME")
        let idLastname = userForm.bind(input: fieldLastname) { (person, input) in
            guard let lastname = input.output else {
                return
            }
            person.lastname = lastname
        }
        
        let fieldAddress = UIActiveInput<String>(label: "ADDRESS")
        let idAddress = userForm.bind(input: fieldAddress) { (person, input) in
            guard let address = input.output else {
                return
            }
            person.address = address
        }
        
        let ageField = UIActiveInput<UInt>(label: "AGE")
        let idAge = userForm.bind(input: ageField) { (person, input) in
            guard let age = input.output else {
                return
            }
            person.age = age
        }
        
        let userFormTitle = UILabel(frame: .zero)
        userFormTitle.text = "User Form"
        userFormTitle.font = UIFont.systemFont(ofSize: 16.0)
        userFormTitle.textColor = .black
        let idTitle = userForm.bind(view: userFormTitle)
        
        // Lay things out on the form
        userForm.addRow([FormElement(idTitle)])
        userForm.addRow([FormElement(idFirstname, size: 2), FormElement(idLastname, size: 1)])
        userForm.addRow([FormElement(idAddress)])
        userForm.addRow([FormElement(idAge), FormElement.spacer(size: 2)])
        
        // Form constraints
        userForm.translatesAutoresizingMaskIntoConstraints = false
        userForm.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10.0).isActive = true
        userForm.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 8.0).isActive = true
        userForm.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -8.0).isActive = true
        userForm.setRecommendedContentPriorities()
        userForm.build()
        
        //
        // Button
        //
        
        let button = UIButton(frame: .zero)
        view.addSubview(button)
        
        button.setTitle("Done", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: userForm.bottomAnchor, constant: 10.0).isActive = true
        button.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        button.addTarget(self, action: #selector(self.doneTapped), for: UIControlEvents.allTouchEvents)
        
        //
        // CGSize Form
        //
        
        let form = UIQuickFormView<CGSize>()
        view.addSubview(form)
        form.backgroundColor = .green
        form.layer.cornerRadius = 3.0
        form.translatesAutoresizingMaskIntoConstraints = false
        form.topAnchor.constraint(equalTo: userForm.bottomAnchor, constant: 50.0).isActive = true
        form.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 8.0).isActive = true
        form.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -8.0).isActive = true
        
        let widthInput = UIActiveInput<CGFloat>(label: "WIDTH")
        let heightInput = UIActiveInput<CGFloat>(label: "HEIGHT")
        
        // Bind the inputs
        let widthInputId = form.bind(input: widthInput) { (size: inout CGSize, input: UIActiveInput<CGFloat>) in
            guard let width = input.output else {
                // handle any errors here
                return
            }
            size.width = width
        }
        let heightInputId = form.bind(input: heightInput) { (size: inout CGSize, input: UIActiveInput<CGFloat>) in
            guard let height = input.output else {
                // handle any errors here
                return
            }
            size.height = height
        }
        
        // Lay out the inputs in the form (both inputs go on the same line here)
        form.addRow([FormElement(widthInputId), FormElement(heightInputId)])
        form.setRecommendedContentPriorities()
        form.build()
        
        // When you want to resolve the form to a CGSize:
        var s = CGSize(width: 0, height: 0)
        let size = form.resolve(model: &s)
    }
    
    @objc func doneTapped() {
        var p = Person()
        let person = userForm.resolve(model: &p)
        print(person)
    }


}

