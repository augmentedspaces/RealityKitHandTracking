//
//  ARFrameHandTracker.swift
//  RealityKitHandTracking
//
//  Created by Sebastian Buys on 10/27/20.
//

import Foundation
import RealityKit
import ARKit
import Vision

class ARFrameHandTracker: NSObject {
    var delegate: ARFrameHandTrackerDelegate?
    
    // A request that detects a human hand pose.
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    
    // Do the tracking on a background thread so the main UI doesn't slow down
    private let analysisQueue =
        DispatchQueue(label: "HandPoseAnalysisQueue",
                      qos: .userInteractive)
    
    init(maximumHandCount: Int = 1) {
        handPoseRequest.maximumHandCount = maximumHandCount
    }
    
    func analyzeFrame(_ frame: ARFrame) {
        analysisQueue.async { [weak self] in
            guard let self = self else { return }
            self.performHandPoseRequest(frame)
        }
    }
    
    private func performHandPoseRequest(_ frame: ARFrame) {
        // Create a CMSampleBuffer from the video frame's captured image
        // CMSampleBuffer is the object type required by the Vision framework
        guard let buffer = frame.capturedImageSampleBuffer else {
            return
        }
        
        // Image analysis request handler
        let handler = VNImageRequestHandler(cmSampleBuffer: buffer,
                                            orientation: .up,
                                            options: [:])
        
        do {
            // Perform VNDetectHumanHandPoseRequest
            try handler.perform([self.handPoseRequest])
            
            guard let observations = self.handPoseRequest.results else {
                return
            }
            
            let poses = observations.map {
                HandPose($0)
            }
            
            self.delegate?.onHandTrackingResult(poses)
        } catch {
            print("Error performing VNDetectHumanHandPoseRequest:", error)
        }
    }
}

extension ARFrame {
    /**
     Some jiu jitsu for converting ARFrame pixel data to CMSampleBuffer.
     */
    
    var capturedImageSampleBuffer: CMSampleBuffer? {
        // Grab the image associated with the video frame
        let capturedImage = self.capturedImage
        
        // Timing info
        let scale = CMTimeScale(NSEC_PER_SEC)
        let pts = CMTime(value: CMTimeValue(self.timestamp * Double(scale)),
                         timescale: scale)
        
        let timingInfo = CMSampleTimingInfo(duration: CMTime.invalid,
                                            presentationTimeStamp: pts,
                                            decodeTimeStamp: CMTime.invalid)
        
        var formatDescription: CMVideoFormatDescription? = nil
        
        CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: nil,
            imageBuffer: capturedImage,
            formatDescriptionOut: &formatDescription
        )
        
        guard let description = formatDescription else { return nil }
        
        do {
            let sampleBuffer = try CMSampleBuffer(imageBuffer: capturedImage,
                                                  formatDescription: description,
                                                  sampleTiming: timingInfo)
            
            return sampleBuffer
            
        } catch  {
            print("Error converting ARFrame.capturedImage to CMSampleBuffer")
            return nil
        }
    }
}

protocol ARFrameHandTrackerDelegate {
    func onHandTrackingResult(_ handPoses: [HandPose])
}
