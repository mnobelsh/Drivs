//
//  User.swift
//  Drivs
//
//  Created by Muhammad Nobel Shidqi on 27/05/20.
//  Copyright © 2020 Muhammad Nobel Shidqi. All rights reserved.
//

import Foundation
import CoreLocation

enum UserRole {
    case driver,rider
}

struct User {
    var uid: String
    var name: String
    var email: String
    var role: UserRole
    var location: CLLocation?
    
    init(uid: String , email: String, name: String, role: Int, location: CLLocation? = nil) {
        self.uid = uid
        self.email = email
        self.name = name
        if role == 0 {
            self.role = .rider
        } else {
            self.role = .driver
        }
        
        if let loc = location {
            self.location = loc
        }
    }
    
}
