//
//  ViewController+Actions.swift
//  Bob
//
//  Created by lvwei on 20/09/2017.
//  Copyright © 2017 Alun Bestor. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

extension ViewController {
    
    
    @IBAction func restartAction(_ sender: UIButton) {
        
        modeler.cleanup()
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    @IBAction func infoAction(_ sender: UIButton) {
        showDebugVisuals = !showDebugVisuals
        if showDebugVisuals {
            sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        }else{
            sceneView.debugOptions = []
        }
    }
    
    @IBAction func polyAction(_ sender: UIButton) {
        polyButton.isSelected = true
        boxButton.isSelected = false
        
        if modeler == bModeler {
            bModeler.deactive()
            pModeler.active()
            modeler = pModeler
        }
    }
    
    @IBAction func boxAction(_ sender: UIButton) {
        boxButton.isSelected = true
        polyButton.isSelected = false
        
        if modeler == pModeler {
            pModeler.deactive()
            bModeler.active()
            modeler = bModeler
        }
    }

    @IBAction func chairAction(_ sender: UIButton) {
    }
    
    @IBAction func cupAction(_ sender: UIButton) {
    }
}
