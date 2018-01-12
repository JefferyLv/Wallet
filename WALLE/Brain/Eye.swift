//
//  Eye.swift
//  Bob
//
//  Created by lvwei on 02/01/2018.
//  Copyright © 2018 Juran. All rights reserved.
//

import SceneKit
import ARKit
import Vision

enum Direction {
    case Floor, Roof, Wall, None
}

class eFinding : Finding {
    var dir = Direction.None
    var obj :SCNNode?
}

class Eye {
    
    var sceneView: ARSCNView!
    var inDetection = false
    var finding: eFinding!
    var pos: CGPoint
    
    let dispatchQueueAR = DispatchQueue(label: "com.dispatchqueue.ar") // A Serial Queue
    
    init (scene: ARSCNView) {
        
        sceneView = scene
        finding = eFinding()
        pos = scene.center
    }
    
    func look(target: Modeler) {
        dispatchQueueAR.async {
            if self.inDetection {
                self.predict(pos: self.pos, target: target)
            }
        }
    }
    
    func predict(pos: CGPoint, target: Modeler) {
        
        finding.dir = .None
        finding.obj = nil

        for face in target.face() {
            
            let hitResults = sceneView.hitTest(pos, options: [
                .rootNode: face,
                .firstFoundOnly: true,
                ])
            
            if let result = hitResults.first {
                
                if (result.node.parent != target.model()) {
                    return
                }
                
                finding.obj = result.node

                if result.node.orientation.x > 0 {
                    finding.dir = .Floor
                } else if result.node.orientation.x < 0 {
                    finding.dir = .Roof
                } else {
                    finding.dir = .Wall
                }
                break
            }
        }
    }
}
