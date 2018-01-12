//
//  CoreML.swift
//  Bob
//
//  Created by lvwei on 21/12/2017.
//  Copyright © 2017 Juran. All rights reserved.
//
import SceneKit
import ARKit
import Vision

enum Category {
    case Window, Light, None
}

class nFinding : Finding {
    var cate = Category.None
}

class Nose {
    
    var sceneView: ARSCNView!
    var consoleView: UILabel!
    var inDetection = false
    var finding: nFinding!
    
    var visionRequests = [VNRequest]()
    let dispatchQueueML = DispatchQueue(label: "com.dispatchqueue.ml") // A Serial Queue
    
    init (scene: ARSCNView, console: UILabel) {
        
        sceneView = scene
        consoleView = console
        finding = nFinding()
        
        // Set up Vision Model
        guard let selectedModel = try? VNCoreMLModel(for:  Inceptionv3().model) else {
            // (Optional) This can be replaced with other models on https://developer.apple.com/machine-learning/
            fatalError("Could not load model. Ensure model has been drag and dropped (copied) to XCode Project from https://developer.apple.com/machine-learning/ . Also ensure the model is part of a target (see: https://stackoverflow.com/questions/45884085/model-is-not-part-of-any-target-add-the-model-to-a-target-to-enable-generation ")
        }

        // Set up Vision-CoreML Request
        let classificationRequest = VNCoreMLRequest(model: selectedModel, completionHandler: classificationCompleteHandler)
        // Crop from centre of images and scale to appropriate size.
        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
        visionRequests = [classificationRequest]  
    }
    
    func smell() {
        dispatchQueueML.async {
            if self.inDetection {
                self.predict()
            }
        }
    }
    
    func predict() {
        
        ///////////////////////////
        // Get Camera Image as RGB
        let pixbuff : CVPixelBuffer? = (sceneView.session.currentFrame?.capturedImage)
        if pixbuff == nil {
            return
        }
        
        let ciImage = CIImage(cvPixelBuffer: pixbuff!)
        // Note: Not entirely sure if the ciImage is being interpreted as RGB, but for now it works with the Inception model.
        // Note2: Also uncertain if the pixelBuffer should be rotated before handing off to Vision (VNImageRequestHandler) - regardless, for now, it still works well with the Inception model.
        
        ///////////////////////////
        // Prepare CoreML/Vision Request
        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        // let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage!, orientation: myOrientation, options: [:]) // Alternatively; we can convert the above to an RGB CGImage and use that. Also UIInterfaceOrientation can inform orientation values.
        
        ///////////////////////////
        // Run Image Request
        do {
            try imageRequestHandler.perform(self.visionRequests)
        } catch {
            print(error)
        }
        
    }
    
    func classificationCompleteHandler(request: VNRequest, error: Error?) {
        // Catch Errors
        if error != nil {
            print("Error: " + (error?.localizedDescription)!)
            return
        }
        guard let observations = request.results else {
            print("No results")
            return
        }
        
        // Get Classifications
        let classifications = observations[0...4] // top 2 results
            .flatMap({ $0 as? VNClassificationObservation })
            .map({ "\($0.identifier) \(String(format:"- %.2f", $0.confidence))" })
            .joined(separator: "\n")
        
        finding.cate = .None
        if classifications.contains("window") {
            finding.cate = .Window
        }
        if classifications.contains("light") {
            finding.cate = .Light
        }
          
        DispatchQueue.main.async {
            // Print Classifications
            print(classifications)
            print("--")
            
            self.consoleView.text = classifications
        }
    }
}
