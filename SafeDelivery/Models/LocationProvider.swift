//
//  LocationProvider.swift
//  SafeDelivery
//
//  Created by Phil Mui on 11/15/21.
//

import UIKit
import CoreLocation
import LogStore
import Combine

class LocationProvider: NSObject, CLLocationManagerDelegate {

    private let locationManager: CLLocationManager
    @Published var lastLocation: CLLocation?
    
    override init() {
        locationManager = CLLocationManager()
        
        super.init()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse: printLog("location authz success")
        case .denied:
            printLog("location authz denied")
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        default: break
        }
    }
    
    func start() {
        locationManager.startUpdatingLocation()
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }
}
