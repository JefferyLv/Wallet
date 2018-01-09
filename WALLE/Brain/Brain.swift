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
    case Curtain ,Light, None
}
class bFinding : Finding {
    var kind = Inference.None
}

class Brain {
    
    var scene: ARSCNView!
    
    var nose: Nose!
    var eye : Eye!
    var inf : bFinding!
    
    init (sceneView: ARSCNView) {
        scene = sceneView
        
        nose = Nose(scene: scene)
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
        
//        if eye.finding.dir == .Wall {
            if nose.finding.cate == .Window {
                print ("window on wall")
                inf.kind = .Curtain
            }
//        }
//        if eye.finding.dir == .Roof {
            if nose.finding.cate == .Light {
                print ("light in roof")
                inf.kind = .Light
            }
//        }
        if eye.finding.dir == .Floor {
            print ("floor")
        }
    }
}
