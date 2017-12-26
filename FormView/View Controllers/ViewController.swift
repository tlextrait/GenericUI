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
        userForm.addRow([FormElement(idFirstname), FormElement(idLastname)])
        userForm.addRow([FormElement(idAddress)])
        //userForm.addRow([FormElement(idAge), FormElement.spacer(size: 2)])
        
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
    }
    
    @objc func doneTapped() {
        let person = userForm.resolve(model: Person())
        print(person)
    }


}

