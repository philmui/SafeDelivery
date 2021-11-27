//
//  DistanceViewController.swift
//  SafeDelivery
//
//  Created by Phil Mui on 11/15/21.
//

import UIKit
import Combine
import CoreLocation
import LogStore
import Firebase
import FirebaseFirestore

class DistanceViewController: UIViewController {

    @IBOutlet var distanceLabel: UILabel!
    private let locationProvider = LocationProvider()
    private var subscription: AnyCancellable?
    private var storedLocations: [CLLocation] = []
    private var lastDistance: CLLocationDistance = 0
    private var stillInRadius = false
    
    let db = Firestore.firestore()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        locationProvider.start()
        
        subscription = locationProvider.$lastLocation
            .sink(receiveValue: updateUI)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let lastLocation = loadLocation() {
            storedLocations.append(lastLocation)
        }
    }
    
    @IBAction func setAnchor(_ sender: UIButton) {
        
        if let location = locationProvider.lastLocation {
            storedLocations.append(location)
            write(location)
            
            showAR()
        }
    }
    
    func updateUI(for location: CLLocation?) {
        guard let location = location else { return }
        
        if let lastLocation = storedLocations.last {
            let distance = location.distance(from: lastLocation)
            distanceLabel.text =
                String(format: "Distance from last anchor: %.4lf m", distance)
            
            if distance >= lastDistance {
                view.backgroundColor = .red
            } else {
                view.backgroundColor = .green
            }
            
            lastDistance = distance
            
            if distance < 10 {
                if stillInRadius == false {
                    showAR(shouldRestore: true)
                }
            } else {
                stillInRadius = false
            }
        } else {
            let coordinate = location.coordinate
            distanceLabel.text = String(format: "%.6lf, %.6lf",
                                        coordinate.latitude,
                                        coordinate.longitude)
        }
    }
    
    func showAR(shouldRestore: Bool = false) {
        
        stillInRadius = true
        
        if let next = storyboard?.instantiateViewController(
            withIdentifier: "ARViewController") as? ARViewController {
            
            next.shouldRestore = shouldRestore
            next.lastLocation = storedLocations.last
            next.modalPresentationStyle = .fullScreen
            present(next, animated: true, completion: nil)
        }
    }
    
    private func write(_ location: CLLocation?) {
        guard let location = location else { return }
        
        // firestore persistence
        db.collection(K.FStore.locationCollection)
            .addDocument(data: [
                K.FStore.timestamp: Timestamp(date: Date()),
                K.FStore.latitude: location.coordinate.latitude,
                K.FStore.longitude: location.coordinate.longitude
            ]) { error in
                if let e = error {
                    printLog("Firestore write error: \(e)")
                }
            }
        
// local persistence
//        do {
//            let data = try NSKeyedArchiver.archivedData(
//                       withRootObject: location, requiringSecureCoding: true)
//            try data.write(to: FileManager.locationURL())
//        } catch {
//            printLog("write error: \(error)")
//        }
    }
    
    private func loadLocation() -> CLLocation? {
        
        var lastLocation: CLLocation?

        db.collection(K.FStore.locationCollection)
            .order(by: K.FStore.timestamp, descending: true).limit(to: 4)
            .getDocuments { querySnapshot, error in
                
                if let err = error {
                    printLog("Error getting Firebase history: \(err)")
                } else {
                    if let docs = querySnapshot?.documents {
                        
                        for doc in docs {
                            let data = doc.data()
                            if let timestamp = data[K.FStore.timestamp] as? Timestamp,
                               let lat = data[K.FStore.latitude] as? Double,
                               let long = data[K.FStore.longitude] as? Double {
                                
                                if lastLocation == nil {
                                    lastLocation = CLLocation(latitude: lat, longitude: long)
                                    print("==> time: \(timestamp.dateValue()), lat: \(lat), long: \(long)")
                                }
                                print(" -> time: \(timestamp.dateValue()), lat: \(lat), long: \(long)")
                            }
                        }
                    }
                }
            }
        
//        do {
//            let data = try Data(contentsOf: FileManager.locationURL())
//            return try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self, from: data)
//        } catch {
//            printLog("load error: \(error)")
//        }
        return lastLocation
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
