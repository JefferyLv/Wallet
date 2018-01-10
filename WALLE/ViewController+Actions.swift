//
//  ViewController+Actions.swift
//  Bob
//
//  Created by lvwei on 20/09/2017.
//  Copyright © 2017 Juran. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

import LiquidFloatingActionButton

extension ViewController: LiquidFloatingActionButtonDataSource, LiquidFloatingActionButtonDelegate {
    
    func UISetup() {
        
        cells.append(LiquidFloatingCell(icon: UIImage(named: "rectangle")!))
        cells.append(LiquidFloatingCell(icon: UIImage(named: "polygon")!))
        cells.append(LiquidFloatingCell(icon: UIImage(named: "brain")!))
        
        let floatingFrame = CGRect(x: 16, y: 16, width: 56, height: 56)
        let floatingActionButton = LiquidFloatingActionButton(frame: floatingFrame)
        floatingActionButton.dataSource = self
        floatingActionButton.delegate = self
        floatingActionButton.animateStyle = .down
        floatingActionButton.color = UIColor.init(red: 100/255.0, green: 86/255.0, blue: 86/255.0, alpha: 1)
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
            brainAction()
        default:
            break
        }
        liquidFloatingActionButton.close()
    }
    
    @IBAction func acceptAction() {

        DispatchQueue.global(qos: .userInitiated).async {
            var url:URL!
            switch self.brain.inf.kind {
            case .Curtain:
                url = Bundle.main.url(forResource: "Models.scnassets/curtain/model", withExtension: "scn")!
            case .Light:
                url = Bundle.main.url(forResource: "Models.scnassets/light/model", withExtension: "scn")!
            case .None:
                url = nil
            }
            
            if (url != nil) {
                
                self.select = SCNReferenceNode(url:url)
                self.select.load()
                
                self.brain.inf.node?.addChildNode(self.select)
            }
        }

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
    
    func brainAction() {
        
        if self.brain.isAwake() {
            self.brain.sleep()
            self.modeler.setCullMode(mode: .back)
        } else {
            self.brain.wakeUp()
            self.modeler.setCullMode(mode: .front)
        }
    }
    

}
