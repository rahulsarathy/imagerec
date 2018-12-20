//
//  ViewController.swift
//  imagerec
//
//  Created by Rahul Sarathy on 12/16/18.
//  Copyright © 2018 Rahul Sarathy. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".serialSceneKitQueue")
    
    var session: ARSession {
        return sceneView.session
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
        // Set the view's delegate
        sceneView.delegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Load reference images
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing resources")
        }
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.detectionImages = referenceImages

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let imageAnchor = anchor as? ARImageAnchor else {
            return
        }
        
        let referenceImage = imageAnchor.referenceImage
       // updateQueue.async {

            let plane = SCNPlane(width: referenceImage.physicalSize.width, height: referenceImage.physicalSize.height)
            let planeNode = SCNNode(geometry: plane)
            planeNode.opacity = 0.25
            
            planeNode.eulerAngles.x = -.pi / 2
            
            planeNode.runAction(self.imageHighlightAction)
        
     let star = SCNScene(named: "art.scnassets/star.dae")!
        let starNode = star.rootNode.childNode(withName: "Cylinder", recursively: true)
        starNode?.scale = SCNVector3(x: 0.02, y: 0.02, z: 0.02)
        starNode?.position = SCNVector3(x:0.0, y: 0.0, z: 0.0)
       // starNode?.eulerAngles.z = -.pi/6

        let name = imageAnchor.name
        let text = SCNText(string: name, extrusionDepth: 1)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        text.materials = [material]
        let textNode = SCNNode()
        textNode.geometry = text
        textNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        textNode.eulerAngles.x = -.pi/2
        
        node.addChildNode(starNode!)
        node.addChildNode(planeNode)
        node.addChildNode(textNode)
        print(textNode.position)
        print(node.position)
        //node.addChildNode(cubeNode)
     //   }
        
        
        //resetTracking()
    }
    
    func resetTracking() {
        
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    
    var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
           // .fadeOut(duration: 0.5),
         //   .removeFromParentNode()
            ])
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
}
