//
//  Adoner.swift
//

import SceneKit

class Adorner {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static let lineWidth = CGFloat(0.005)
    
    static let vertexRadius = CGFloat(0.005)
    
    static let fontSize = Float(0.025)
    
    static let labelMargin = Float(0.01)
    
    /// Don't show labels on axes that are less than this length
    static let minLabelDistanceThreshold = Float(0.01)
    
    /// At heights below this, the box will be flattened until it becomes completely 2D
    static let minHeightFlatteningThreshold = Float(0.05)
    
//    static let lengthFormatter: NumberFormatter
    
//    static func makeNode(with geometry: SCNGeometry, in parentNode: SCNNode) -> SCNNode {
//        for material in geometry.materials {
//            material.lightingModel = .constant
//            material.diffuse.contents = UIColor.white
//            material.isDoubleSided = false
//        }
//
//        let node = SCNNode(geometry: geometry)
//        parentNode.addChildNode(node)
//        return node
//    }
    
    static func makeNode(with geometry: SCNGeometry) -> SCNNode {
        for material in geometry.materials {
            material.lightingModel = .constant
            material.diffuse.contents = UIColor.white
            material.isDoubleSided = false
        }
        
        let node = SCNNode(geometry: geometry)
//        parentNode.addChildNode(node)
        return node
    }
    
    static func makeVertex() -> SCNNode {
        let ball = SCNSphere(radius: vertexRadius)
        return makeNode(with: ball)
    }
    
    static func updateVertex(_ vertex: SCNNode, to position: SCNVector3) {
        guard (vertex.geometry as? SCNSphere) != nil else {
            fatalError("Tried to update something that is not a line")
        }
        
        vertex.position = position
    }
    
    static func makeLine() -> SCNNode {
        let box = SCNBox(width: lineWidth, height: lineWidth, length: lineWidth, chamferRadius: 0)
        return makeNode(with: box)
    }
    
//    static func updateLine(_ line: SCNNode, from position: SCNVector3, distance: Float, axis: SCNVector3.Axis) {
//        guard let box = line.geometry as? SCNBox else {
//            fatalError("Tried to update something that is not a line")
//        }
//
//        let absDistance = CGFloat(abs(distance))
//        let offset = distance * 0.5
//        switch axis {
//        case .x:
//            box.width = absDistance
//            line.position = position + SCNVector3(x: offset, y: 0, z: 0)
//        case .y:
//            box.height = absDistance
//            line.position = position + SCNVector3(x: 0, y: offset, z: 0)
//        case .z:
//            box.length = absDistance
//            line.position = position + SCNVector3(x: 0, y: 0, z: offset)
//        }
//    }
    
    static func makeLabel() -> SCNNode {
        // NOTE: SCNText font sizes are measured in the same coordinate systems as everything else, so font size 1.0 means a font that's 1 metre high.
        // For some reason very small font sizes gave incorrect results (e.g. invisible/misplaced geometry), so we handle font sizing using scale instead.
        
        let text = SCNText(string: "", extrusionDepth: 0.0)
        text.font = UIFont.boldSystemFont(ofSize: 1.0)
        text.flatness = 0.01
        
        let node = makeNode(with: text)
        node.setUniformScale(fontSize)
        
        return node
    }
    
    static func makeFace(orientation: SCNQuaternion) -> SCNNode {
        let plane = SCNPlane()
        let node = makeNode(with: plane)
//        node.name = side.rawValue
        node.geometry?.firstMaterial?.transparency = 0.1
        node.geometry?.firstMaterial?.writesToDepthBuffer = false
        node.orientation = orientation
        
        return node
    }
    
//    static func makeFace(for side: Side) -> SCNNode {
//        let plane = SCNPlane()
//        let node = makeNode(with: plane)
//        node.name = side.rawValue
//        node.geometry?.firstMaterial?.transparency = 0.1
//        node.geometry?.firstMaterial?.writesToDepthBuffer = false
//
//        // Rotate each face to the appropriate facing
//        switch side {
//        case .top:
//            node.orientation = SCNQuaternion(radians: -Float.pi / 2, around: .axisX)
//        case .bottom:
//            node.orientation = SCNQuaternion(radians: Float.pi / 2, around: .axisX)
//        case .front:
//            break
//        case .back:
//            node.orientation = SCNQuaternion(radians: Float.pi, around: .axisY)
//        case .left:
//            node.orientation = SCNQuaternion(radians: -Float.pi / 2, around: .axisY)
//        case .right:
//            node.orientation = SCNQuaternion(radians: Float.pi / 2, around: .axisY)
//        }
//
//        return node
//    }
}
