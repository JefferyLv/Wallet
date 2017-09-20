//
//  ViewController.swift
//

import UIKit
import ARKit
import SceneKit

struct RenderingCategory: OptionSet {
    let rawValue: Int
    static let reflected = RenderingCategory(rawValue: 1 << 1)
    static let planes = RenderingCategory(rawValue: 1 << 2)
}

class ViewController: UIViewController, ARSCNViewDelegate, UIGestureRecognizerDelegate {
    
    var showDebugVisuals: Bool = false
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var indicator: UILabel!
    @IBOutlet var boxButton: UIButton!
    @IBOutlet var polyButton: UIButton!
  
    var bModeler : Modeler!
    var pModeler : Modeler!
    var modeler  : Modeler!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.antialiasingMode = .multisampling4X
        sceneView.autoenablesDefaultLighting = true

        bModeler = BoxModeler(scene: sceneView)
        bModeler.indicator = indicator
        bModeler.setup()
        
        pModeler = PolyModeler(scene: sceneView)
        pModeler.indicator = indicator
        pModeler.setup()
        
        modeler = bModeler
        bModeler.active()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.delegate = self
        sceneView.addGestureRecognizer(tapGesture)
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
    
    // MARK: - ARSCNViewDelegate
    
    // Highlight detected planes in the view with a surface so we can see what the hell we're doing
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return nil
        }
        
        let plane = SCNBox(width: CGFloat(planeAnchor.extent.x),
                           height: 0.0001,
                           length: CGFloat(planeAnchor.extent.z),
                           chamferRadius: 0)
        
        if let material = plane.firstMaterial {
            material.lightingModel = .constant
            material.diffuse.contents = UIColor.white
            material.transparency = 0.1
            material.writesToDepthBuffer = false
        }
        
        let node = SCNNode(geometry: plane)
        node.categoryBitMask = RenderingCategory.planes.rawValue
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, let plane = node.geometry as? SCNBox else {
            return
        }
        
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.length = CGFloat(planeAnchor.extent.z)
        
        // If this anchor is the one the box is positioned relative to, then update the box to match any corrections to the plane's observed position.
        if plane == modeler.currentAnchor {
            let oldPos = node.position
            let newPos = SCNVector3.positionFromTransform(planeAnchor.transform)
            let delta = newPos - oldPos
            modeler.model().position += delta
        }
        
        node.transform = SCNMatrix4(planeAnchor.transform)
        node.pivot = SCNMatrix4(translationByX: -planeAnchor.center.x, y: -planeAnchor.center.y, z: -planeAnchor.center.z)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.modeler.updateAtTime(pos: self.indicator.center)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    @objc dynamic func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        
        if !indicator.isHidden {
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.allowUserInteraction,.curveEaseOut], animations: {
                self.indicator.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            }) { (value) in
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.allowUserInteraction,.curveEaseIn], animations: {
                    self.indicator.transform = CGAffineTransform.identity
                }) { (value) in
                }
            }
        }
    }
    
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
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
