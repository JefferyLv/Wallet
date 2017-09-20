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
    
    static func updateLine(_ line: SCNNode, from startPos: SCNVector3, to endPos: SCNVector3) {
        guard let box = line.geometry as? SCNBox else {
            fatalError("Tried to update something that is not a line")
        }

        let vec = endPos - startPos
        let dis = vec.length

        let axis = vec.cross(SCNVector3.axisX).normalized()
        let angle = acos(vec.dot(SCNVector3.axisX) / dis)
        
        line.rotation = SCNVector4(x:axis.x, y:axis.y, z:axis.z, w: -angle)
        line.position = startPos + vec / 2
        
        box.width = CGFloat(dis)
    }
    
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
        node.geometry?.firstMaterial?.isDoubleSided = true
        node.orientation = orientation
        
        return node
    }
    
    static func makePolygon(nodes: [SCNNode]) -> SCNNode {
        
        var vertices : [SCNVector3] = []
        for node in nodes {
            vertices.append(node.position)
        }
        let source = SCNGeometrySource(vertices: vertices)
        
        var indices : [Int32] = [Int32(nodes.count)]
        for idx in 0..<nodes.count {
            indices.append(Int32(idx))
        }
        let indexData = NSData(bytes: indices, length: MemoryLayout<Int32>.size * indices.count)
        let element = SCNGeometryElement(data: indexData as Data, primitiveType: .polygon, primitiveCount: 1, bytesPerIndex: MemoryLayout<Int32>.size)
        
        let poly = SCNGeometry(sources: [source], elements: [element])
        
        poly.firstMaterial?.lightingModel = .constant
        poly.firstMaterial?.diffuse.contents = UIColor.white
        poly.firstMaterial?.transparency = 0.2
        poly.firstMaterial?.isDoubleSided = true
        
        return SCNNode(geometry: poly)
    }
}
