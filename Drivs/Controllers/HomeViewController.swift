//
//  HomeViewController.swift
//  Drivs
//
//  Created by Muhammad Nobel Shidqi on 21/05/20.
//  Copyright © 2020 Muhammad Nobel Shidqi. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class HomeViewController: UIViewController {

    // MARK: - Properties
    private var titleView: UIView = {
        let view = UIView()
        view.backgroundColor = .themeColor
        
        let titleLabel: UILabel = {
            let label = UILabel()
            label.text = "DRIVS"
            label.font = UIFont(name: "Avenir-Heavy", size: 18)
            label.textColor = .darkGray
            return label
        }()
        
        view.addSubview(titleLabel)
        titleLabel.setCenterXY(in: view)
        
        return view
    }()
    private let inputLocationView = InputLocationView()
    private var mapView: MKMapView!
    private let inputLocationViewHeight: CGFloat = 250
    private lazy var signoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setAttributedTitle(NSAttributedString(string: "Sign Out", attributes: [
            NSAttributedString.Key.font : UIFont(name: "Avenir-Heavy", size: 12)!]), for: .normal)
        button.titleLabel?.textColor = .white
        button.addTarget(self, action: #selector(signOutButtonHandler), for: .touchUpInside)
        return button
    }()

    private let locationManager = LocationHandler.shared.manager
    let service = Services.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let uid = Auth.auth().currentUser?.uid else {return}
        service.fetchUser(withUID: uid) { (user) in
            self.enableLocationService()
            self.inputLocationView.user = user
        }
        fetchDriversLocation()
    }
    
    
    // MARK: - Services=
    private func fetchDriversLocation() {
        guard let location = locationManager?.location else {return}
        self.service.fetchDrivers(location: location) { (driver) in
            guard let coordinate = driver.location?.coordinate else {return}
            let driverAnnotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)

            var isDriverVisible: Bool {
                return self.mapView.annotations.contains(where: { (annotation) -> Bool in
                    guard let anno = annotation as? DriverAnnotation else {return false}
                    if anno.uid == driver.uid {
                        anno.updateCoordinate(withCoordinate: coordinate)
                        self.mapView.reloadInputViews()
                        return true
                    }
                    return false
                })
            }
        
            if !isDriverVisible {
                self.mapView.addAnnotation(driverAnnotation)
            }
        }
    }
    
    private func authenticateUser() {
        if Auth.auth().currentUser?.uid == nil {
            let signinVC = UINavigationController(rootViewController: SigninViewController())
            signinVC.modalPresentationStyle = .fullScreen
            present(signinVC, animated: true, completion: nil)
        } else {
            self.configureUI()
        }
    }
    
    // MARK: - Handler
    @objc private func trackUserLocationInMap() {
        mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    @objc private func signOutButtonHandler() {
        service.signOut {
            self.authenticateUser()
            for view in self.view.subviews {
                view.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Helper

    private func configureTableView() {
        let tableView = inputLocationView.locationTableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(LocationTableCell.self, forCellReuseIdentifier: "LocationCell")
    }
    
    private func enableLocationService() {
        switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways:
                locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                locationManager?.startUpdatingLocation()
            case .authorizedWhenInUse:
                locationManager?.requestAlwaysAuthorization()
            case .notDetermined:
                locationManager?.requestWhenInUseAuthorization()
            default:
                break
        }
    }
    
    func configureUI() {
        navigationController?.navigationBar.barStyle = .default
        view.backgroundColor = .baseColor
        navigationController?.navigationBar.isHidden = true
        configureMapView()
        
        view.addSubview(titleView)
        titleView.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        titleView.setSizeConstraint(width: 90, height: 33)
        titleView.setCenterX(in: view)
        titleView.layer.cornerRadius = 16
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(trackUserLocationInMap))
        titleView.addGestureRecognizer(tapGesture)
        
        view.addSubview(inputLocationView)
        inputLocationView.delegate = self
        inputLocationView.frame = CGRect(x: 0, y: view.frame.height - inputLocationViewHeight, width: view.frame.width, height: inputLocationViewHeight)
        
        view.addSubview(signoutButton)
        signoutButton.setCenterY(in: titleView)
        signoutButton.anchor(right: view.rightAnchor, paddingRight: 8)
        signoutButton.setSizeConstraint(width: 60, height: 33)
        
    }
    
    private func configureMapView() {
        mapView = MKMapView()
        mapView.delegate = self
        mapView.frame = view.frame
        mapView.showsUserLocation = true
        view.addSubview(mapView)
        mapView.anchor(top: view.topAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, left: view.leftAnchor)
        mapView.setUserTrackingMode(.follow, animated: true)
        
    }


}

// MARK: - Map View Delegate
extension HomeViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "DriverAnnotation")
            annotationView.image = UIImage(systemName: "car")?.withTintColor(.white)
            return annotationView
        }
        return nil
    }
}

// MARK: - Input Location View Delegate
extension HomeViewController: InputLocationViewDelegate {

    func showMainInputLocationView() {
        configureTableView()
        let yPosition: CGFloat = 100
        let height: CGFloat = view.frame.height - yPosition
        UIView.animate(withDuration: 0.5, animations: {
            self.inputLocationView.frame = CGRect(x: 0, y: self.view.frame.height - height, width: self.view.frame.width, height: height)
            self.inputLocationView.frame.origin.y = yPosition
        }) { (_) in
            
        }
        
    }
    
    func closeInputLocationView(_ completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3, animations: {
            self.inputLocationView.frame.origin.y = self.view.frame.height - self.inputLocationViewHeight
        }) { (_) in
            self.inputLocationView.frame = CGRect(x: 0, y: self.view.frame.height - self.inputLocationViewHeight, width: self.view.frame.width, height: self.inputLocationViewHeight)
            completion()
        }
    }
    
    
}

var originList: [[String:String]] = [
    ["title": "Menteng Dalam", "description": "Jalan Medan Merdeka Barat, Menteng, Jakarta, Indonesia"],
    ["title": "Menteng Luar", "description": "Jalan Medan Merdeka Barat, Menteng, Jakarta, Indonesia"],
]

var destinationList: [[String:String]] = [
    ["title": "Cikini Raya", "description": "Jalan Medan Merdeka Barat, Menteng, Jakarta, Indonesia"],
]

// MARK: - Tableview datasource & delegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return originList.count
        } else if section == 1 {
            return destinationList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let view = UIView()
            view.backgroundColor = #colorLiteral(red: 0.8560581803, green: 0.8562023044, blue: 0.8560392261, alpha: 1)
            return view
        }
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return CGFloat(45)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as? LocationTableCell else {return UITableViewCell()}
        var title: String = ""
        var description: String = ""
        if indexPath.section == 0 {
            title = originList[indexPath.row]["title"]!
            description = originList[indexPath.row]["description"]!
        } else if indexPath.section == 1 {
            title = destinationList[indexPath.row]["title"]!
            description = destinationList[indexPath.row]["description"]!
        }
        cell.titleLabel.text = title
        cell.descriptionLabel.text = description
        return cell
    }
}


