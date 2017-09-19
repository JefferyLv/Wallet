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
    var indicator: UILabel!
    var currentAnchor: ARAnchor?
    
    var planesShown: Bool {
        get { return RenderingCategory(rawValue: sceneView.pointOfView!.camera!.categoryBitMask).contains(.planes) }
        set {
            var mask = RenderingCategory(rawValue: sceneView.pointOfView!.camera!.categoryBitMask)
            if newValue == true {
                mask.formUnion(.planes)
            } else {
                mask.subtract(.planes)
            }
            sceneView.pointOfView!.camera!.categoryBitMask = mask.rawValue
        }
    }
    
    var indicatorShown: Bool {
        get { return !indicator.isHidden }
        set { indicator.isHidden = !newValue }
    }
    
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
