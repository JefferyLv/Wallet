//
//  ViewController+Gestures.swift
//  Bob
//
//  Created by lvwei on 20/09/2017.
//  Copyright © 2017 Juran. All rights reserved.
//

import UIKit
import SceneKit
import SceneKit.ModelIO

extension ViewController : UIGestureRecognizerDelegate {
    
    func GesturesSetup() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.delegate = self
        sceneView.addGestureRecognizer(tapGesture)
        
//        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
//        doubleTapGesture.numberOfTapsRequired = 2
//        sceneView.addGestureRecognizer(doubleTapGesture)
    }

    @objc dynamic func handleDoubleTap(_ gestureRecognizer: UITapGestureRecognizer) {

//        let touchPos = gestureRecognizer.location(in: sceneView)
        
        // Test if the user managed to hit a face of the box: if so, transition into dragging that face
        
//        for face in self.modeler.face() {
//
//            let hitResults = sceneView.hitTest(touchPos, options: [
//                .rootNode: face,
//                .firstFoundOnly: true,
//                ])
//
//            if let result = hitResults.first {
//                let coordinate = self.modeler.model().convertPosition(result.localCoordinates, from: result.node)
//
//                var rotation = SCNVector4Zero
//                if select == chair {
//                    var normal = self.modeler.model().convertVector(result.localNormal, from: result.node)
//
//                    normal *= -1
//                    let axis = normal.cross(SCNVector3.axisY).normalized()
//                    let angle = acos(normal.dot(SCNVector3.axisY))
//                    rotation = SCNVector4(x:axis.x, y:axis.y, z:axis.z, w: angle)
//                } else {
//                    rotation = result.node.rotation
//
//                }
//
//
//                select.position = coordinate
//                select.rotation = rotation
//                self.modeler.model().addChildNode(select)
//
//                break
//            }
//        }
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
