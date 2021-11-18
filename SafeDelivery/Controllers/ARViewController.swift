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

class ARViewController: UIViewController, ARSKViewDelegate, ARSessionDelegate {
    
    @IBOutlet var sceneView: ARSKView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    
    var shouldRestore = false
    
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

        if shouldRestore {
            do {
                let data = try Data(contentsOf: FileManager.mapDataURL())
                let worldMap = try NSKeyedUnarchiver.unarchivedObject(
                                        ofClass: ARWorldMap.self, from: data)
                configuration.initialWorldMap = worldMap
            } catch {
                printLog("load worldmap error: \(error)")
            }
        }
        
        
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
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: false)
                try data.write(to: FileManager.mapDataURL())
                self?.dismiss(animated: true, completion: nil)
            } catch {
                printLog("click done error: \(error)")
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
        if anchor.name == K.TEXT_ANCHOR {
            // Create and configure a node for the anchor added to the view's session.
            let labelNode = SKLabelNode(text: "👆")
            labelNode.fontSize = 80
            labelNode.fontColor = .blue
            labelNode.horizontalAlignmentMode = .center
            labelNode.verticalAlignmentMode = .center
            
            for i in 5...8 {
                let circleNode = SKShapeNode(circleOfRadius: CGFloat(20*i))
                circleNode.strokeColor = .yellow
                labelNode.addChild(circleNode)
            }
            return labelNode;
        } else {
            return nil
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
