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
    func closeInputLocationView()
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(mainView)
        mainView.anchor(top: self.topAnchor, right: self.rightAnchor, bottom: self.bottomAnchor, left: self.leftAnchor, paddingTop: 40)
        mainView.setRoundedCorners(corners: [.topLeft,.topRight], radius: 16)
        mainView.addShadow(withColor: .themeColor)
        
        mainView.addSubview(inputBar)
        inputBar.anchor(top: mainView.topAnchor, right: mainView.rightAnchor, left: mainView.leftAnchor, paddingTop: 20, paddingRight: 20, paddingLeft: 20)
        inputBar.setSizeConstraint(height: 55)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Handler
    @objc private func handleInputLocationBar() {
        delegate?.showMainInputLocationView()
        self.inputBar.alpha = 0
        self.addSubview(closeButton)
        closeButton.anchor(bottom: mainView.topAnchor, left: self.leftAnchor, paddingBottom: 8, paddingLeft: 16)
        
    }
    
    @objc private func handleCloseButton() {
        delegate?.closeInputLocationView()
        self.inputBar.alpha = 1
        closeButton.removeFromSuperview()
    }
    
    
    
}
