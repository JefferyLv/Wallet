//
//  PolyModeler.swift
//  Boxify
//
//  Created by lvwei on 16/09/2017.
//  Copyright © 2017 Juran. All rights reserved.
//

import ARKit
import SceneKit

class PolyModeler : Modeler {
    
    enum InteractionMode {
        case waitingForLocation
        case draggingNewPoint, draggingHeightPoint
        case draggingTop(dragStart: SCNVector3)
        
    }
    
    enum InteractionState {
        case findCorner
        case addCorner
        case findBase
        case updateRoof
        case updateWall
    }
    
    
    var panGesture: UIPanGestureRecognizer!
    var tapGesture: UITapGestureRecognizer!
    
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
                poly.clearHighlight()
                
                hitTestPlane.isHidden = true
                floor.isHidden = true
                
                planesShown = true
                indicatorShown = true
                
            case .draggingNewPoint:
                //                rotationGesture.isEnabled = true
                
                poly.isHidden = false
                poly.clearHighlight()
                
                floor.isHidden = false
                
                // Place the hit-test plane flat on the z-axis, aligned with the bottom of the box.
                hitTestPlane.isHidden = false
                hitTestPlane.position = .zero
                hitTestPlane.boundingBox.min = SCNVector3(x: -1000, y: 0, z: -1000)
                hitTestPlane.boundingBox.max = SCNVector3(x: 1000, y: 0, z: 1000)
                
                planesShown = true
                indicatorShown = true
                
            case .draggingHeightPoint:
                
                poly.isHidden = false
                poly.clearHighlight()
                
                planesShown = false
                indicatorShown = false
                
            case .draggingTop(let dragStart):
                
                floor.isHidden = false
                
                hitTestPlane.isHidden = false
                hitTestPlane.position = dragStart
                
                hitTestPlane.boundingBox.min = SCNVector3(x: -1000, y: -1000, z: 0)
                hitTestPlane.boundingBox.max = SCNVector3(x: 1000, y: 1000, z: 0)
                
                planesShown = false
                indicatorShown = false
                
                poly.highlight(face: poly.topFace!)
            }
        }
    }
    
    //    var currentAnchor: ARAnchor?
    
    override func setup() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        poly = Polygon()
        poly.isHidden = true
        
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
        
        mode = .waitingForLocation
    }
    
    var closed = false
    
    @objc dynamic func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        switch mode {
        case .waitingForLocation: break
        case .draggingNewPoint: break
        case .draggingHeightPoint: 
            AddHeightPoint(gestureRecognizer)
        case .draggingTop:
            HandleTopDrag(gestureRecognizer)
            
        }
    }
    
    @objc dynamic func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        
        switch mode {
        case .waitingForLocation:
            findStartingLocation(pos: indicator.center)
        case .draggingNewPoint:
            AddNewPoint(pos: indicator.center)
        case .draggingHeightPoint: break
        case .draggingTop: break
        }
    }
    
    override func updateAtTime(pos: CGPoint) {
        guard case .draggingNewPoint = mode else {
            poly.trackingline.isHidden = true
            
            return
        }
        
        poly.trackingline.isHidden = false
        if let locationInWorld = sceneView.scenekitHit(at: pos, within: hitTestPlane) {
            
            let delta = locationInWorld - poly.position
            poly.buildLine(pos: delta)
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
                poly.closeLine()
                
                poly.buildFace()
                
                mode = .draggingHeightPoint
            } else {
                poly.addVertex(at: delta)
            }
        }
    }
    
    func AddHeightPoint(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began, .changed:
            let touchPos = gestureRecognizer.location(in: sceneView)
            
            // Test if the user managed to hit a face of the box: if so, transition into dragging that face
            
            let hitResults = sceneView.hitTest(touchPos, options: [
                .rootNode: self.poly.topFace!,
                .firstFoundOnly: true,
                ])
            
            if let result = hitResults.first {
                let coordinatesInBox = poly.convertPosition(result.localCoordinates, from: result.node)
                mode = .draggingTop(dragStart: coordinatesInBox)
                return
            }
        default:
            break
        }
    }
    
    func HandleTopDrag(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .changed:
            let touchPos = gestureRecognizer.location(in: sceneView)
            if let locationInWorld = sceneView.scenekitHit(at: touchPos, within: hitTestPlane) {
                let locationInBox = poly.convertPosition(locationInWorld, from: nil)
                
                let distanceForAxis = locationInBox.value(for: .y)
                poly.updateTop(height: distanceForAxis)
            }
        case .ended, .cancelled:
            mode = .draggingHeightPoint
        default:
            break
        }
    }
    
    func findNearest(pos:SCNVector3) -> Bool{
        for ver in poly.vertices {
            
            let dis = ver.position - pos
            if (dis.length < 0.05) {
                
                return true
            }
        }
        return false
    }
    
    override func active() {
        sceneView.addGestureRecognizer(panGesture)
        sceneView.addGestureRecognizer(tapGesture)
        
        sceneView.scene.rootNode.addChildNode(poly)
        mode = .waitingForLocation
    }
    
    override func deactive() {
        sceneView.removeGestureRecognizer(panGesture)
        sceneView.removeGestureRecognizer(tapGesture)
        
        cleanup()
    }
    
    override func face() -> [SCNNode] {
        return poly.sideFaces
    }
}
