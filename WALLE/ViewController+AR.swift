//
//  ViewController+AR.swift
//  Bob
//
//  Created by lvwei on 26/12/2017.
//  Copyright © 2017 Juran. All rights reserved.
//

import ARKit

struct RenderingCategory: OptionSet {
    let rawValue: Int
    static let reflected = RenderingCategory(rawValue: 1 << 1)
    static let planes = RenderingCategory(rawValue: 1 << 2)
}

extension ViewController: ARSCNViewDelegate {
    // MARK: - ARSCNViewDelegate
    
    func ARSetup() {
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.antialiasingMode = .multisampling4X
        sceneView.autoenablesDefaultLighting = true
        
        bModeler = BoxModeler(scene: sceneView)
        bModeler.indicator = indicator
        bModeler.setup()
        
        pModeler = PolyModeler(scene: sceneView)
        pModeler.indicator = indicator
        pModeler.setup()
        
        modeler = bModeler
        bModeler.active()
    }
    
    // Highlight detected planes in the view with a surface so we can see what the hell we're doing
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return nil
        }
        
        let plane = SCNBox(width: CGFloat(planeAnchor.extent.x),
                           height: 0.0001,
                           length: CGFloat(planeAnchor.extent.z),
                           chamferRadius: 0)
        
        if let material = plane.firstMaterial {
            material.lightingModel = .constant
            material.diffuse.contents = UIColor.white
            material.transparency = 0.1
            material.writesToDepthBuffer = false
        }
        
        let node = SCNNode(geometry: plane)
        node.categoryBitMask = RenderingCategory.planes.rawValue
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, let plane = node.geometry as? SCNBox else {
            return
        }
        
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.length = CGFloat(planeAnchor.extent.z)
        
        // If this anchor is the one the box is positioned relative to, then update the box to match any corrections to the plane's observed position.
        if plane == modeler.currentAnchor {
            let oldPos = node.position
            let newPos = SCNVector3.positionFromTransform(planeAnchor.transform)
            let delta = newPos - oldPos
            modeler.model().position += delta
        }
        
        node.transform = SCNMatrix4(planeAnchor.transform)
        node.pivot = SCNMatrix4(translationByX: -planeAnchor.center.x, y: -planeAnchor.center.y, z: -planeAnchor.center.z)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.modeler.updateAtTime(pos: self.indicator.center)
        }
        
        if (self.brain.isAwake()) {
            self.brain.run(target: self.modeler)
        }
        MLInfer()
    }

}
