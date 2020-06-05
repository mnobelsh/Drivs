//
//  Extensions.swift
//  Drivs
//
//  Created by Muhammad Nobel Shidqi on 21/05/20.
//  Copyright © 2020 Muhammad Nobel Shidqi. All rights reserved.
//

import UIKit

extension UIColor {
    static let baseColor = UIColor.darkGray
    static let destinationIndicator = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
    static let originIndicator = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    static let themeColor = #colorLiteral(red: 1, green: 0.9586039186, blue: 0.6410561204, alpha: 1)
}

extension UIView {
    
    enum CornerType {
        case topLeft,topRight,bottomRight,bottomLeft,allCorners
    }
    
    func anchor(top: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, paddingTop: CGFloat = 0, paddingRight: CGFloat = 0, paddingBottom: CGFloat = 0, paddingLeft: CGFloat = 0) {
        self.translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
    }
    
    func setSizeConstraint(width: CGFloat? = nil, height: CGFloat? = nil) {
        self.translatesAutoresizingMaskIntoConstraints = false
        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func setCenterX(in view: UIView, constant: CGFloat? = nil) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: constant ?? 0).isActive = true
    }
    
    func setCenterY(in view: UIView, constant: CGFloat? = nil) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant ?? 0).isActive = true
    }
    
    func setCenterXY(in view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
           self.centerYAnchor.constraint(equalTo: view.centerYAnchor),
           self.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func setRoundedCorners(corners: [CornerType], radius: CGFloat) {
        self.layer.cornerRadius = radius
        var maskedCorners = [CACornerMask]()
        if corners.contains(.allCorners) {
            maskedCorners = [.layerMaxXMaxYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMinXMinYCorner]
        } else {
            if corners.contains(.bottomLeft) {
                maskedCorners.append(.layerMinXMaxYCorner)
            }
            if corners.contains(.bottomRight) {
                maskedCorners.append(.layerMaxXMaxYCorner)
            }
            if corners.contains(.topLeft) {
                maskedCorners.append(.layerMinXMinYCorner)
            }
            if corners.contains(.topRight) {
                maskedCorners.append(.layerMaxXMinYCorner)
            }
        }
        self.layer.maskedCorners = CACornerMask(maskedCorners)
    }
    
    func addShadow(withColor color: UIColor) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 5
    }
    
    func configureInputView(image: UIImage, imageColor: UIColor? = nil, textfield: UITextField? = nil) {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        
        self.addSubview(imageView)
        imageView.anchor(left: self.leftAnchor, paddingLeft: 8)
        imageView.setSizeConstraint(width: 24, height: 24)
        if let color = imageColor {
            imageView.tintColor = color
        } else {
            imageView.tintColor = .lightGray
        }
        
        
        if let tf = textfield {
            self.setSizeConstraint(height: 55)
            imageView.setCenterY(in: self)
            self.addSubview(tf)
            tf.autocapitalizationType = .none
            tf.anchor(right: self.rightAnchor, left: imageView.rightAnchor)
            tf.setCenterY(in: self)
            self.layer.borderWidth = 0.7
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.layer.cornerRadius = 8
        }
    }
    
}

extension UITextField {
    func configureInputTextField(placeholder: String, isSecureTextEntry: Bool) {
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 18)!,
            NSAttributedString.Key.foregroundColor: UIColor.lightGray
        ])
        self.textColor = #colorLiteral(red: 0.9325500727, green: 0.932706356, blue: 0.9325295091, alpha: 1)
        self.isSecureTextEntry = isSecureTextEntry
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: self.frame.height))
        self.leftViewMode = .always
        self.leftView = leftView
    }
}

extension UIButton {
    func configureDefaultButton(title: String, color: UIColor? = nil) {
        self.backgroundColor = color == nil ? UIColor.themeColor : color!
        self.setTitle(title, for: .normal)
        self.layer.cornerRadius = 12
        let attributedTitle = NSAttributedString(string: title, attributes: [
            NSAttributedString.Key.foregroundColor : UIColor.darkGray,
            NSAttributedString.Key.font : UIFont(name: "Avenir-Heavy", size: 22)!
        ])
        self.setAttributedTitle(attributedTitle, for: .normal)
        self.setSizeConstraint(height: 55)
    }
}

