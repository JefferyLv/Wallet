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
        sender.heartbeat()
        
        modeler.cleanup()
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    @IBAction func infoAction(_ sender: UIButton) {
        sender.heartbeat()
        
        showDebugVisuals = !showDebugVisuals
        if showDebugVisuals {
            sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        }else{
            sceneView.debugOptions = []
        }
    }
    
    @IBAction func polyAction(_ sender: UIButton) {
        sender.heartbeat()
        polyButton.isSelected = true
        boxButton.isSelected = false
        
        if modeler == bModeler {
            bModeler.deactive()
            pModeler.active()
            modeler = pModeler
        }
    }
    
    @IBAction func boxAction(_ sender: UIButton) {
        sender.heartbeat()
        boxButton.isSelected = true
        polyButton.isSelected = false
        
        if modeler == pModeler {
            pModeler.deactive()
            bModeler.active()
            modeler = bModeler
        }
    }
    
    @IBAction func chairAction(_ sender: UIButton) {
        sender.heartbeat()
        
        if self.chair == nil {
            // Load the content asynchronously.
            DispatchQueue.global(qos: .userInitiated).async {
                
                guard let url = Bundle.main.url(forResource: "Models.scnassets/chair/chair", withExtension: "scn") else {
                    fatalError("can't find expected virtual object bundle resources")
                }
                
                self.chair = SCNReferenceNode(url:url)
                self.chair.load()
                
                self.select = self.chair
            }
        } else {
            self.select = self.chair
        }
    }
    
    @IBAction func cupAction(_ sender: UIButton) {
        sender.heartbeat()
        
        if self.cup == nil {
            // Load the content asynchronously.
            DispatchQueue.global(qos: .userInitiated).async {
                
                guard let url = Bundle.main.url(forResource: "Models.scnassets/paint/blackboard", withExtension: "scn") else {
                    fatalError("can't find expected virtual object bundle resources")
                }
                
                self.cup = SCNReferenceNode(url:url)
                self.cup.load()
                self.select = self.cup
            }
        } else {
            
            self.select = self.cup
        }
    }
}

//                    guard let url = Bundle.main.url(forResource: "Models.scnassets/chair/chair", withExtension: "obj") else {
//                        fatalError("Failed to find model file.")
//                    }
//
//                    let asset = MDLAsset(URL: NSURL(string: url))
//                    guard let object = asset.object(at: 0) as? MDLMesh else {
//                        fatalError("Failed to get mesh from asset.")
//                    }
//
//                    // Create a material from the various textures
//                    let scatteringFunction = MDLScatteringFunction()
//                    let material = MDLMaterial(name: "baseMaterial", scatteringFunction: scatteringFunction)
//
//                    material.setTextureProperties(textures: [.baseColor: "Models.scnassets/chair/chair.png"])
//
//                    // Apply the texture to every submesh of the asset
//                    for  submesh in object.submeshes!  {
//                        if let submesh = submesh as? MDLSubmesh {
//                            submesh.material = material
//                        }
//                    }
//
//                    let obj = SCNNode(mdlObject: object)
