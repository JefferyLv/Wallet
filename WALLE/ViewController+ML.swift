//
//  ViewController+ML.swift
//  Bob
//
//  Created by lvwei on 26/12/2017.
//  Copyright © 2017 Juran. All rights reserved.
//
import UIKit
import ARKit
import SceneKit

extension ViewController {
    
    func MLSetup() {
        brain = Brain(sceneView: sceneView)
    }
    
    func infer() {
        DispatchQueue.main.async {
            switch self.brain.inf.kind {
            case .Curtain:
                self.message.setTitle("Curtain", for: UIControlState.normal)
            case .Light:
                self.message.setTitle("Light", for: UIControlState.normal)
            case .None:
                self.message.setTitle("", for: UIControlState.normal)
                break
            }
        }
    }
}
