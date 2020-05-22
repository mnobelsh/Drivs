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
    private let titleView: UIView = {
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
    private let locationManager = LocationHandler.shared.manager
    private var mapView: MKMapView!
    
    private let inputLocationViewHeight: CGFloat = 250
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .black
        authenticateUser()
    }
    
    // MARK: - Services
    private func authenticateUser() {
        if Auth.auth().currentUser?.uid == nil {
            let signinVC = UINavigationController(rootViewController: SigninViewController())
            signinVC.modalPresentationStyle = .fullScreen
            present(signinVC, animated: true, completion: nil)
        } else {
            enableLocationService()
            configureUI()
        }
    }
    
    // MARK: - Handler
    @objc private func trackUserLocationInMap() {
        mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    // MARK: - Helper
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
    private func configureUI() {
        overrideUserInterfaceStyle = .dark
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
    }
    private func configureMapView() {
        mapView = MKMapView()
        mapView.frame = view.frame
        mapView.showsUserLocation = true
        view.addSubview(mapView)
        mapView.anchor(top: view.topAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, left: view.leftAnchor)
        mapView.setUserTrackingMode(.follow, animated: true)
    }

}

// MARK: - Input Location View Delegate
extension HomeViewController: InputLocationViewDelegate {
    
    func showMainInputLocationView() {
        let yPosition: CGFloat = 100
        UIView.animate(withDuration: 0.5, animations: {
            self.inputLocationView.frame.origin.y = yPosition
            self.inputLocationView.frame.size.height = self.view.frame.height - yPosition
        }) { (_) in
            self.inputLocationView.anchor(right: self.view.rightAnchor, bottom: self.view.bottomAnchor, left: self.view.leftAnchor)
            self.inputLocationView.setSizeConstraint(width: self.view.frame.width, height: self.view.frame.height - yPosition)
        }
    }
    
    func closeInputLocationView() {
        UIView.animate(withDuration: 0.3) {
            self.inputLocationView.frame.origin.y = self.view.frame.height - self.inputLocationViewHeight
        }
    }
    
}




