//
//  LocationTableCell.swift
//  Drivs
//
//  Created by Muhammad Nobel Shidqi on 31/05/20.
//  Copyright © 2020 Muhammad Nobel Shidqi. All rights reserved.
//

import UIKit
import MapKit

class LocationTableCell: UITableViewCell {
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Heavy", size: 16)
        label.textColor = .black
        return label
    }()
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Light", size: 14)
        label.textColor = .darkGray
        return label
    }()
    private lazy var cellLabelStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel,descriptionLabel])
        stack.alignment = .fill
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.axis = .vertical
        return stack
    }()
    var mapItem: MKMapItem? {
        didSet {
            self.titleLabel.text = mapItem?.name
            self.descriptionLabel.text = mapItem?.placemark.title
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.addSubview(cellLabelStack)
        cellLabelStack.anchor(top: self.topAnchor, right: self.rightAnchor, bottom: self.bottomAnchor, left: self.leftAnchor, paddingTop: 8, paddingBottom: 8, paddingLeft: 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

