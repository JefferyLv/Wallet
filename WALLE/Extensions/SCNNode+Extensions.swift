//
//  SCNNode+Extensions.swift
//

import SceneKit

extension SCNNode {
    
    func setUniformScale(_ scale: Float) {
        self.scale = SCNVector3Make(scale, scale, scale)
    }
    
    func renderOnTop() {
        self.renderingOrder = 2
        if let geom = self.geometry {
            for material in geom.materials {
                material.readsFromDepthBuffer = false
            }
        }
        for child in self.childNodes {
            child.renderOnTop()
        }
    }
}

extension SCNBoundingVolume {
	// Returns a point at a specified normalized location within the bounds of the volume, where 0 is min and 1 is max.
	func pointInBounds(at normalizedLocation: SCNVector3) -> SCNVector3 {
		let boundsSize = boundingBox.max - boundingBox.min
		let locationInPoints = boundsSize * normalizedLocation
		return locationInPoints + boundingBox.min
	}
}

extension SCNMaterial {
    
    static func material(withDiffuse diffuse: Any?, respondsToLighting: Bool = true) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = diffuse
        material.isDoubleSided = true
        if respondsToLighting {
            material.locksAmbientWithDiffuse = true
        } else {
            material.ambient.contents = UIColor.black
            material.lightingModel = .constant
            material.emission.contents = diffuse
        }
        return material
    }
}
