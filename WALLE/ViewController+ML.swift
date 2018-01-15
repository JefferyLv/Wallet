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
        brain = Brain(sceneView: sceneView, consoleLabel: console)
    }
    
    func MLInfer() {
        DispatchQueue.main.async {
            switch self.brain.inf.kind {
            case .Curtain:
                self.message.setTitle("Find a WINDOW, do you need a CURTAIN?", for: UIControlState.normal)
            case .Light:
                self.message.setTitle("Find a ROOF, do you need a LIGHT?", for: UIControlState.normal)
            case .Tv:
                self.message.setTitle("Find a WALL, do you need a TV?", for: UIControlState.normal)
            case .Chair:
                self.message.setTitle("Find a FLOOR, do you need a SOFA?", for: UIControlState.normal)
            case .None:
                self.message.setTitle("", for: UIControlState.normal)
                break
            }
            
            self.messageView.isHidden = self.brain.inf.kind == .None
        }
    }
}
