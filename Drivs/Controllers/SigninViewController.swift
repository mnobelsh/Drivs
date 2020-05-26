//
//  SigninViewController.swift
//  Drivs
//
//  Created by Muhammad Nobel Shidqi on 21/05/20.
//  Copyright © 2020 Muhammad Nobel Shidqi. All rights reserved.
//

import UIKit

class SigninViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        let titleString = NSMutableAttributedString(string: "DRIVS\n", attributes: [
            NSAttributedString.Key.foregroundColor : UIColor.themeColor,
            NSMutableAttributedString.Key.font : UIFont(name: "Avenir-Heavy", size: 55)!
        ])
        
        let textString = NSAttributedString(string: "Welcome, please sign in", attributes: [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 25)!
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
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.configureInputTextField(placeholder: "Password", isSecureTextEntry: true)
        return tf
    }()
    private lazy var emailInputView: UIView = {
        let view = UIView()
        view.configureInputView(image: UIImage(systemName: "envelope")!, textfield: emailTextField)
        return view
    }()
    private lazy var passwordInputView: UIView = {
        let view = UIView()
        view.configureInputView(image: UIImage(systemName: "lock")!, textfield: passwordTextField)
        return view
    }()
    private let signinButton: UIButton = {
        let button = UIButton(type: .system)
        button.configureDefaultButton(title: "Sign In")
        return button
    }()
    private lazy var signinFormStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailInputView,
                                                       passwordInputView,
                                                       signinButton])
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.distribution = .fill
        return stackView
    }()
    private let signupLink: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account ? ", attributes: [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 18)!
        ])
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [
            NSAttributedString.Key.foregroundColor : UIColor.originIndicator,
            NSAttributedString.Key.font : UIFont(name: "Avenir-Heavy", size: 18)!
        ]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleSignupLink), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Handler
    @objc private func handleSignupLink() {
        navigationController?.pushViewController(SignupViewController(), animated: true)
    }

    // MARK: - Helper
    private func configureUI() {
        let navbar = navigationController?.navigationBar
        navbar?.isHidden =  true
        navbar?.barStyle = .black
        view.backgroundColor = .baseColor
        
        view.addSubview(signinFormStack)
        signinFormStack.anchor(right: view.rightAnchor, left: view.leftAnchor, paddingRight: 30, paddingLeft: 30)
        signinFormStack.setCenterXY(in: view)
        
        view.addSubview(titleLabel)
        titleLabel.anchor(bottom: signinFormStack.topAnchor, left: view.leftAnchor,  paddingBottom: 30, paddingLeft: 30 )
        
        view.addSubview(signupLink)
        signupLink.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,paddingBottom: 15)
        signupLink.setCenterX(in: view)
    }

    
    

}
