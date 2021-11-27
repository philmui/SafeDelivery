//
//  ViewController.swift
//  SafeDelivery
//
//  Created by Phil Mui on 11/15/21.
//

import UIKit
import SpriteKit
import ARKit
import LogStore
import Firebase
import FirebaseFirestore

class ARViewController: UIViewController, ARSKViewDelegate, ARSessionDelegate {
    
    @IBOutlet var sceneView: ARSKView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    
    var shouldRestore = false
    var lastLocation: CLLocation?
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        restoreStoredWorldMap(configuration)
        
//        if shouldRestore {
//
//            do {
//                let data = try Data(contentsOf: FileManager.mapDataURL())
//                let worldMap = try NSKeyedUnarchiver.unarchivedObject(
//                                        ofClass: ARWorldMap.self, from: data)
//                configuration.initialWorldMap = worldMap
//            } catch {
//                printLog("load worldmap error: \(error)")
//            }
//        }
        
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @IBAction func clickedDone(_ sender: UIButton) {
        
        sceneView.session.getCurrentWorldMap {
            [weak self] worldMap, error in
            
            guard let worldMap = worldMap else {
                printLog("error: \(String(describing: error))")
                return
            }
            
            if let loc = self!.lastLocation {
                self!.writeWorldMap(map: worldMap, at: loc)
            }
            //do {
            //    let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: false)
            //    try data.write(to: FileManager.mapDataURL())
            //} catch {
            //    printLog("click done error: \(error)")
            //}
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    func writeWorldMap(map: ARWorldMap, at location: CLLocation) {
        
        do {
            let nsmap = try NSKeyedArchiver.archivedData(withRootObject: map,
                                                         requiringSecureCoding: false)

            // firestore persistence
            db.collection(K.FStore.worldMapCollection)
                .addDocument(data: [
                    K.FStore.timestamp: Timestamp(date: Date()),
                    K.FStore.latitude: location.coordinate.latitude,
                    K.FStore.longitude: location.coordinate.longitude,
                    K.FStore.worldMap: nsmap
                ]) { error in
                    if let e = error {
                        printLog("Firestore write error: \(e)")
                    }
                }
        } catch {
            printLog("Firebase save world: \(error)")
        }
    }
    
    func restoreStoredWorldMap(_ configuration: ARWorldTrackingConfiguration) {
        
        db.collection(K.FStore.worldMap)
            .order(by: K.FStore.timestamp, descending: true).limit(to: 1)
            .getDocuments { querySnapshot, error in
                
            if let err = error {
                printLog("Error getting Firebase worldmap: \(err)")
            } else {
                if let docs = querySnapshot?.documents,
                   let doc = docs.last {
                    
                    let data = doc.data()
                    if let timestamp = data[K.FStore.timestamp] as? Timestamp,
                       let lat = data[K.FStore.latitude] as? Double,
                       let long = data[K.FStore.longitude] as? Double,
                       let nsmap = data[K.FStore.worldMap] as? Data {
                        
                        let lastLocation = CLLocation(latitude: lat, longitude: long)
                        do {
                            if let storedWorldMap = try NSKeyedUnarchiver.unarchivedObject(
                                ofClass: ARWorldMap.self, from: nsmap) {
                                                        
                                print("**> time: \(timestamp.dateValue()), \(lastLocation), \(String(describing: storedWorldMap))")

                                print("****> anchors: \(storedWorldMap.anchors.count)")
                                
                                configuration.initialWorldMap = storedWorldMap
                                print("$$$> anchors: \(storedWorldMap.anchors.count)")
                                self.displayAnchors(storedWorldMap.anchors)
                            }
                        } catch {
                            printLog("Firebase load worldmap error: \(error)")
                        }
                    }
                }
            }
        }
    }


    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        doneButton.isEnabled = true // frame.worldMappingStatus == .mapped
        
        switch frame.worldMappingStatus {
        case .limited: statusLabel.text = "Limited"
        case .extending: statusLabel.text = "Extending"
        case .mapped: statusLabel.text = "Mapped"
        default: statusLabel.text = "Not Available"
        }
    }
    
    // MARK: - ARSKViewDelegate
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        return getSpriteNode(anchor)
    }
    
    func displayAnchors(_ anchors: [ARAnchor]) {
        
        print("$$$$$> anchors: \(anchors.count)")

        for anchor in anchors {
            print(">>>>>>>>> anchor: \(anchor.name): \(String(describing: anchor))")
        }
    }
    
    func getSpriteNode(_ anchor: ARAnchor) -> SKNode? {
        
        if let name = anchor.name,
           name == K.TEXT_ANCHOR {
            return ViewUtilities.getSprite(symbol: "👆")
        } else {
            print("getSpriteNode: not TEXT \(anchor.name)")
            return ViewUtilities.getSprite(symbol: "🟡")
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
