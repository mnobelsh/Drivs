//
//  SignupViewController.swift
//  Drivs
//
//  Created by Muhammad Nobel Shidqi on 21/05/20.
//  Copyright © 2020 Muhammad Nobel Shidqi. All rights reserved.
//

import UIKit
import CoreLocation

class SignupViewController: UIViewController {

    // MARK: - Properties
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
        sc.setSizeConstraint(height: 45)
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
    private lazy var signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.configureDefaultButton(title: "Sign Up")
        button.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
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
    var isLoading: Bool = true
    let locationManager = LocationHandler.shared.manager
    let service = Services.shared

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Handlers
    @objc private func signUpButtonTapped() {
        
        guard let email = emailTextField.text else {return}
        guard let name = nameTextField.text else {return}
        guard let fPassword = passwordTextField.text else {return}
        guard let sPassword = confirmPasswordTextField.text else {return}
        guard let location = locationManager?.location else {return}
        
        if checkPassword(password: fPassword, confirmationPassword: sPassword) && !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let userData: [String : Any] = [
                 K.Database.email : email,
                 K.Database.name : name,
                 K.Database.role : roleSegmentedControl.selectedSegmentIndex,
                 K.Database.password : sPassword,
                 K.Database.location : location
             ]
            
            service.registerUser(user: userData) {
                guard let homeVC = (self.presentingViewController as? UINavigationController)?.viewControllers.first as? HomeViewController else {return}
                homeVC.configure()
                self.dismiss(animated: true, completion: nil)
            }
        }

    }
    
    // MARK: - Helpers
    private func checkPassword(password: String,confirmationPassword: String) -> Bool {
        if  password == confirmationPassword && (!password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !confirmationPassword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
            return true
        } else {
            if password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                print("DEBUG : Password cannot be empty")
            } else {
                print("DEBUG : Password must be same")
            }
            return false
        }
    }
    
    private func configureUI() {
        configureNavbar()
        view.backgroundColor = .baseColor
        
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
