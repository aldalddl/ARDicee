//
//  ViewController.swift
//  ARDicee
//
//  Created by MinJi Kang on 2022/11/24.
//


import UIKit
import SceneKit
import ARKit


class ViewController: UIViewController, ARSCNViewDelegate {

    var diceColor: UIColor = UIColor.black
    
    var diceArray = [SCNNode]()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPopupButton()
        // Effects when plane detected
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
//        sceneView.session.delegate = self
////        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
//        let sphere = SCNSphere(radius: 0.2)
//
//        let matarial = SCNMaterial()
//
////        matarial.diffuse.contents = UIColor.red
//        matarial.diffuse.contents = UIImage(named: "art.scnassets/2k_moon.jpg")
//
////        cube.materials = [matarial]
//        sphere.materials = [matarial]
//
//        let node = SCNNode()
//
//        node.position = SCNVector3(x: 0, y: 0.1, z: -0.5)
//
////        node.geometry = cube
//        node.geometry = sphere
//
//        sceneView.scene.rootNode.addChildNode(node)
                
        // highlight & shadow
        sceneView.autoenablesDefaultLighting = true
        

//        // Create a new scene
//        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
//
//        // Include child files of "Dice"
//        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
//            diceNode.position = SCNVector3(x: 0, y: 0, z: -0.1)
//
//            sceneView.scene.rootNode.addChildNode(diceNode)
//
//        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (ARWorldTrackingConfiguration.isSupported){
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
            
        // To place dice on the plane, detect plane
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
        
        } else {
            print("ARWorldTrackingConfiguration is not supported.")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // Detect touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            let touchLocation = touch.location(in: sceneView)
            
            // calculate z component, to clicked location be a position in 3D space
            // depending on the z component, dice is going to be rendered larger or smaller
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)

//            if !results.isEmpty {
//                print("touched the plane")
//            } else {
//                print("touched somewhere else")
//            }
            
            // same above
            if let hitResult = results.first {
                print(hitResult)
                
                // Create a new scene
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                                
                // Include child files of "Dice"
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                    
                    // where user touches on the screen
                    diceNode.position = SCNVector3(
                        x: hitResult.worldTransform.columns.3.x,
                        y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius, // add half of the dice in order to raise it "on" the plane, not "through" the plane
                        z: hitResult.worldTransform.columns.3.z
                    )

                    
//                    results[0].node.geometry?.materials.first?.emission.contents = UIColor.white
                    
                    diceArray.append(diceNode)
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    
                    diceNode.geometry?.firstMaterial?.emission.intensity = 0.5
                    diceNode.geometry?.firstMaterial?.emission.contents = diceColor
                    
                    roll(dice: diceNode)
        
                }
            }
        }
    }
    
    
    // to throw dices all at once
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    // When click the refresh button in navigation bar
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    // When shake the physical device
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    func roll(dice: SCNNode) {
        
        // animate when throw the dice
        
        // new random face when throw the dice
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2) // pi/2 == 90 degrees (1 pi radius = 180 degrees)
        // y axis doesn't need because dice won't change by y
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        dice.runAction(SCNAction.rotateBy(
            x: CGFloat(randomX * 5),
            y: 0,
            z: CGFloat(randomZ * 5),
            duration: 0.5)
        )
        
    }
    
    // Detect plane using ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if anchor is ARPlaneAnchor {
//            print("Plane detected")
            
            // change ARAnchor to ARPlaneAnchor
            let planAnchor = anchor as! ARPlaneAnchor
            
            let plane = SCNPlane(width: CGFloat(planAnchor.extent.x), height: CGFloat(planAnchor.extent.z))
            
            let planeNode = SCNNode()
            
            planeNode.position = SCNVector3(x: planAnchor.center.x, y: 0, z: planAnchor.center.z)
            
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            // Show grid image on plane detected
            let gridMatarial = SCNMaterial()
            
//            gridMatarial.diffuse.contents = UIImage(named: "art.scnassets/grid2.png")
            gridMatarial.diffuse.contents = UIImage(named: "grid2.png")

            plane.materials = [gridMatarial]
            
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
            
        } else {
            return
        }
        
    }
    
    @IBOutlet weak var popupButton: UIButton!
    
    // Popup Button choosing dice color
    func setPopupButton(){
        let optionClosure = {(action : UIAction) in
            
            if action.title == "Pink" {
                self.diceColor = .magenta
            } else if action.title == "Yellow" {
                self.diceColor = .yellow
            } else if action.title == "Green" {
                self.diceColor = .green
            } else if action.title == "Cyan" {
                self.diceColor = .cyan
            } else if action.title == "Purple" {
                self.diceColor = .blue
            } else if action.title == "Red(default)" {
                self.diceColor = .black
            }
            
        }

        popupButton.menu = UIMenu(children : [
            UIAction(title : "Red(default)", state : .on, handler: optionClosure),
            UIAction(title : "Pink", state : .on, handler: optionClosure),
            UIAction(title : "Yellow", state : .on, handler: optionClosure),
            UIAction(title : "Green", state : .on, handler: optionClosure),
            UIAction(title : "Cyan", state : .on, handler: optionClosure),
            UIAction(title : "Purple", state : .on, handler: optionClosure)
        ])
    
        popupButton.showsMenuAsPrimaryAction = true
        popupButton.changesSelectionAsPrimaryAction = true
        
    }

}
