//
//  User.swift
//  Drivs
//
//  Created by Muhammad Nobel Shidqi on 27/05/20.
//  Copyright © 2020 Muhammad Nobel Shidqi. All rights reserved.
//

import Foundation
import CoreLocation

struct User {
    var name: String
    var email: String
    var role: String
    var location: CLLocation?
    
    init(email: String, name: String, role: Int, latitude: CLLocationDegrees? = nil, longitude: CLLocationDegrees? = nil) {
        self.email = email
        self.name = name
        if role == 0 {
            self.role = "Rider"
        } else {
            self.role = "Driver"
        }
        
        if let latitude = latitude, let longitude = longitude {
            self.location = CLLocation(latitude: latitude, longitude: longitude)
        }
    }
    
}
