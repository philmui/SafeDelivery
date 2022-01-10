//
//  Scene.swift
//  SafeDelivery
//
//  Created by Phil Mui on 11/15/21.
//

import SpriteKit
import ARKit
import LogStore

class Scene: SKScene {
    
    
    override func didMove(to view: SKView) {
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
  
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        guard let touch = touches.first else { return }
        let point = touch.location(in: sceneView)
        
        guard let hitTestResult = sceneView.hitTest(point, types: .existingPlane).first else {
            print("no plane at: \(String(describing: point))")
            return
        }
        let anchor = ARAnchor(name: K.TEXT_ANCHOR, transform: hitTestResult.worldTransform)
        sceneView.session.add(anchor: anchor)
        
        print("touch: adding \(String(describing: point)): \(anchor.name)")
    }
}



/***
guard let query = sceneView.session.currentFrame?.raycastQuery(from: point,
                                                               allowing: .existingPlaneGeometry,
                                                               alignment: .any) else { return }

let results = sceneView.session.raycast(query)

guard let hitTestResult = results.first else {
    printLog("No surface found")
    return
}
***/
