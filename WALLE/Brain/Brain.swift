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

class Brain {
    
    var scene: ARSCNView!
    
    var nose: Nose!
    var eye : Eye!
    
    init (sceneView: ARSCNView) {
        scene = sceneView
        
        nose = Nose(scene: scene)
        eye = Eye(scene: scene)
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
//        nose.smell()
        eye.look(target: target)
        evolve()
    }
    private func evolve() {
    
        if eye.finding.dir == .Wall {
            print ("wall")
        }
        if eye.finding.dir == .Roof {
            print ("roof")
        }
        if eye.finding.dir == .Floor {
            print ("floor")
        }
    }
}
