//
//  Eye.swift
//  Bob
//
//  Created by lvwei on 02/01/2018.
//  Copyright © 2018 Alun Bestor. All rights reserved.
//

import SceneKit
import ARKit
import Vision

class Eye {
    
    var sceneView: ARSCNView!
    var inDetection = false
    
    let dispatchQueueAR = DispatchQueue(label: "com.dispatchqueue.ar") // A Serial Queue
    
    init (scene: ARSCNView) {
        
        sceneView = scene
    }
    
    func look() {
        if self.inDetection {
            self.predict(pos: self.sceneView.center)
        }
    }
    
    func predict(pos: CGPoint) {
    }
}
