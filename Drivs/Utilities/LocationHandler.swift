//
//  LocationHandler.swift
//  Drivs
//
//  Created by Muhammad Nobel Shidqi on 21/05/20.
//  Copyright © 2020 Muhammad Nobel Shidqi. All rights reserved.
//

import Foundation
import CoreLocation


class LocationHandler: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationHandler()
    var manager: CLLocationManager!
    
    override init() {
        super.init()
        manager = CLLocationManager()
        manager.delegate = self
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.requestAlwaysAuthorization()
        }
    }
    
}
