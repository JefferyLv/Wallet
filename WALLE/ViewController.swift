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
    @IBOutlet var message: UIButton!
    @IBOutlet var console: UILabel!
    @IBOutlet var messageView: UIVisualEffectView!
    
    var cells: [LiquidFloatingCell] = []
    var floatingActionButton: LiquidFloatingActionButton!
    
    var showDebugVisuals: Bool = false
    
    var bModeler : Modeler!
    var pModeler : Modeler!
    var modeler  : Modeler!

    var select  : SCNReferenceNode!
    
    var brain: Brain!
    
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
