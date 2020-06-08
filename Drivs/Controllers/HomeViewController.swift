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
    private let topLeftButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "line.horizontal.3")!.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(handleTopLeftButton), for: .touchUpInside)
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
    
    private enum ButtonActionType {
        case locationDidSelect, menuView
    }
    private var topLeftButtonType: ButtonActionType = .menuView
    private var route: MKRoute?
    
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
    
    @objc private func handleTopLeftButton() {
        switch topLeftButtonType {
        case .locationDidSelect:
            self.configureInputLocationView()
            self.inputLocationView.removeInputLocationView()
            self.inputLocationView.configureGreetingView()
            removeAnnotationsAndOverlays()
            configureDismissalAction(action: .menuView)
            
        case .menuView:
            print("DEBUG : Open left menu pane")
            
        }
    }
    
    // MARK: - Helper
    private func removeAnnotationsAndOverlays() {
        self.mapView.annotations.forEach { (annotation) in
            if let anno = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(anno)
            }
        }
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays.first!)
        }
    }
    
    private func configurePolyline(forDestination destination: MKMapItem) {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile

        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if let e = error {
                print("DEBUG : error \(e)")
                return
            }
            guard let route = response?.routes.first else {return}
            self.route = route
            self.mapView.addOverlay(route.polyline)
        }
    }
    
    private func configureDismissalAction(action: ButtonActionType) {
        switch action {
        case .menuView:
            topLeftButtonType = .menuView
            self.topLeftButton.setImage(UIImage(systemName: "line.horizontal.3")!.withRenderingMode(.alwaysOriginal), for: .normal)

        case .locationDidSelect:
            topLeftButtonType = .locationDidSelect
            self.topLeftButton.setImage(UIImage(systemName: "arrow.left")!.withRenderingMode(.alwaysOriginal), for: .normal)
            closeInputLocationView {
                self.inputLocationView.removeFromSuperview()
            }
            
        }
    }

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
        
        view.addSubview(topLeftButton)
        topLeftButton.anchor(left: view.leftAnchor, paddingLeft: 20)
        topLeftButton.setCenterY(in: titleView)
        topLeftButton.setSizeConstraint(width: 33, height: 33)
        
        configureInputLocationView()
        
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
    
    private func configureInputLocationView() {
        view.addSubview(inputLocationView)
        inputLocationView.delegate = self
        inputLocationView.originTextField.delegate = self
        inputLocationView.destinationTextField.delegate = self
        inputLocationView.frame = CGRect(x: 0, y: view.frame.height - inputLocationViewHeight, width: view.frame.width, height: inputLocationViewHeight)
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            print("DEBUG : polylinerenderer \(route.polyline)")
            let polylineRenderer = MKPolylineRenderer(polyline: route.polyline)
            polylineRenderer.lineWidth = 3
            polylineRenderer.strokeColor = .systemBlue
            return polylineRenderer
        }
        return MKOverlayRenderer()
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
    
    private func closeInputLocationView(completion: (() ->Void)?) {
        locationResult = []
        UIView.animate(withDuration: 0.3, animations: {
            self.inputLocationView.frame.origin.y = self.view.frame.height - self.inputLocationViewHeight
        }) { (_) in
            self.inputLocationView.frame = CGRect(x: 0, y: self.view.frame.height - self.inputLocationViewHeight, width: self.view.frame.width, height: self.inputLocationViewHeight)
            if let comp = completion {
                comp()
            }
        }

    }
    
    func dismissInputLocationView(_ completion: @escaping () -> Void) {
        configureDismissalAction(action: .menuView)
        closeInputLocationView(completion: completion)
    }
    
}

// MARK: - Tableview datasource & delegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        return locationResult.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.8560581803, green: 0.8562023044, blue: 0.8560392261, alpha: 1)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(45)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1, !locationResult.isEmpty {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as? LocationTableCell else {return UITableViewCell()}
            cell.mapItem = locationResult[indexPath.row]
            return cell
        }
        return UITableViewCell()
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
        
        configurePolyline(forDestination: selectedLocation)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = selectedLocation.placemark.coordinate
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
        configureDismissalAction(action: .locationDidSelect)
        self.mapView.centerCoordinate = annotation.coordinate
        
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

