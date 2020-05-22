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
    private lazy var inputFormStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailInputView,
                                                       passwordInputView,
                                                       signinButton])
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    

    // MARK: - Helper
    private func configureUI() {
        let navbar = navigationController?.navigationBar
        navbar?.isHidden =  true
        navbar?.barStyle = .black
        view.backgroundColor = .baseColor
        
        view.addSubview(inputFormStack)
        inputFormStack.anchor(right: view.rightAnchor, left: view.leftAnchor, paddingRight: 30, paddingLeft: 30)
        inputFormStack.setSizeConstraint(height: 200)
        inputFormStack.setCenterXY(in: view)
        
        view.addSubview(titleLabel)
        titleLabel.anchor(bottom: inputFormStack.topAnchor, left: view.leftAnchor,  paddingBottom: 30, paddingLeft: 30 )

    }

}
