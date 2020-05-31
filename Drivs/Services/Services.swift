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
    
    func getUser(withUID uid: String, completion: @escaping(User) -> Void) {
        USER_REF.document(uid).addSnapshotListener { (documentSnapshot, error) in
            if let e = error {
                print(e.localizedDescription)
                return
            }
        
            guard let data = documentSnapshot?.data() else {return}
   
            guard let email = data[K.Database.email] as? String else {return}
            guard let name = data[K.Database.name] as? String else {return}
            guard let role = data[K.Database.role] as? Int else {return}
            
            var user: User!
            
            
            if role == 1 {
                GEOFIRE_REF.document(uid).addSnapshotListener { (locationSnapshot, error) in
                    if let e = error {
                        print(e.localizedDescription)
                        return
                    }
                   
                    guard let locationData = locationSnapshot?.data() else {return}
                    guard let location = locationData["l"] as? [CLLocationDegrees] else {return}
                    guard let latitude = location.first else {return}
                    guard let longitude = location.last else {return}
                         
                    user = User(email: email, name: name, role: role, latitude: latitude, longitude: longitude)
                    completion(user)
                }
                
            } else {
                user = User(email: email, name: name, role: role)
                completion(user)
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
        guard let latitude = user[K.Database.latitude] as? CLLocationDegrees else {return}
        guard let longitude = user[K.Database.longitude] as? CLLocationDegrees else {return}

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
                print("DEBUG : save to db")
                if let err = error {
                    print(err.localizedDescription)
                    return
                }
                
                if role == 1 {
                    print("DEBUG : user uid \(uid)")
                    self.geofirestore.setLocation(location: CLLocation(latitude: latitude, longitude: longitude), forDocumentWithID: uid) { (error) in
                        if let err = error {
                            print("DEBUG : geofire error \(err)")
                            return
                        }
                        print("DEBUG : Driver location added.")
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
    
}
