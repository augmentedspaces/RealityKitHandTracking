//
//  ViewController.swift
//  RealityKitHandTracking
//
//  Created by Sebastian Buys on 10/25/20.
//

import UIKit
import RealityKit
import ARKit
import Vision

class ViewController: UIViewController, ARSessionDelegate, ARFrameHandTrackerDelegate {
    @IBOutlet var arView: ARView!
    
    // Instance of a custom class for hand tracking
    // See sourcecode for implementation details
    let handTracker: ARFrameHandTracker = ARFrameHandTracker(maximumHandCount: 2)

    // BallEntity is a simple custom entity
    // See included source code for details
    let thumbBall: BallEntity = BallEntity(color: .yellow, radius: 0.05)
    let indexBall: BallEntity = BallEntity(color: .yellow, radius: 0.05)
    let middleBall: BallEntity = BallEntity(color: .yellow, radius: 0.05)
    let ringBall: BallEntity = BallEntity(color: .yellow, radius: 0.05)
    let littleBall: BallEntity = BallEntity(color: .yellow, radius: 0.05)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        arView.session.delegate = self
        arView.debugOptions = []
        
        handTracker.delegate = self
        
        // HandView2D is a simple UIView that draws detected hand joints in 2D
        self.view.addSubview(handView2D)
        
        arView.scene.addAnchor(thumbBall)
        arView.scene.addAnchor(indexBall)
        arView.scene.addAnchor(middleBall)
        arView.scene.addAnchor(ringBall)
        arView.scene.addAnchor(littleBall)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // To use the front-facing camera
//        let configuration = ARFaceTrackingConfiguration()
//        arView.session.run(configuration, options: [])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.handView2D.frame = self.view.bounds
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        self.handTracker.analyzeFrame(frame)
    }
    
    // ARFrameHandTrackerDelegate delegate method
    // A "callback" function from our custom ARFrameHandTracker
    // that returns detected HandPose(s)
    
    // HandPose is just another custom class
    // that makes accessing joints easier
    func onHandTrackingResult(_ handPoses: [HandPose]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.handView2D.updateHandPoses(handPoses)
            
            // Grab the first hand pose and find the index finger tip
            guard let firstHandPose = handPoses.first else { return }
            
            self.update(ball: self.thumbBall,
                        at: firstHandPose.thumbJoints[.thumbTip])
            
            self.update(ball: self.indexBall,
                        at: firstHandPose.indexJoints[.indexTip])
            
            self.update(ball: self.middleBall,
                        at: firstHandPose.middleJoints[.middleTip])
            
            self.update(ball: self.ringBall,
                        at: firstHandPose.ringJoints[.ringTip])
            
            self.update(ball: self.littleBall,
                        at: firstHandPose.littleJoints[.littleTip])
            
           
            
            
//            guard let tip = firstHandPose.indexJoints[.indexTip] else { return }
//
//
//
//            // Convert normalized (0 - 1) point to view space (pixels)
//            let screenPosition =  normalizedCoordsToViewSpace(tip.location, view: self.arView)
//
//            // Map the 2D screen position to 3D coordinate space at a certain distance from camera
//            guard let worldPosition = self.worldPositionFor(screenPosition: screenPosition,
//                                                            distance: 2.0) else { return }
//
//            self.indexBall.position = worldPosition
        }
    }
    
    func update(ball: BallEntity, at point: VNRecognizedPoint?) {
        guard let point = point else { return }
        
        // Convert normalized (0 - 1) point to view space (pixels)
        let screenPosition =  normalizedCoordsToViewSpace(point.location, view: self.arView)
        
        // Map the 2D screen position to 3D coordinate space at a certain distance from camera
        guard let worldPosition = self.worldPositionFor(screenPosition: screenPosition,
                                                        distance: 2.0) else { return }
        
        ball.position = worldPosition
    }
    
    func worldPositionFor(screenPosition: CGPoint, distance: Float) -> SIMD3<Float>? {
        // Ray from camera origin through 2D point on screen
        guard let cameraRay = self.arView.ray(through: screenPosition) else {
            return nil
        }
        
        let cameraMatrix = simd_float4x4(translation: cameraRay.origin)
            * simd_float4x4(translation: cameraRay.direction * distance)
        
        return self.arView.unproject(screenPosition,
                                     ontoPlane: cameraMatrix,
                                     relativeToCamera: false)
    }
 
    lazy var handView2D: HandView2D = {
        return HandView2D()
    }()
}
