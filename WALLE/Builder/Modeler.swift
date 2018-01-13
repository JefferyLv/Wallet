//
//  Modeler.swift
//  Boxify
//
//  Created by lvwei on 16/09/2017.
//  Copyright © 2017 Juran. All rights reserved.
//

import ARKit
import SceneKit

class Modeler : Equatable {
    static func ==(lhs: Modeler, rhs: Modeler) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
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
    
    var mod: Model!
    func model() -> SCNNode {
        return mod
    }
    
    func updateAtTime(pos: CGPoint) {
    }
    
    func setup () {
    }
    
    func cleanup() {
        model().removeFromParentNode()
        setup()
    }
    
    func face() -> [SCNNode] {
        return []
    }
    
    func line() -> [SCNNode] {
        return []
    }
    
    func setCullMode(mode: SCNCullMode) {
        for f in face() {
            f.geometry?.firstMaterial?.cullMode = mode
        }
    }
    
    func showLines(_ yes: Int) {
        for l in line() {
            l.geometry?.firstMaterial?.transparency = CGFloat(yes)
        }
    }
    
    func active() {
    }
    func deactive() {
    }
}
