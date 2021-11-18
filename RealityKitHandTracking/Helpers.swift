//
//  Helpers.swift
//  RealityKitHandTracking
//
//  Created by Sebastian Buys on 10/26/20.
//

import ARKit
import Foundation
import RealityKit
import UIKit

// Convert a normalized (0.0 - 1.0) point to screen pixel point
func normalizedCoordsToViewSpace(_ point: CGPoint, view: UIView) -> CGPoint {
    let pxWidth = view.bounds.size.width
    let pxHeight = view.bounds.size.height
    
    // Y-coordinate is flipped,
    // so convert by subtracting from 1
    return CGPoint(x: point.x * pxWidth,
                   y: (1 - point.y) * pxHeight)
}
