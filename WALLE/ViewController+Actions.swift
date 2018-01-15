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
        
        cells.append(LiquidFloatingCell(icon: UIImage(named: "ruler")!))
        cells.append(LiquidFloatingCell(icon: UIImage(named: "brain")!))
        
        let floatingFrame = CGRect(x: 16, y: 16, width: 56, height: 56)
        floatingActionButton = LiquidFloatingActionButton(frame: floatingFrame)
        floatingActionButton.dataSource = self
        floatingActionButton.delegate = self
        floatingActionButton.animateStyle = .down
        floatingActionButton.color = UIColor.init(red: 242/255.0, green: 167/255.0, blue: 99/255.0, alpha: 1)
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
        
        if (self.brain.isAwake()) {
            
            self.loadContent(self.brain.eye.finding.dir, index)
            
        } else {
            switch index {
            case 0:
                boxAction()
            case 1:
                brainAction()
            default:
                break
            }
        }
        liquidFloatingActionButton.close()
//        liquidFloatingActionButton.isClosed = true
    }
    
    @IBAction func acceptAction() {

        if (self.floatingActionButton.isOpening) {
            self.floatingActionButton.close()
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            var url:URL!
            switch self.brain.inf.kind {
            case .None:
                url = nil
            case .Curtain:
                url = Bundle.main.url(forResource: "Models.scnassets/curtain/model", withExtension: "scn")!
            case .Light:
                url = Bundle.main.url(forResource: "Models.scnassets/light/model", withExtension: "scn")!
            case .Tv:
                url = Bundle.main.url(forResource: "Models.scnassets/tv/model", withExtension: "scn")!
            case .Chair:
                url = Bundle.main.url(forResource: "Models.scnassets/sofa/model", withExtension: "scn")!
            }


            if (url != nil) {
                
                self.select = SCNReferenceNode(url:url)
                self.select.load()
                self.brain.inf.node?.addChildNode(self.select)
                
                DispatchQueue.main.async {
                    self.cellSetup(self.brain.eye.finding.dir)
                    self.floatingActionButton.open()
                }
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
        
        self.console.isHidden = !showDebugVisuals
        self.modeler.showLines(showDebugVisuals ? 1: 0)
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
            self.modeler.showLines(1)
            self.indicator.isHidden = false
        } else {
            self.brain.wakeUp()
            self.modeler.setCullMode(mode: .front)
            self.modeler.showLines(0)
            self.indicator.isHidden = true
        }
    }
    

    func cellSetup(_ dir:Direction) {
        cells.removeAll()
        
        switch dir {
        case .Floor:
            cells.append(LiquidFloatingCell(icon: UIImage(named: "table")!))
            cells.append(LiquidFloatingCell(icon: UIImage(named: "chair")!))
            cells.append(LiquidFloatingCell(icon: UIImage(named: "sofa")!))
            cells.append(LiquidFloatingCell(icon: UIImage(named: "paint")!))
        case .Roof:
            cells.append(LiquidFloatingCell(icon: UIImage(named: "light")!))
        case .Wall:
            cells.append(LiquidFloatingCell(icon: UIImage(named: "tv")!))
            cells.append(LiquidFloatingCell(icon: UIImage(named: "paint")!))
        case .None:
            break
        }
    }
    
    func loadContent(_ dir:Direction, _ index: Int) {
        var url: URL! = nil
        
        if (dir == .Floor) {
            if (index == 0) {
                url = Bundle.main.url(forResource: "Models.scnassets/table/model", withExtension: "scn")!
            } else if (index == 1) {
                url = Bundle.main.url(forResource: "Models.scnassets/chair/model", withExtension: "scn")!
            } else if (index == 2) {
                url = Bundle.main.url(forResource: "Models.scnassets/sofa/model", withExtension: "scn")!
            }
        }
        
        if (dir == .Wall) {
            if (index == 0) {
                url = Bundle.main.url(forResource: "Models.scnassets/tv/model", withExtension: "scn")!
            } else if (index == 1) {
                url = Bundle.main.url(forResource: "Models.scnassets/paint/model", withExtension: "scn")!
            }
        }
        
        if (url != nil) {
 
            let newSelect = SCNReferenceNode(url:url)
            newSelect!.load()
            self.brain.inf.node?.addChildNode(newSelect!)
            self.brain.inf.node?.replaceChildNode(self.select, with: newSelect!)
            self.select.removeFromParentNode()
            self.select = newSelect
        }
        
        if (index == 3 && dir == .Floor) {
            self.brain.inf.node?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "wallpaper.jpg")
            self.brain.inf.node?.geometry?.firstMaterial?.diffuse.wrapS = .repeat
            self.brain.inf.node?.geometry?.firstMaterial?.diffuse.wrapT = .repeat
            self.brain.inf.node?.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(3.6, 3.6, 0)
            self.brain.inf.node?.geometry?.firstMaterial?.transparency = 1
        }
    }
}
