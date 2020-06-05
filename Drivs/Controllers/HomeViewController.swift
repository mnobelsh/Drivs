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
        button.titleLabel?.textColor = .darkGray
        button.addTarget(self, action: #selector(signOutButtonHandler), for: .touchUpInside)
        return button
    }()
    private let menuButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "line.horizontal.3")!.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
    
    private let locationManager = LocationHandler.shared.manager
    let service = Services.shared
    private var currentUser: User? {
        didSet {
            inputLocationView.user = currentUser
        }
    }
    
    var locationResult: [MKMapItem] = []
    var lastEditedTextfield: UITextField?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateUser()
    }
    
    
    // MARK: - Services
    private func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        service.fetchUser(withUID: uid) { (user) in
            DispatchQueue.main.async {
                self.currentUser = user
                self.enableLocationService()
                self.currentUser!.role == .rider ? self.fetchDriversLocation() : nil
            }
        }
    }
    
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
            self.configure()
        }
    }
    
    // MARK: - Handler
    func configure() {
        configureUI()
        fetchUser()
        fetchDriversLocation()
    }
    
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
        tableView.reloadData()
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
        
        view.addSubview(menuButton)
        menuButton.anchor(left: view.leftAnchor, paddingLeft: 20)
        menuButton.setCenterY(in: titleView)
        menuButton.setSizeConstraint(width: 33, height: 33)
        
        view.addSubview(inputLocationView)
        inputLocationView.delegate = self
        inputLocationView.originTextField.delegate = self
        inputLocationView.destinationTextField.delegate = self
        inputLocationView.frame = CGRect(x: 0, y: view.frame.height - inputLocationViewHeight, width: view.frame.width, height: inputLocationViewHeight)
        
//        view.addSubview(signoutButton)
//        signoutButton.setCenterY(in: titleView)
//        signoutButton.anchor(right: view.rightAnchor, paddingRight: 8)
//        signoutButton.setSizeConstraint(width: 60, height: 33)
        
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
            annotationView.image = UIImage(systemName: "car")!
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
        locationResult = []
        UIView.animate(withDuration: 0.3, animations: {
            self.inputLocationView.frame.origin.y = self.view.frame.height - self.inputLocationViewHeight
        }) { (_) in
            self.inputLocationView.frame = CGRect(x: 0, y: self.view.frame.height - self.inputLocationViewHeight, width: self.view.frame.width, height: self.inputLocationViewHeight)
            completion()
        }
    }
    
}

// MARK: - Tableview datasource & delegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? locationResult.count : 0
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
        cell.mapItem = indexPath.section == 1 ? locationResult[indexPath.row] : nil
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let attributedText = NSMutableAttributedString(string: locationResult[indexPath.row].name!, attributes: [
            NSAttributedString.Key.font : UIFont(name: "Avenir-Heavy", size: 16)!,
            NSAttributedString.Key.foregroundColor : UIColor.black])
        attributedText.append(NSAttributedString(string: " | \(locationResult[indexPath.row].placemark.title!)", attributes: [
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 12)!,
            NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        guard let tf = lastEditedTextfield else {return}
        tf.attributedText = attributedText
        
        let selectedLocation = locationResult[indexPath.row]
        let annotation = MKPointAnnotation()
        annotation.coordinate = selectedLocation.placemark.coordinate
        mapView.addAnnotation(annotation)
    }
}

// MARK: - Location Textfield Delegate
extension HomeViewController: UITextFieldDelegate {
    
    private func requestLocation(withQuery query: String, completion: @escaping([MKMapItem]) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = mapView.region
        
        MKLocalSearch(request: request).start { (response, error) in
            if let e = error {
                print("DEBUG : Error Search \(e.localizedDescription)")
                return
            }
            guard let res = response else {return}
            var results: [MKMapItem] = []
            res.mapItems.forEach { (item) in
                results.append(item)
            }
            completion(results)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text else {return false}
        
        requestLocation(withQuery: query) { (results) in
            DispatchQueue.main.async {
                if textField == self.inputLocationView.originTextField {
                    self.locationResult = results
                } else if textField == self.inputLocationView.destinationTextField {
                    self.locationResult = results
                }
                self.inputLocationView.locationTableView.reloadData()
            }
        }
        
        lastEditedTextfield = textField
        textField.resignFirstResponder()
        return true
    }
    
    

}

