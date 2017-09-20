//
//  ViewController+Gestures.swift
//  Bob
//
//  Created by lvwei on 20/09/2017.
//  Copyright © 2017 Alun Bestor. All rights reserved.
//

import UIKit
import SceneKit
import SceneKit.ModelIO

extension ViewController {

    @objc dynamic func handleDoubleTap(_ gestureRecognizer: UITapGestureRecognizer) {

        let touchPos = gestureRecognizer.location(in: sceneView)
        
        // Test if the user managed to hit a face of the box: if so, transition into dragging that face
        
        for face in self.modeler.face() {
            
            let hitResults = sceneView.hitTest(touchPos, options: [
                .rootNode: face,
                .firstFoundOnly: true,
                ])
            
            if let result = hitResults.first {
                let coordinate = self.modeler.model().convertPosition(result.localCoordinates, from: result.node)
//                let normal = self.modeler.model().convertVector(result.localNormal, from: result.node)

//                let axis = normal.cross(SCNVector3.axisY).normalized()
//                let angle = acos(normal.dot(SCNVector3.axisY))
//                let rotation = SCNVector4(x:axis.x, y:axis.y, z:axis.z, w: -angle)
                
                let rotation = result.node.rotation
        
                // Load the content asynchronously.
                DispatchQueue.global(qos: .userInitiated).async {
                    
                    guard let url = Bundle.main.url(forResource: "Models.scnassets/paint/blackboard", withExtension: "scn") else {
                        fatalError("can't find expected virtual object bundle resources")
                    }

                    let obj = SCNReferenceNode(url:url)
                    obj?.load()
                    
//                    guard let url = Bundle.main.url(forResource: "Models.scnassets/chair/chair", withExtension: "obj") else {
//                        fatalError("Failed to find model file.")
//                    }
//
//                    let asset = MDLAsset(URL: NSURL(string: url))
//                    guard let object = asset.object(at: 0) as? MDLMesh else {
//                        fatalError("Failed to get mesh from asset.")
//                    }
//
//                    // Create a material from the various textures
//                    let scatteringFunction = MDLScatteringFunction()
//                    let material = MDLMaterial(name: "baseMaterial", scatteringFunction: scatteringFunction)
//
//                    material.setTextureProperties(textures: [.baseColor: "Models.scnassets/chair/chair.png"])
//
//                    // Apply the texture to every submesh of the asset
//                    for  submesh in object.submeshes!  {
//                        if let submesh = submesh as? MDLSubmesh {
//                            submesh.material = material
//                        }
//                    }
//
//                    let obj = SCNNode(mdlObject: object)
                    
                    obj?.position = coordinate
                    obj?.rotation = rotation
                    
                    DispatchQueue.main.async {
                        self.modeler.model().addChildNode(obj!)
                    }
                }
                break
            }
        }
    }
    
    @objc dynamic func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        
        if !indicator.isHidden {
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.allowUserInteraction,.curveEaseOut], animations: {
                self.indicator.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            }) { (value) in
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.allowUserInteraction,.curveEaseIn], animations: {
                    self.indicator.transform = CGAffineTransform.identity
                }) { (value) in
                }
            }
        }
        
        
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}
