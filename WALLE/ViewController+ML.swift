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
        switch brain.inf.kind {
        case .Curtain:
            DispatchQueue.global(qos: .userInitiated).async {
                
                guard let url = Bundle.main.url(forResource: "Models.scnassets/blackboard/blackboard", withExtension: "scn") else {
                    fatalError("can't find expected virtual object bundle resources")
                }
                
                self.chair = SCNReferenceNode(url:url)
                self.chair.load()
                
                self.select = self.chair
            }
        case .Light:
            break
        case .None:
            break
        }
    }
}
