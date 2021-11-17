//
//  Scene.swift
//  ScavengerHunt
//
//  Created by Phil Mui on 11/15/21.
//

import SpriteKit
import ARKit

class Scene: SKScene {
        
    override func didMove(to view: SKView) {
        // Setup your scene here
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
        
        guard let hitTestResult = sceneView.hitTest(point, types: .existingPlane).first else { return }
        let anchor = ARAnchor(name: K.TEXT_ANCHOR, transform: hitTestResult.worldTransform)
        sceneView.session.add(anchor: anchor)
        
        /***
        // Create anchor using the camera's current position
        if let currentFrame = sceneView.session.currentFrame {
            
            // Create a transform with a translation of 0.2 meters in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.2
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
        }
        ***/
    }
}
