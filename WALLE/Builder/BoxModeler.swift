//
//  boxproc.swift
//  Boxify
//
//  Created by lvwei on 16/09/2017.
//  Copyright © 2017 Juran. All rights reserved.
//

import ARKit
import SceneKit

class BoxModeler : Modeler {
    
    enum InteractionMode {
        case waitingForLocation
        case draggingInitialWidth, draggingInitialLength
        case waitingForFaceDrag, draggingFace(side: Box.Side, dragStart: SCNVector3)
    }


    var panGesture: UIPanGestureRecognizer!
    var tapGesture: UITapGestureRecognizer!
    var doubleTapGesture: UITapGestureRecognizer!
    var rotationGesture: UIRotationGestureRecognizer!

    var hitTestPlane: SCNNode!
    var floor: SCNNode!
    
    var box : Box!
    
    override func model() -> SCNNode {
        return box
    }
    
    var mode: InteractionMode = .waitingForLocation {
        didSet {
            switch mode {
            case .waitingForLocation:
                rotationGesture.isEnabled = false
                
                box.isHidden = true
                box.clearHighlights()
                
                hitTestPlane.isHidden = true
                floor.isHidden = true
                
                planesShown = true
                indicatorShown = true
                
            case .draggingInitialWidth, .draggingInitialLength:
                rotationGesture.isEnabled = true
                
                box.isHidden = false
                box.clearHighlights()
                
                floor.isHidden = false
                
                // Place the hit-test plane flat on the z-axis, aligned with the bottom of the box.
                hitTestPlane.isHidden = false
                hitTestPlane.position = .zero
                hitTestPlane.boundingBox.min = SCNVector3(x: -1000, y: 0, z: -1000)
                hitTestPlane.boundingBox.max = SCNVector3(x: 1000, y: 0, z: 1000)
                
                planesShown = true
                indicatorShown = true
                
            case .waitingForFaceDrag:
                rotationGesture.isEnabled = true
                
                box.isHidden = false
                box.clearHighlights()
                
                floor.isHidden = false
                hitTestPlane.isHidden = true
                
                planesShown = false
                indicatorShown = false
                
            case .draggingFace(let side, let dragStart):
                rotationGesture.isEnabled = true
                
                box.isHidden = false
                floor.isHidden = false
                
                hitTestPlane.isHidden = false
                hitTestPlane.position = dragStart
                
                planesShown = false
                indicatorShown = false
                
                box.highlight(side: side)
                
                // Place the hit-test plane straight through the dragged side, centered at the point on which the drag started.
                // This makes the drag operation act as though you're dragging that exact point on the side to a new location.
                // TODO: the plane should be constrained so that it always rotates to face the camera along the axis that goes through the dragged side.
                switch side.axis {
                case .x:
                    hitTestPlane.boundingBox.min = SCNVector3(x: -1000, y: -1000, z: 0)
                    hitTestPlane.boundingBox.max = SCNVector3(x: 1000, y: 1000, z: 0)
                case .y:
                    hitTestPlane.boundingBox.min = SCNVector3(x: -1000, y: -1000, z: 0)
                    hitTestPlane.boundingBox.max = SCNVector3(x: 1000, y: 1000, z: 0)
                case .z:
                    hitTestPlane.boundingBox.min = SCNVector3(x: 0, y: -1000, z: -1000)
                    hitTestPlane.boundingBox.max = SCNVector3(x: 0, y: 1000, z: 1000)
                }
            }
        }
    }

