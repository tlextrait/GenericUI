//
//  ViewController.swift
//  FormView
//
//  Created by Thomas Lextrait on 12/19/17.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
    
    private func setupViews() {
        view.backgroundColor = .lightGray
        
        //
        // Title
        //
        
        let title = UILabel(frame: .zero)
        title.text = "FormView"
        title.font = UIFont.systemFont(ofSize: 24)
        title.textColor = .white
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false
        title.allowsDefaultTighteningForTruncation = true
        title.adjustsFontSizeToFitWidth = false
        
        view.addSubview(title)
        
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
        
        /*
 
        
 
        */

        let field = UIActiveInput<Int>()
        field.label.text = "FIRST NAME"
        field.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(field)

        field.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10.0).isActive = true
        field.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 10.0).isActive = true
        field.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -10.0).isActive = true

        
        
        let field2 = UIActiveInput<String>()
        field2.label.text = "LAST NAME"
        field2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(field2)
        
        field2.topAnchor.constraint(equalTo: field.bottomAnchor, constant: 2.0).isActive = true
        field2.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 10.0).isActive = true
        field2.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -10.0).isActive = true
        
        
        
        let field3 = UIActiveInput<String>()
        field3.label.text = "HOME ADDRESS"
        field3.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(field3)
        
        field3.topAnchor.constraint(equalTo: field2.bottomAnchor, constant: 2.0).isActive = true
        field3.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 10.0).isActive = true
        field3.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -10.0).isActive = true
    }


}

