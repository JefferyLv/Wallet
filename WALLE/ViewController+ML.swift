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
                self.message.setTitle("Find a window, Do you need a Curtain?", for: UIControlState.normal)
            case .Light:
                self.message.setTitle("Find a roof, Do you need a Light?", for: UIControlState.normal)
            case .Tv:
                self.message.setTitle("Find a wall, Do you need a Tv?", for: UIControlState.normal)
            case .Chair:
                self.message.setTitle("Find a floor, Do you need a Chair?", for: UIControlState.normal)
            case .None:
                self.message.setTitle("", for: UIControlState.normal)
                break
            }
            
            self.messageView.isHidden = self.brain.inf.kind == .None
        }
    }
}
