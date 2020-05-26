//
//  SignupViewController.swift
//  Drivs
//
//  Created by Muhammad Nobel Shidqi on 21/05/20.
//  Copyright © 2020 Muhammad Nobel Shidqi. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        
        let titleString = NSMutableAttributedString(string: "Sign Up\n", attributes: [
            NSAttributedString.Key.foregroundColor : UIColor.themeColor,
            NSMutableAttributedString.Key.font : UIFont(name: "Avenir-Heavy", size: 35)!
        ])
        
        let textString = NSAttributedString(string: "Register as a member and get more benefits.", attributes: [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 18)!
        ])
        
        titleString.append(textString)
        
        label.numberOfLines = 0
        label.attributedText = titleString
        
        return label
    }()
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.configureInputTextField(placeholder: "Email", isSecureTextEntry: false)
        tf.keyboardType = .emailAddress
        return tf
    }()
    private let nameTextField: UITextField = {
        let tf = UITextField()
        tf.configureInputTextField(placeholder: "Name", isSecureTextEntry: false)
        return tf
    }()
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.configureInputTextField(placeholder: "Password", isSecureTextEntry: true)
        return tf
    }()
    private let confirmPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.configureInputTextField(placeholder: "Confirm Password", isSecureTextEntry: true)
        return tf
    }()
    private let roleSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: [
            "Rider","Driver"
        ])
        sc.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor : UIColor.darkGray,
            NSAttributedString.Key.font : UIFont(name: "Avenir-Heavy", size: 14)!
        ], for: .normal)
        sc.backgroundColor = #colorLiteral(red: 0.819047749, green: 0.8261945844, blue: 0.8726840615, alpha: 1)
        sc.selectedSegmentTintColor = .themeColor
        sc.selectedSegmentIndex = 0
        return sc
    }()
    private lazy var emailInputView: UIView = {
        let view = UIView()
        view.configureInputView(image: UIImage(systemName: "envelope")!, textfield: emailTextField)
        return view
    }()
    private lazy var nameInputView: UIView = {
        let view = UIView()
        view.configureInputView(image: UIImage(systemName: "person")!, textfield: nameTextField)
        return view
    }()
    private lazy var passwordInputView: UIView = {
        let view = UIView()
        view.configureInputView(image: UIImage(systemName: "lock")!, textfield: passwordTextField)
        return view
    }()
    private lazy var confirmPasswordInputView: UIView = {
        let view = UIView()
        view.configureInputView(image: UIImage(systemName: "lock.shield")!, textfield: confirmPasswordTextField)
        return view
    }()
    private let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.configureDefaultButton(title: "Sign Up")
        return button
    }()
    private lazy var signupFormStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [roleSegmentedControl,
                                                       emailInputView,
                                                       nameInputView,
                                                       passwordInputView,
                                                       confirmPasswordInputView,
                                                       ])
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.distribution = .fill
        return stackView
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Helper
    private func configureUI() {
        view.backgroundColor = .baseColor
        configureNavbar()
        
        
        view.addSubview(signupFormStack)
        signupFormStack.anchor(right: view.rightAnchor, left: view.leftAnchor, paddingRight: 30, paddingLeft: 30)
        signupFormStack.setCenterXY(in: view)
        
        view.addSubview(signupButton)
        signupButton.anchor(top: signupFormStack.bottomAnchor, right: view.rightAnchor, left: view.leftAnchor, paddingTop: 30, paddingRight: 30,paddingLeft: 30)
        
        view.addSubview(titleLabel)
        titleLabel.anchor(right: view.rightAnchor, bottom: signupFormStack.topAnchor, left: view.leftAnchor, paddingRight: 30, paddingBottom: 30, paddingLeft: 30)
    }
    
    private func configureNavbar() {
        let navbar = navigationController?.navigationBar
        navbar?.isHidden = false
        navbar?.backgroundColor = .clear
        navbar?.setBackgroundImage(UIImage(), for: .default)
        navbar?.shadowImage = UIImage()
        
        let backButtonItem = UIBarButtonItem()
        backButtonItem.title = "Sign In"
        backButtonItem.tintColor = .originIndicator
        navbar?.topItem?.backBarButtonItem = backButtonItem
    }

}
