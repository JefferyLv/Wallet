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
        case draggingNewPoint, draggingHeightPoint
    }
    var panGesture: UIPanGestureRecognizer!
    
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
                
            case .draggingNewPoint:
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
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        sceneView.addGestureRecognizer(panGesture)
        
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
    
    @objc dynamic func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
    }
    
    override func handleNewPoint(pos: CGPoint) {
        
        switch mode {
        case .waitingForLocation:
            findStartingLocation(pos:pos)
        case .draggingNewPoint:
            AddNewPoint(pos:pos)
        case .draggingHeightPoint: break
        }
    }
    
    override func updateAtTime(pos: CGPoint) {
        
        if let locationInWorld = sceneView.scenekitHit(at: pos, within: hitTestPlane) {
            if (mode == .draggingNewPoint) {
                let delta = locationInWorld - poly.position
                poly.buildLine(pos: delta)
            }
//            else {
//                poly.buildLine(pos: SCNVector3Zero)
//            }
        }
        
    }
    
    func findStartingLocation(pos:CGPoint) {
        let hit = sceneView.realWorldHit(at: pos)
        if let startPos = hit.position, let plane = hit.planeAnchor {
            // Once the user hits a usable real-world plane, switch into line-dragging mode
            poly.position = startPos
            poly.addVertex(at: SCNVector3Zero)
            currentAnchor = plane
            mode = .draggingNewPoint
        }
    }
    
    func AddNewPoint(pos: CGPoint) {
        if let locationInWorld = sceneView.scenekitHit(at: pos, within: hitTestPlane) {
            let delta = locationInWorld - poly.position
            let closed = findNearest(pos: delta)

            if (closed) {
                poly.addVertex(at: SCNVector3Zero)
                
                mode = .draggingHeightPoint
            } else {
                poly.addVertex(at: delta)
            }
        }
    }
    
    func AddHeightPoint(pos:CGPoint) {
        
    }
    
    func findNearest(pos:SCNVector3) -> Bool{
        for ver in poly.vertices {

            let dis = ver.position - pos
            if (dis.length < 0.1) {

                return true
            }
        }
        return false
    }

}
