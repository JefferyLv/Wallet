//
//  Polygon.swift
//  Boxify
//
//  Created by lvwei on 16/09/2017.
//  Copyright © 2017 Juran. All rights reserved.
//

import SceneKit

class Polygon: SCNNode {
    
    let labelMargin = Float(0.01)
    
    let lineWidth = CGFloat(0.005)
    
    let vertexRadius = CGFloat(0.005)
    
    let fontSize = Float(0.025)
    
    /// Don't show labels on axes that are less than this length
    let minLabelDistanceThreshold = Float(0.01)
    
    /// At heights below this, the box will be flattened until it becomes completely 2D
    let minHeightFlatteningThreshold = Float(0.05)
    
    let lengthFormatter: NumberFormatter
    
    var vertices: [SCNNode] = []
    var lines: [SCNNode] = []
    
    var sideLines: [SCNNode] = []
    var sideFaces: [SCNNode] = []
    var topLines: [SCNNode] = []
    var topVerts: [SCNNode] = []
    var bottomFace: SCNNode? = nil
    var topFace: SCNNode? = nil
    var trackingline: SCNNode = Adorner.makeLine()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        self.lengthFormatter = NumberFormatter()
        self.lengthFormatter.numberStyle = .decimal
        self.lengthFormatter.maximumFractionDigits = 1
        self.lengthFormatter.multiplier = 100
        
        super.init()
        
        self.addChildNode(self.trackingline)
    }
    
    func addVertex(at pos: SCNVector3) {
        
        let vertex = Adorner.makeVertex()
        vertex.position = pos
        addChildNode(vertex)
        
        vertices.append(vertex)
        buildLines()
    }
    
    func buildLines() {
        if vertices.count < 2 {
            return
        }
        
        let endPos = vertices[vertices.count - 1].position
        let startPos = vertices[vertices.count - 2].position
        
        let line = Adorner.makeLine()
        Adorner.updateLine(line, from: startPos, to: endPos)
        addChildNode(line)
        
        lines.append(line)
    }
    
    func buildLine(pos: SCNVector3) {
        Adorner.updateLine(trackingline, from: (vertices.last?.position)!, to: pos)
    }
    
    func closeLine() {
        let startPos = vertices.first?.position
        let endPos = vertices.last?.position
        
        let line = Adorner.makeLine()
        Adorner.updateLine(line, from: startPos!, to: endPos!)
        addChildNode(line)
        
        lines.append(line)
    }
    
    func buildFace()
    {
        bottomFace = Adorner.makePolygon(nodes: vertices)
        addChildNode(bottomFace!)
        
        topFace = Adorner.makePolygon(nodes: vertices)
        addChildNode(topFace!)
        
        buildWalls()
        buildSides()
        buildTops()
    }
    
    func updateTop(height: Float) {
        topFace?.position.y = height
        
        updateWalls(height: CGFloat(height))
    }
    
    func buildTops() {
        for line in lines {
            let cline = line.clone()
            
            addChildNode(cline)
            
            topLines.append(cline)
        }
        
        for vert in vertices {
            let cvert = vert.clone()
            
            addChildNode(cvert)
            topVerts.append(cvert)
        }
    }
    
    func buildSides() {
        for vertex in vertices {
            let line = Adorner.makeLine()
            Adorner.updateLine(line, from: vertex.position, to: vertex.position)
            addChildNode(line)
            
            sideLines.append(line)
        }
    }
    
    func buildWalls() {
        
        for line in lines {
            let sideface = Adorner.makeFace(orientation: SCNVector4Zero)
            sideface.rotation = line.rotation
            sideface.position = line.position
            
            let geoFace = sideface.geometry as! SCNPlane
            let geoLine = line.geometry as! SCNBox
            geoFace.width = geoLine.width
            geoFace.height = 0
            
            addChildNode(sideface)
            
            sideFaces.append(sideface)
        }
        
    }
    
    func updateWalls(height: CGFloat) {
        
        for face in sideFaces {
            face.position.y = Float(height / 2)
            
            let geoFace = face.geometry as! SCNPlane
            geoFace.height = height
        }
        
        for i in 0...sideLines.count - 1 {
            let fromPos = vertices[i].position
            var toPos = vertices[i].position
            toPos.y = Float(height)
            Adorner.updateLine(sideLines[i], from: fromPos, to: toPos)
        }
        
        for line in topLines {
            line.position.y = Float(height)
        }
        
        for vert in topVerts {
            vert.position.y = Float(height)
        }
    }
    
    func highlight(face: SCNNode) {
        setOpacity(face: face, opacity: 0.8, color: #colorLiteral(red: 0.8736846447, green: 0.9426622987, blue: 0.9978836179, alpha: 1))
    }
    
    func clearHighlight() {
        let faces = [topFace, bottomFace]
        for face in faces {
            if (face != nil) {
                setOpacity(face: face!, opacity: 0.1, color: UIColor.white)
            }
        }
    }
    
    func setOpacity(face: SCNNode, opacity: CGFloat, color: UIColor) {
        //        guard let geoface = face.geometry as? SCNPlane else {
        //            fatalError("No face found")
        //        }
        
        face.geometry?.firstMaterial?.diffuse.contents = color
        face.geometry?.firstMaterial?.transparency = opacity
        face.geometry?.firstMaterial?.writesToDepthBuffer = (opacity >= 0.8)
    }
    
}
