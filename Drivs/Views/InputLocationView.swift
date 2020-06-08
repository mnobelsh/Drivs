//
//  InputLocationView.swift
//  Drivs
//
//  Created by Muhammad Nobel Shidqi on 21/05/20.
//  Copyright © 2020 Muhammad Nobel Shidqi. All rights reserved.
//

import UIKit


protocol InputLocationViewDelegate {
    func showMainInputLocationView()
    func dismissInputLocationView(_ completion: @escaping() -> Void)
}

class InputLocationView: UIView {
    
    // MARK: - Properties
    var delegate: InputLocationViewDelegate?
    private let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    private lazy var inputBar: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.7
        view.setRoundedCorners(corners: [.allCorners], radius: 12)
        view.backgroundColor = #colorLiteral(red: 0.9340569973, green: 0.9342134595, blue: 0.9340363145, alpha: 1)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleInputLocationBar))
        view.addGestureRecognizer(tapGesture)
        
        let inputLabel: UILabel = {
            let label = UILabel()
            label.text = "Search for destination..."
            label.font = UIFont(name: "Avenir-Light", size: 18)
            label.textColor = .darkGray
            return label
        }()
        view.addSubview(inputLabel)
        inputLabel.anchor(right: view.rightAnchor, left: view.leftAnchor, paddingRight: 8, paddingLeft: 16)
        inputLabel.setCenterY(in: view)
        return view
    }()
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setSizeConstraint(width: 30, height: 30)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .lightGray
        button.addTarget(self, action: #selector(handleCloseButton), for: .touchUpInside)
        return button
    }()
    
    private let greetingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "welcome")
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        return imageView
    }()
    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .originIndicator
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    private lazy var greetingView: UIView = {
        let view = UIView()
        
        view.addSubview(greetingImageView)
        greetingImageView.anchor(top: view.topAnchor,bottom: view.bottomAnchor, left: view.leftAnchor)
        greetingImageView.setSizeConstraint(width: 120)
        
        
        view.addSubview(greetingLabel)
        greetingLabel.anchor(top: view.topAnchor ,right: view.rightAnchor, bottom: view.bottomAnchor, left: greetingImageView.rightAnchor, paddingLeft: 16)
        
        return view
    }()
    
    let originTextField: UITextField = {
    let tf = UITextField()
        tf.returnKeyType = .search
        tf.clearButtonMode = .whileEditing
        tf.configureInputTextField(placeholder: "Your origin...", isSecureTextEntry: false)
        tf.setSizeConstraint(height: 55)
        tf.textColor = .darkGray
    return tf
}()
    private lazy var inputOriginView: UIView = {
        let view = UIView()
        view.configureInputView(image: UIImage(systemName: "smallcircle.fill.circle")!, imageColor: .originIndicator, textfield: originTextField)
        view.backgroundColor = #colorLiteral(red: 0.9513661265, green: 0.9515252709, blue: 0.9513451457, alpha: 1)
        return view
    }()
    let destinationTextField: UITextField = {
    let tf = UITextField()
    tf.returnKeyType = .search
    tf.clearButtonMode = .whileEditing
    tf.configureInputTextField(placeholder: "Your destination...", isSecureTextEntry: false)
    tf.setSizeConstraint(height: 55)
    tf.textColor = .darkGray
    return tf
}()
    private lazy var inputDestinationView: UIView = {
        let view = UIView()
        view.configureInputView(image: UIImage(systemName: "smallcircle.fill.circle")!, imageColor: .destinationIndicator, textfield: destinationTextField)
        view.backgroundColor = #colorLiteral(red: 0.9513661265, green: 0.9515252709, blue: 0.9513451457, alpha: 1)
        return view
    }()
    
    private lazy var selectFromMapButton: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.setSizeConstraint(width: 110, height: 35)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        view.setRoundedCorners(corners: [.allCorners], radius: 8)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectFromMapButtonTapped))
        view.addGestureRecognizer(tapGesture)
        
        let imageView = UIImageView(image: UIImage(systemName: "map")!.withRenderingMode(.alwaysOriginal).withTintColor(.white))
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(imageView)
        imageView.anchor(top: view.topAnchor, bottom: view.bottomAnchor, left: view.leftAnchor, paddingTop: 5, paddingBottom: 5, paddingLeft: 8)
        imageView.setSizeConstraint(width: 14)
        
        let label = UILabel()
        label.attributedText = NSAttributedString(string: "Select from map", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white,
                                                                                          NSAttributedString.Key.font : UIFont(name: "Avenir-Heavy", size: 10)!])
        label.textAlignment = .right
        
        view.addSubview(label)
        label.anchor(top: view.topAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, left: imageView.rightAnchor, paddingTop: 5, paddingRight: 8, paddingBottom: 5)
        
        return view
    }()
    private lazy var inputLocationStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [inputOriginView,inputDestinationView])
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        return stackView
    }()
    
    var locationTableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.tableFooterView = UIView()
        return tv
    }()

    var user: User? {
        didSet {
            let greetingText = NSMutableAttributedString(string: "Hello, \(user!.name)\n", attributes: [
                    NSAttributedString.Key.font : UIFont(name: "Avenir-Heavy", size: 20)!,
                    NSAttributedString.Key.foregroundColor : UIColor.black
                ])
            let tagline = NSAttributedString(string: "Today is a great day! ready for new adventure ?", attributes: [
                NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 14)!,
                NSAttributedString.Key.foregroundColor : UIColor.darkGray
            ])
            greetingText.append(tagline)
            greetingLabel.attributedText = greetingText
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(mainView)
        mainView.anchor(top: self.topAnchor, right: self.rightAnchor, bottom: self.bottomAnchor, left: self.leftAnchor, paddingTop: 40)
        mainView.setRoundedCorners(corners: [.topLeft,.topRight], radius: 16)
        mainView.addShadow(withColor: .darkGray)
        
        mainView.addSubview(inputBar)
        inputBar.anchor(top: mainView.topAnchor, right: mainView.rightAnchor, left: mainView.leftAnchor, paddingTop: 20, paddingRight: 20, paddingLeft: 20)
        inputBar.setSizeConstraint(height: 55)
        
        configureGreetingView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Handler
    @objc private func selectFromMapButtonTapped() {
        if originTextField.isEditing {
            print("DEBUG: Select from map (origin)")
        } else if destinationTextField.isEditing {
            print("DEBUG: Select from map (destination)")
        }
        
    }
    
    private func configureInputLocationView() {
        self.addSubview(inputLocationStack)
        inputLocationStack.anchor(top: mainView.topAnchor, right: mainView.rightAnchor, left: mainView.leftAnchor, paddingTop: 20, paddingRight: 20, paddingLeft: 20)
        inputLocationStack.setSizeConstraint(height: 130)
        
        self.addSubview(selectFromMapButton)
        selectFromMapButton.anchor(top: inputLocationStack.bottomAnchor, left: mainView.leftAnchor, paddingTop: 16,paddingLeft: 20)
        
        self.addSubview(locationTableView)
        locationTableView.anchor(top: selectFromMapButton.bottomAnchor, right: mainView.rightAnchor, bottom: mainView.bottomAnchor, left: mainView.leftAnchor, paddingTop: 30)
        
    }
    
    func removeInputLocationView() {
        self.inputBar.alpha = 1
        closeButton.removeFromSuperview()
        inputLocationStack.removeFromSuperview()
        originTextField.text?.removeAll()
        destinationTextField.text?.removeAll()
        locationTableView.removeFromSuperview()
        selectFromMapButton.removeFromSuperview()
    }
    
    @objc private func handleInputLocationBar() {
        delegate?.showMainInputLocationView()
        self.inputBar.alpha = 0
        self.addSubview(closeButton)
        greetingView.removeFromSuperview()
        closeButton.anchor(bottom: mainView.topAnchor, left: self.leftAnchor, paddingBottom: 8, paddingLeft: 16)
        configureInputLocationView()
    }

    @objc private func handleCloseButton() {
        delegate?.dismissInputLocationView {
            self.configureGreetingView()
        }
        removeInputLocationView()
    }
    
    func configureGreetingView() {
        mainView.addSubview(greetingView)
        greetingView.anchor(top: inputBar.bottomAnchor, right: mainView.rightAnchor, bottom: mainView.bottomAnchor, left: mainView.leftAnchor, paddingTop: 8, paddingRight: 20, paddingBottom: 20, paddingLeft: 20)
    }
    
}
