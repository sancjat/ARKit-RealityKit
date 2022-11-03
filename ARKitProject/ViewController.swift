//
//  ViewController.swift
//  ARKitProject
//
//  Created by Santosh Kumari on 23/10/22.
//

import UIKit
import RealityKit
import ARKit
/* To play animation
import Combine */

class ViewController: UIViewController  {
    
    @IBOutlet weak var aRView: ARView!
    var type : Types?
    /* To play animation
    var cancellables: [AnyCancellable] = [] */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if type == .FaceTracking {
            // Load the "Scene" scene from the "MyCrown" Reality File
            let sceneAnchor = try! MyCrown.loadScene()
            // Add the scene anchor to the scene
            aRView.scene.anchors.append(sceneAnchor)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        restartSession()
    }
    
    override func didReceiveMemoryWarning() {
        print("Memory Warning")
        flushFromMemory()
        restartSession()
    }
    
    deinit {
        flushFromMemory()
    }
    
    func restartSession() {
        aRView.session.delegate = self
        setUpObject()
    }

    func flushFromMemory() {
        print("Cleaning")
        aRView.scene.anchors.removeAll()
        aRView.session.delegate = nil
    }
    
    func setUpObject() {
        aRView.automaticallyConfigureSession = false
        if type == .FaceTracking {
            let configuration = ARFaceTrackingConfiguration()
            aRView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        } else if type == .RealWorldTracking {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = [.horizontal, .vertical]
            configuration.environmentTexturing = .automatic
            aRView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            addTapGesture()
        }
    }
    
    func addTapGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        aRView.addGestureRecognizer(gesture)
    }
    
    @objc func onTap(recognizer : UITapGestureRecognizer) {
        let location = recognizer.location(in: aRView)
        let result = aRView.raycast(from: location, allowing: .estimatedPlane, alignment: .any)
        if let first = result.first {
            let anchor = ARAnchor.init(name: "toy_drummer.usdz", transform: first.worldTransform)
            aRView.session.add(anchor: anchor)
        } else {
            print("object not found")
        }
    }
}


extension ViewController : ARSessionDelegate {
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let obj = anchor.name , obj == "toy_drummer.usdz" {
                locateAnchorObjectOnMove(entityName: obj, object: anchor)
            }
        }
    }
    
    func locateAnchorObjectOnMove(entityName : String, object : ARAnchor) {
        let entity = try! ModelEntity.loadModel(named: entityName)
        entity.generateCollisionShapes(recursive: true)
        aRView.installGestures([.rotation, .translation], for: entity)
        
        let anchorEntity = AnchorEntity(anchor: object)
        anchorEntity.addChild(entity)
        aRView.scene.addAnchor(anchorEntity)
        
       /*if #available(iOS 15.0, *) {
            aRView.scene.subscribe(to: SceneEvents.AnchoredStateChanged.self) { [weak self] (event) in
                if anchorEntity.isActive {
                    for entity in anchorEntity.children {
                        for animation in entity.availableAnimations {
                            entity.playAnimation(animation.repeat())
                        }
                    }
                }
            }.store(in: &cancellables)
        } else {
            // Fallback on earlier versions
        }*/
    }
}
