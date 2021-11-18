//
//  HandPose.swift
//  RealityKitHandTracking
//
//  Created by Sebastian Buys on 10/27/20.
//

import Foundation
import ARKit
import RealityKit

struct HandPose {
    // Create typealiases because variable names are obnoxiously long
    typealias JointName = VNHumanHandPoseObservation.JointName
    typealias JointGroupName = VNHumanHandPoseObservation.JointsGroupName
    
    var orderedFingerJoints: [JointGroupName: [VNRecognizedPoint?]]
    
    var wristJoint: VNRecognizedPoint?
    
    var thumbJoints: [JointName: VNRecognizedPoint]
    var indexJoints: [JointName: VNRecognizedPoint]
    var middleJoints: [JointName: VNRecognizedPoint]
    var ringJoints: [JointName: VNRecognizedPoint]
    var littleJoints: [JointName:VNRecognizedPoint]
    
    
    init(_ observation: VNHumanHandPoseObservation) {
        // Grab all finger joints and sort
        self.thumbJoints = (try? observation.recognizedPoints(.thumb)) ?? [:]
        self.indexJoints = (try? observation.recognizedPoints(.indexFinger)) ?? [:]
        self.middleJoints = (try? observation.recognizedPoints(.middleFinger)) ?? [:]
        self.ringJoints = (try? observation.recognizedPoints(.ringFinger)) ?? [:]
        self.littleJoints = (try? observation.recognizedPoints(.littleFinger)) ?? [:]
        
        self.wristJoint = try? observation.recognizedPoint(.wrist)
        
        // Setup ordered arrays of each finger hierarchy
        let thumbPoints = [
            thumbJoints[.thumbCMC],  // Carpo-metacarpal
            thumbJoints[.thumbMP],   // Metacarpal
            thumbJoints[.thumbIP],   // Interphalangeal
            thumbJoints[.thumbTip]   // Tip
        ]
        
        let indexPoints = [
            indexJoints[.indexMCP],  // Metacarpo-phalangeal
            indexJoints[.indexPIP],  // Proximal inter-phalangic
            indexJoints[.indexDIP],  // Distal inter-phanagic
            indexJoints[.indexTip]   // Tip
        ]
        
        let middlePoints = [
            middleJoints[.middleMCP],
            middleJoints[.middlePIP],
            middleJoints[.middleDIP],
            middleJoints[.middleTip]
        ]
        
        let ringPoints = [
            ringJoints[.ringMCP],
            ringJoints[.ringPIP],
            ringJoints[.ringDIP],
            ringJoints[.ringTip]
        ]
        
        let littlePoints = [
            littleJoints[.littleMCP],
            littleJoints[.littlePIP],
            littleJoints[.littleDIP],
            littleJoints[.littleTip]
        ]
    
        self.orderedFingerJoints = [
            .thumb: thumbPoints,
            .indexFinger: indexPoints,
            .middleFinger: middlePoints,
            .ringFinger: ringPoints,
            .littleFinger: littlePoints
        ]
    }
}
