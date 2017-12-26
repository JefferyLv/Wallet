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

import LiquidFloatingActionButton

extension ViewController: LiquidFloatingActionButtonDataSource, LiquidFloatingActionButtonDelegate {
    
    func UISetup() {
        
        cells.append(LiquidFloatingCell(icon: UIImage(named: "rectangle")!))
        cells.append(LiquidFloatingCell(icon: UIImage(named: "polygon")!))
        cells.append(LiquidFloatingCell(icon: UIImage(named: "chair")!))
        cells.append(LiquidFloatingCell(icon: UIImage(named: "cup")!))
        cells.append(LiquidFloatingCell(icon: UIImage(named: "brain")!))
        
        let floatingFrame = CGRect(x: 16, y: 16, width: 56, height: 56)
        let floatingActionButton = LiquidFloatingActionButton(frame: floatingFrame)
        floatingActionButton.dataSource = self
        floatingActionButton.delegate = self
        floatingActionButton.animateStyle = .right
        self.view.addSubview(floatingActionButton)
    }
    
    func numberOfCells(_ liquidFloatingActionButton: LiquidFloatingActionButton) -> Int {
        return cells.count
    }
    
    func cellForIndex(_ index: Int) -> LiquidFloatingCell {
        return cells[index]
    }
    
    func liquidFloatingActionButton(_ liquidFloatingActionButton: LiquidFloatingActionButton, didSelectItemAtIndex index: Int) {
        liquidFloatingActionButton.heartbeat()
        
        switch index {
        case 0:
            boxAction()
        case 1:
            polyAction()
        case 2:
            chairAction()
        case 3:
            cupAction()
        case 4:
            brainAction()
        default:
            break
        }
        liquidFloatingActionButton.close()
    }
    
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
    
    func polyAction() {
        if modeler == bModeler {
            bModeler.deactive()
            pModeler.active()
            modeler = pModeler
        }
    }
    
    func boxAction() {   
        if modeler == pModeler {
            pModeler.deactive()
            bModeler.active()
            modeler = bModeler
        }
    }
    
    func chairAction() {
        
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
    
    func cupAction() {
        
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
    
    func brainAction() {
        self.brain.startCoreMLUpdate()
    }
    

}
