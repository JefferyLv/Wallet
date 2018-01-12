//
//  Brain.swift
//  Bob
//
//  Created by lvwei on 03/01/2018.
//  Copyright © 2018 Juran. All rights reserved.
//

import SceneKit
import ARKit
import Vision


enum Inference {
    case Curtain, Light, Tv, Chair, None
}
class bFinding : Finding {
    var kind = Inference.None
    var node : SCNNode?
}

class Brain {
    
    var scene: ARSCNView!
    
    var nose: Nose!
    var eye : Eye!
    var inf : bFinding!
    
    init (sceneView: ARSCNView, consoleLabel: UILabel) {
        scene = sceneView
        
        nose = Nose(scene: scene, console: consoleLabel)
        eye = Eye(scene: scene)
        inf = bFinding()
    }
    func openEye() {
        eye.inDetection = true
    }
    func closeEye() {
        eye.inDetection = false
    }
    func openNose() {
        nose.inDetection = true
    }
    func closeNose() {
        nose.inDetection = false
    }
    func wakeUp() {
        openEye()
        openNose()
    }
    func sleep() {
        closeEye()
        closeNose()
        
        inf.kind = .None
        inf.node = nil
    }
    func isAwake() -> Bool {
        return eye.inDetection || nose.inDetection
    }
    func run(target: Modeler) {
        nose.smell()
        eye.look(target: target)
        evolve()
    }
    private func evolve() {
        inf.kind = .None
        inf.node = eye.finding.obj
        
        if eye.finding.dir == .Wall {
            inf.kind = .Tv
            if nose.finding.cate == .Window {
                inf.kind = .Curtain
            }
        }
        if eye.finding.dir == .Roof {
            inf.kind = .Light
            if nose.finding.cate == .Light {
            }
        }
        if eye.finding.dir == .Floor {
            inf.kind = .Chair
        }
    }
}
