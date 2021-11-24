//
//  BallLineGeometry.swift
//  Padel3D
//
//  Created by Yoshitaka on 2020/12/17.
//

import SceneKit

open class BallLineGeometryNode: SCNNode {
    
    var vertices: [SCNVector3] = []
    private var indices: [Int32] = []
    private let lineWidth: Float
    private let color: UIColor

    public init(color: UIColor, lineWidth: Float) {
        self.color = color
        self.lineWidth = lineWidth
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func addVertice(_ vertice: SCNVector3) {
        vertices.append(SCNVector3Make(vertice.x, vertice.y - lineWidth, vertice.z))
        vertices.append(SCNVector3Make(vertice.x, vertice.y + lineWidth, vertice.z))
        let count = vertices.count
        indices.append(Int32(count-2))
        indices.append(Int32(count-1))
        
        updateGeometryIfNeeded()
    }
    
    private func updateGeometryIfNeeded() {
        guard vertices.count >= 3 else {
//            print("not enough vertices")
            return
        }
        
        let source = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangleStrip)
        geometry = SCNGeometry(sources: [source], elements: [element])
        if let material = geometry?.firstMaterial {
            material.diffuse.contents = color
            material.isDoubleSided = true
        }
    }
    
    public func reset() {
        vertices.removeAll()
        indices.removeAll()
        geometry = nil
    }
}


