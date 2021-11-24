//
//  PadelARViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka Tanaka on 2021/11/24.
//

import UIKit
import RealityKit

class PadelARViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! PadelAR.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
    }
}

