//
//  BallEntity.swift
//  RealityKitHandTracking
//
//  Created by Sebastian Buys on 10/27/20.
//

import Foundation
import RealityKit
import UIKit

class BallEntity: Entity, HasModel, HasAnchoring {
    required init(color: UIColor, radius: Float) {
        super.init()
        
        self.components[ModelComponent.self] = ModelComponent(
            mesh: .generateSphere(radius: radius),
            materials: [SimpleMaterial(
                            color: color,
                            isMetallic: false)
            ]
        )
    }
    
    convenience init(color: UIColor, position: SIMD3<Float>) {
        self.init(color: .yellow, radius: 0.25)
        self.position = position
     }
    
    required convenience init() {
        self.init(color: .yellow, radius: 0.25)
    }
}


