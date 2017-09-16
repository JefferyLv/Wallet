//
//  PolyModeler.swift
//  Boxify
//
//  Created by lvwei on 16/09/2017.
//  Copyright © 2017 Alun Bestor. All rights reserved.
//

import ARKit
import SceneKit

class PolyModeler : Modeler {
    
    enum InteractionMode {
        case waitingForLocation
        case draggingNewPoint, draggingClosePoint, draggingHeightPoint
    }
    
//    var sceneView: ARSCNView!
    
    var panGesture: UIPanGestureRecognizer!
    var doubleTapGesture: UITapGestureRecognizer!
    var rotationGesture: UIRotationGestureRecognizer!
    
//    var poly: Box!
    var hitTestPlane: SCNNode!
    var floor: SCNNode!
    
//    var currentAnchor: ARAnchor?
    
    
}