    override func setup() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))

        doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        
        rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation))
        
        box = Box()
        box.isHidden = true

        // Create an invisible plane used for hit-testing during drag operations.
        // This is a child of the box, so it inherits the box's own transform.
        // It is resized and repositioned within the box depending on what part of the box is being dragged.
        hitTestPlane = SCNNode()
        hitTestPlane.isHidden = true
        box.addChildNode(hitTestPlane)
        
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
        
        box.addChildNode(floor)
        box.categoryBitMask |= RenderingCategory.reflected.rawValue
        
        mode = .waitingForLocation
    }
    
    // MARK: - Touch handling
    
    @objc dynamic func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch mode {
        case .waitingForLocation: break
        case .draggingInitialWidth: break
        case .draggingInitialLength: break
        case .waitingForFaceDrag:
            findFaceDragLocation(gestureRecognizer)
        case .draggingFace:
            handleFaceDrag(gestureRecognizer)
        }
    }
    
    @objc dynamic func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        
        switch mode {
        case .waitingForLocation:
            findStartingLocation(pos: indicator.center)
        case .draggingInitialWidth:
            handleInitialWidthDrag(pos: indicator.center)
        case .draggingInitialLength:
            handleInitialLengthDrag(pos: indicator.center)
        case .waitingForFaceDrag: break
        case .draggingFace: break
        }
    }
    
    override func updateAtTime(pos: CGPoint) {
        switch mode {
        case .waitingForLocation:break
        case .draggingInitialWidth:
            if let locationInWorld = sceneView.scenekitHit(at: pos, within: hitTestPlane) {
                // This drags a line out that determines the box's width and its orientation:
                // The box's front will face 90 degrees clockwise out from the line being dragged.
                let delta = box.position - locationInWorld
                let distance = delta.length
                
                let angleInRadians = atan2(delta.z, delta.x)
                
                box.move(side: .right, to: distance)
                box.rotation = SCNVector4(x: 0, y: 1, z: 0, w: -(angleInRadians + Float.pi))
            }
        case .draggingInitialLength:
            if let locationInWorld = sceneView.scenekitHit(at: pos, within: hitTestPlane) {
                // Check where the hit vector landed within the box's own coordinate system, which may be rotated.
                let locationInBox = box.convertPosition(locationInWorld, from: nil)
                
                // Front side faces toward +z, back side toward -z
                if locationInBox.z < 0 {
                    box.move(side: .front, to: 0)
                    box.move(side: .back, to: locationInBox.z)
                } else {
                    box.move(side: .front, to: locationInBox.z)
                    box.move(side: .back, to: 0)
                }
            }
        case .waitingForFaceDrag: break
        case .draggingFace: break
        }
    }
    
    @objc dynamic func handleDoubleTap(_ gestureRecognizer: UIPanGestureRecognizer) {
        resetBox()
    }
    
    // MARK: Twist-to-rotate gesture handling
    
    fileprivate var lastRotation = CGFloat(0)
    @objc dynamic func handleRotation(_ gestureRecognizer: UIRotationGestureRecognizer) {
        let currentRotation = gestureRecognizer.rotation
        switch gestureRecognizer.state {
        case .began:
            lastRotation = currentRotation
        case .changed:
            let rotationDelta = currentRotation - lastRotation
            lastRotation = currentRotation
            
            let rotation = SCNQuaternion(radians: -Float(rotationDelta), around: .axisY)
            let rotationPivot = box.pointInBounds(at: SCNVector3(x: 0.5, y: 0, z: 0.5))
            let pivotInWorld = box.convertPosition(rotationPivot, to: nil)
            box.rotate(by: rotation, aroundTarget: pivotInWorld)
        default:
            break
        }
    }
    
    // MARK: Drag Gesture handling
    
    func findStartingLocation(pos: CGPoint) {
        
        let hit = sceneView.realWorldHit(at: pos)
        if let startPos = hit.position, let plane = hit.planeAnchor {
            // Once the user hits a usable real-world plane, switch into line-dragging mode
            box.position = startPos
            currentAnchor = plane
            mode = .draggingInitialWidth
        }
    }
    
    func handleInitialWidthDrag(pos: CGPoint) {
        
        if abs(box.boundingBox.max.x - box.boundingBox.min.x) >= box.minLabelDistanceThreshold {
            // If the box ended up with a usable width, switch to length-dragging mode.
            mode = .draggingInitialLength
        } else {
            // Otherwise, give up on this drag and start again.
            resetBox()
        }
        
    }
    
    func handleInitialLengthDrag(pos: CGPoint) {
        if (box.boundingBox.max.z - box.boundingBox.min.z) >= box.minLabelDistanceThreshold {
            mode = .waitingForFaceDrag
        }
    }
    
    func findFaceDragLocation(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began, .changed:
            let touchPos = gestureRecognizer.location(in: sceneView)
            
            // Test if the user managed to hit a face of the box: if so, transition into dragging that face
            for (side, node) in box.faces {
                let hitResults = sceneView.hitTest(touchPos, options: [
                    .rootNode: node,
                    .firstFoundOnly: true,
                    ])
                
                if let result = hitResults.first {
                    let coordinatesInBox = box.convertPosition(result.localCoordinates, from: result.node)
                    mode = .draggingFace(side: side, dragStart: coordinatesInBox)
                    return
                }
            }
        default:
            break
        }
    }
    
    func handleFaceDrag(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard case let .draggingFace(side, _) = mode else {
            return
        }
        
        switch gestureRecognizer.state {
        case .changed:
            let touchPos = gestureRecognizer.location(in: sceneView)
            if let locationInWorld = sceneView.scenekitHit(at: touchPos, within: hitTestPlane) {
                // Check where the hit vector landed within the box's own coordinate system, which may be rotated.
                let locationInBox = box.convertPosition(locationInWorld, from: nil)
                
                var distanceForAxis = locationInBox.value(for: side.axis)
                
                // Don't allow the box to be dragged inside-out: stop dragging the side at the point at which it meets its opposite side.
                switch side.edge {
                case .min:
                    distanceForAxis = min(distanceForAxis, box.boundingBox.max.value(for: side.axis))
                case .max:
                    distanceForAxis = max(distanceForAxis, box.boundingBox.min.value(for: side.axis))
                }
                
                box.move(side: side, to: distanceForAxis)
            }
        case .ended, .cancelled:
            mode = .waitingForFaceDrag
        default:
            break
        }
    }
    
    func resetBox() {
        mode = .waitingForLocation
        box.resizeTo(min: .zero, max: .zero)
        currentAnchor = nil
    }
    
    override func face() -> [SCNNode] {
        var faces = [SCNNode]()
        for (_, f) in box.faces {
            faces.append(f)
        }
        return faces
    }
    
    override func line()-> [SCNNode] {
        var lines = [SCNNode]()
        for (l) in box.lines {
            lines.append(l)
        }
        return lines
    }
    
    override func active() {
        sceneView.addGestureRecognizer(panGesture)
        sceneView.addGestureRecognizer(tapGesture)
        sceneView.addGestureRecognizer(doubleTapGesture)
        sceneView.addGestureRecognizer(rotationGesture)
        
        sceneView.scene.rootNode.addChildNode(box)
                mode = .waitingForLocation
    }
    
    override func deactive() {
        sceneView.removeGestureRecognizer(panGesture)
        sceneView.removeGestureRecognizer(tapGesture)
        sceneView.removeGestureRecognizer(doubleTapGesture)
        sceneView.removeGestureRecognizer(rotationGesture)
        
        cleanup()
    }
}
