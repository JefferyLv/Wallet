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
    
    var vertex: [SCNNode] = []
    var lines:  [SCNNode] = []
    var faces:  [SCNNode] = []
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        self.lengthFormatter = NumberFormatter()
        self.lengthFormatter.numberStyle = .decimal
        self.lengthFormatter.maximumFractionDigits = 1
        self.lengthFormatter.multiplier = 100
        
        super.init()
    }
}
