//
//  SpritesUtilities.swift
//  SafeDelivery
//
//  Created by Phil Mui on 11/22/21.
//

import Foundation
import SpriteKit
import CoreLocation
import LogStore
import Firebase
import FirebaseFirestore

public struct ViewUtilities {
    
    static func getSprite(symbol: String) -> SKNode? {
        let labelNode = SKLabelNode(text: symbol)
        labelNode.fontSize = 80
        labelNode.fontColor = .yellow
        labelNode.horizontalAlignmentMode = .center
        labelNode.verticalAlignmentMode = .center
        
        for i in 5...7 {
            let circleNode = SKShapeNode(circleOfRadius: CGFloat(20*i))
            circleNode.strokeColor = .yellow
            labelNode.addChild(circleNode)
        }
        
        return labelNode
    }
    
    
}
