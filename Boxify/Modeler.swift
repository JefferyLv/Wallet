//
//  Modeler.swift
//  Boxify
//
//  Created by lvwei on 16/09/2017.
//  Copyright © 2017 Alun Bestor. All rights reserved.
//

import ARKit
import SceneKit

class Modeler {
    var sceneView: ARSCNView!
    var currentAnchor: ARAnchor?
    
    init (scene: ARSCNView) {
        sceneView = scene
    }
    
    func setup () {
    }
    
    var mod: Model!
    func model() -> SCNNode {
        return mod
    }
    
    func handleNewPoint(pos: CGPoint) {
        
    }
    
    func updateAtTime(pos: CGPoint) {

    }
    
}
