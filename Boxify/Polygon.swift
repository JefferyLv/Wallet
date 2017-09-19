//
//  Polygon.swift
//  Boxify
//
//  Created by lvwei on 16/09/2017.
//  Copyright © 2017 Alun Bestor. All rights reserved.
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
    var lines:  [SCNNode] = []
    var sideFaces:  [SCNNode] = []
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
    }
    
    func buildLine(pos: SCNVector3) {
        Adorner.updateLine(trackingline, from: (vertices.last?.position)!, to: pos)
    }
    
    func buildPoly()
    {
        bottomFace = Adorner.makePolygon(nodes: vertices)
        addChildNode(bottomFace!)
        
        topFace = bottomFace?.clone()
        addChildNode(topFace!)
    }
    
    func buildTop(y: Float) {
        topFace?.position.y = y
    }
    
    func buildWalls() {
        
    }

}
