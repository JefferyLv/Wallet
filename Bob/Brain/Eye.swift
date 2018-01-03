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
    
    func look(target: Modeler) {
        dispatchQueueAR.async {
            if self.inDetection {
                self.predict(pos: self.sceneView.center, target: target)
            }
        }
    }
    
    func predict(pos: CGPoint, target: Modeler) {
        
        for face in target.face() {
            
            let hitResults = sceneView.hitTest(pos, options: [
                .rootNode: face,
                .firstFoundOnly: true,
                ])
            
            face.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            face.geometry?.firstMaterial?.transparency = 0.1
            
            if let result = hitResults.first {
                result.node.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                result.node.geometry?.firstMaterial?.transparency = 0.6
            }
        }
    }
}
