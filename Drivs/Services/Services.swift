//
//  Services.swift
//  Drivs
//
//  Created by Muhammad Nobel Shidqi on 26/05/20.
//  Copyright © 2020 Muhammad Nobel Shidqi. All rights reserved.
//

import Foundation
import Firebase
import Geofirestore
import CoreLocation

fileprivate let db = Firestore.firestore()
fileprivate let GEOFIRE_REF = db.collection(K.Database.Reference.drivers_location)
fileprivate let USER_REF = db.collection(K.Database.Reference.users)

struct Services {
    
    static let shared = Services()
    private let geofirestore = GeoFirestore(collectionRef: GEOFIRE_REF)
    
    func fetchUser(withUID uid: String, completion: @escaping(User) -> Void) {
        USER_REF.document(uid).addSnapshotListener { (documentSnapshot, error) in
            if let e = error {
                print(e.localizedDescription)
                return
            }
        
            guard let data = documentSnapshot?.data() else {return}
            guard let email = data[K.Database.email] as? String else {return}
            guard let name = data[K.Database.name] as? String else {return}
            guard let role = data[K.Database.role] as? Int else {return}

            if role == 1 {
                GEOFIRE_REF.document(uid).addSnapshotListener { (locationSnapshot, error) in
                    if let e = error {
                        print(e.localizedDescription)
                        return
                    }
                   
                    guard let locationData = locationSnapshot?.data() else {return}
                    guard let latitude = (locationData["l"] as? [CLLocationDegrees])?.first else {return}
                    guard let longitude = (locationData["l"] as? [CLLocationDegrees])?.last else {return}
                    let location = CLLocation(latitude: latitude, longitude: longitude)
                    
                    completion(User(uid: uid, email: email, name: name, role: role, location: location))
                }
                
            } else {
                completion( User(uid: uid, email: email, name: name, role: role))
            }
            
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping() -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let err = error {
                print("DEBUG : Sign in error \(err)")
                return
            }
            completion()
        }
    }
    
    func registerUser(user: [String : Any], completion : @escaping() -> Void) {
        guard let name = user[K.Database.name] as? String else {return}
        guard let email = user[K.Database.email] as? String else {return}
        guard let password = user[K.Database.password] as? String else {return}
        guard let role = user[K.Database.role] as? Int else {return}
        guard let location = user[K.Database.location] as? CLLocation else {return}

        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let e = error {
                print("DEBUG : \(e.localizedDescription)")
                return
            }
            
            guard let uid = result?.user.uid else {return}
            let userData : [String:Any] = [
                "email": email,
                "name": name,
                "role": role,
            ]
            USER_REF.document(uid).setData(userData) { (error) in
                if let err = error {
                    print(err.localizedDescription)
                    return
                }
                
                if role == 1 {
                    self.geofirestore.setLocation(location: location, forDocumentWithID: uid) { (error) in
                        if let err = error {
                            print("DEBUG : geofire error \(err)")
                            return
                        }
                        completion()
                    }
                } else {
                    completion()
                }
                
            }
        
        }
    }
    
    func signOut(completion: @escaping() -> Void) {
        DispatchQueue.main.async {
            do {
                try Auth.auth().signOut()
                completion()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchDrivers(location: CLLocation, completion: @escaping(User) -> Void ) {
        let _ = geofirestore.query(withCenter: location, radius: 5.0).observe(.documentEntered) { (uid, location) in
            guard let userID = uid else {return}
            self.fetchUser(withUID: userID) { (user) in
                completion(user)
            }
        }
    }
}
