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
    
    var hitTestPlane: SCNNode!
    var floor: SCNNode!
    
    var poly: Polygon!
    
    override func model() -> SCNNode {
        return poly
    }
    
    var mode: InteractionMode = .waitingForLocation {
        didSet {
            switch mode {
            case .waitingForLocation:
//                rotationGesture.isEnabled = false
                
                poly.isHidden = true
//                poly.clearHighlights()
                
                hitTestPlane.isHidden = true
                floor.isHidden = true
                
                //                planesShown = true
                
            case .draggingNewPoint, .draggingClosePoint:
//                rotationGesture.isEnabled = true
                
                poly.isHidden = false
//                poly.clearHighlights()
                
                floor.isHidden = false
                
                // Place the hit-test plane flat on the z-axis, aligned with the bottom of the box.
                hitTestPlane.isHidden = false
                hitTestPlane.position = .zero
                hitTestPlane.boundingBox.min = SCNVector3(x: -1000, y: 0, z: -1000)
                hitTestPlane.boundingBox.max = SCNVector3(x: 1000, y: 0, z: 1000)
                
                //                planesShown = false
            case .draggingHeightPoint:
                break
//            case .waitingForFaceDrag:
//                rotationGesture.isEnabled = true
//
//                box.isHidden = false
//                box.clearHighlights()
//
//                floor.isHidden = false
//                hitTestPlane.isHidden = true
//
//                //                planesShown = false
//
//            case .draggingFace(let side, let dragStart):
//                rotationGesture.isEnabled = true
//
//                box.isHidden = false
//                floor.isHidden = false
//
//                hitTestPlane.isHidden = false
//                hitTestPlane.position = dragStart
//
//                //                planesShown = false
//
//                box.highlight(side: side)
//
//                // Place the hit-test plane straight through the dragged side, centered at the point on which the drag started.
//                // This makes the drag operation act as though you're dragging that exact point on the side to a new location.
//                // TODO: the plane should be constrained so that it always rotates to face the camera along the axis that goes through the dragged side.
//                switch side.axis {
//                case .x:
//                    hitTestPlane.boundingBox.min = SCNVector3(x: -1000, y: -1000, z: 0)
//                    hitTestPlane.boundingBox.max = SCNVector3(x: 1000, y: 1000, z: 0)
//                case .y:
//                    hitTestPlane.boundingBox.min = SCNVector3(x: -1000, y: -1000, z: 0)
//                    hitTestPlane.boundingBox.max = SCNVector3(x: 1000, y: 1000, z: 0)
//                case .z:
//                    hitTestPlane.boundingBox.min = SCNVector3(x: 0, y: -1000, z: -1000)
//                    hitTestPlane.boundingBox.max = SCNVector3(x: 0, y: 1000, z: 1000)
//                }
            }

        }
    }
    
//    var currentAnchor: ARAnchor?
    
    override func setup() {
      
        poly = Polygon()
        poly.isHidden = true
        sceneView.scene.rootNode.addChildNode(poly)
        
        // Create an invisible plane used for hit-testing during drag operations.
        // This is a child of the box, so it inherits the box's own transform.
        // It is resized and repositioned within the box depending on what part of the box is being dragged.
        hitTestPlane = SCNNode()
        hitTestPlane.isHidden = true
        poly.addChildNode(hitTestPlane)
        
        let floorSurface = SCNFloor()
        floorSurface.reflectivity = 0.2
        floorSurface.reflectionFalloffEnd = 0.05
        floorSurface.reflectionCategoryBitMask = RenderingCategory.reflected.rawValue
        
        // Floor scene reflections are blended with the diffuse color's transparency mask, so if diffuse is transparent then no reflection will be shown.
        // To get around this, we make the floor black and use additive blending so that only the brighter reflection is shown.
        floorSurface.firstMaterial?.diffuse.contents = UIColor.black
        floorSurface.firstMaterial?.writesToDepthBuffer = false
        floorSurface.firstMaterial?.blendMode = .add
        
        floor = SCNNode(geometry: floorSurface)
        floor.isHidden = true
        
        poly.addChildNode(floor)
        poly.categoryBitMask |= RenderingCategory.reflected.rawValue
    }
 
    var closed = false
    
    override func handleNewPoint(pos: CGPoint) {
        let hit = sceneView.realWorldHit(at: pos)
        
        if let startPos = hit.position, let _ = hit.planeAnchor {
            poly.addVertex(at: startPos)
            print(startPos)
        }
        
//        var nearpos = pos.position;
//        if line != nil {
//            for l in lines {
//
//                let p2 = CGPoint(sceneView.projectPoint(l.startNode.worldPosition))
//                let dis = indicator.center - p2
//
//                if (dis.length() < 25) {
//                    nearpos = l.startNode.position
//                    closed = true
//                    break
//                }
//
//            }
//
//            _ = line?.updatePosition(pos: nearpos!, camera: self.sceneView.session.currentFrame?.camera)
//
//            line = nil
//
//        }
//
//        line = LineNode(startPos: nearpos!, sceneV: sceneView)
//        lines.append(line!)
//
//
//        if (closed) {
//
//            var nodes : [SCNNode] = []
//            for li in lines {
//                nodes.append(li.startNode)
//            }
//            poly = PolyNode.polyFromNodes(nodes: nodes)
//            sceneView?.scene.rootNode.addChildNode(poly!)
//        }
    }
}
