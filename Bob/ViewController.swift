//
//  ViewController.swift
//

import UIKit
import ARKit
import SceneKit
import LiquidFloatingActionButton

class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var indicator: UILabel!
    
    var cells: [LiquidFloatingCell] = []
    var floatingActionButton: LiquidFloatingActionButton!
    
    var showDebugVisuals: Bool = false
    
    var bModeler : Modeler!
    var pModeler : Modeler!
    var modeler  : Modeler!
    
    var chair   : SCNReferenceNode!
    var cup     : SCNReferenceNode!
    var select  : SCNReferenceNode!
    
    var nose: Nose!
    var eye : Eye!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UISetup()
        ARSetup()
        MLSetup()
        GesturesSetup()

        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
}
