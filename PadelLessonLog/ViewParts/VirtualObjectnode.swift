//
//  VirtualObjectnode.swift
//  Padel3D
//
//  Created by Yoshitaka on 2020/12/14.
//

import SceneKit

class VirtualObjectNode: SCNNode {

    enum VirtualObjectType {
        case padel
        case ship
    }
    
    init(type: VirtualObjectType = .padel) {
        super.init()
        
        var scale = 1.0
        switch type {
        case .padel:
            loadScn(name: "padel", inDirectory: "art.scnassets/padel")
        case .ship:
            loadScn(name: "ship", inDirectory: "art.scnassets/ship")
            scale = 0.005
        }
        self.scale = SCNVector3(scale, scale, scale)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func react() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.3
        SCNTransaction.completionBlock = {
            SCNTransaction.animationDuration = 0.15
            self.opacity = 1.0
        }
        self.opacity = 0.5
        SCNTransaction.commit()
    }
}
