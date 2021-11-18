//
//  2DHandView.swift
//  RealityKitHandTracking
//
//  Created by Sebastian Buys on 10/25/20.
//

import UIKit
import Vision

/**
 Basic UIView for debugging VNHumanHandPoseObservation
 */
class HandView2D: UIView {
    private var pointRadius: CGFloat
    private var pointColor: UIColor
    
    private var lineWidth: CGFloat
    private var lineColor: UIColor
    
    private let linesLayer = CAShapeLayer()
    private var linesPath = UIBezierPath()
    
    private let pointsLayer = CAShapeLayer()
    private var pointsPath = UIBezierPath()
    
    init(pointRadius: CGFloat = 5.0,
         pointColor: UIColor = .red,
         lineWidth: CGFloat = 2.0,
         lineColor: UIColor = .white) {
        self.pointRadius = pointRadius
        self.pointColor = pointColor
        
        self.lineWidth = lineWidth
        self.lineColor = lineColor
        
        super.init(frame: .zero)
        
        self.layer.addSublayer(linesLayer)
        self.layer.addSublayer(pointsLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawPose(_ pose: HandPose) {
        // Draw wrist if the point exists
        let wristLocationView = pose.wristJoint.flatMap {
            normalizedCoordsToViewSpace($0.location, view: self)
        }
        
        if let wristLocationView = wristLocationView {
            self.pointsPath.move(to: wristLocationView)
            pointsPath.addArc(withCenter: wristLocationView,
                              radius: self.pointRadius,
                              startAngle: 0,
                              endAngle: 2 * .pi,
                              clockwise: true)
        }
        
        // Iterate through fingers
        for finger in pose.orderedFingerJoints {
            // Remove nils
            let points = finger.value.compactMap { $0 }
            
            var previousPoint = wristLocationView
            
            if let wristLocationView = wristLocationView {
                self.linesPath.move(to: wristLocationView)
                self.pointsPath.move(to: wristLocationView)
            }
            
            for point in points {
                let pointLocation = normalizedCoordsToViewSpace(point.location, view: self)
                
                // For the first point, draw from wrist if it exists
                if previousPoint != nil {
                    self.linesPath.addLine(to: pointLocation)
                }
                
                self.pointsPath.move(to: pointLocation)
                pointsPath.addArc(withCenter: pointLocation,
                                  radius: self.pointRadius,
                                  startAngle: 0,
                                  endAngle: 2 * .pi,
                                  clockwise: true)
                
                previousPoint = pointLocation
            }
        }
    }
    
    func updateHandPoses(_ poses: [HandPose]) {
        self.pointsPath.removeAllPoints()
        self.linesPath.removeAllPoints()
        
        for pose in poses {
            self.drawPose(pose)
        }
        
        self.pointsLayer.fillColor = self.pointColor.cgColor
        
        self.linesLayer.fillColor = UIColor.clear.cgColor
        self.linesLayer.lineWidth = self.lineWidth
        self.linesLayer.strokeColor = self.lineColor.cgColor

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.linesLayer.path = linesPath.cgPath
        self.pointsLayer.path = pointsPath.cgPath
        CATransaction.commit()
        
    }
}
