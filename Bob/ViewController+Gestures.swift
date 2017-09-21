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
                
                var rotation = SCNVector4Zero
                if select == chair {
                    var normal = self.modeler.model().convertVector(result.localNormal, from: result.node)
                    
                    normal *= -1
                    let axis = normal.cross(SCNVector3.axisY).normalized()
                    let angle = acos(normal.dot(SCNVector3.axisY))
                    rotation = SCNVector4(x:axis.x, y:axis.y, z:axis.z, w: angle)
                } else {
                    rotation = result.node.rotation
                    
                }

                
                select.position = coordinate
                select.rotation = rotation
                self.modeler.model().addChildNode(select)
                
                // Load the content asynchronously.
//                DispatchQueue.global(qos: .userInitiated).async {
//
//                    guard let url = Bundle.main.url(forResource: "Models.scnassets/paint/blackboard", withExtension: "scn") else {
//                        fatalError("can't find expected virtual object bundle resources")
//                    }
//
//                    let obj = SCNReferenceNode(url:url)
//                    obj?.load()
//
//
//
//                    obj?.position = coordinate
//                    obj?.rotation = rotation
//
//                    DispatchQueue.main.async {
//                        self.modeler.model().addChildNode(obj!)
//                    }
//                }
                break
            }
        }
    }
    
    @objc dynamic func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        
        if !indicator.isHidden {
            indicator.heartbeat()
        }

    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}
