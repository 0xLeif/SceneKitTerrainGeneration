//
//  ViewController.swift
//  scenekitterraingeneration
//
//  Created by Zach Eriksen on 12/12/18.
//  Copyright © 2018 ol. All rights reserved.
//
import SceneKit
import QuartzCore
import GameplayKit

class ViewController: NSViewController {
    let verticesPerSide = 100
    var squaresPerSide: Int!
    var totalSquares: Int!
    var totalTriangles: Int!
    var triangleIndices: [UInt16]!
    
    var normals: [SCNVector3] = []
    var vertices: [SCNVector3] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        squaresPerSide = verticesPerSide - 1
        totalSquares = squaresPerSide * squaresPerSide
        totalTriangles = totalSquares * 2
        triangleIndices = Array(repeating: UInt16(0), count: totalTriangles * 3)
        
        // create a new scene
        let scene = SCNScene()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 15)
        
        // create and add lights to the scene
        let lightNode0 = SCNNode()
        lightNode0.light = SCNLight()
        lightNode0.light!.type = .omni
        lightNode0.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode0)
        
        let lightNode1 = SCNNode()
        lightNode1.light = SCNLight()
        lightNode1.light!.type = .omni
        lightNode1.position = SCNVector3(5, -10, 0)
        scene.rootNode.addChildNode(lightNode1)
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = NSColor.black
        
        //        addCustomGeometry()
        addCustomTerrain()
    }
    
    private func drawTriangle(atIndex i: Int) {
        let index = i / 2
        let x = index % (verticesPerSide)
        let y = index / (verticesPerSide)
        if y >= verticesPerSide - 1 || x >= verticesPerSide - 1 {
            return
        }
        
        let topRightIndex = ((y + 1) * verticesPerSide) + x + 1
        let topLeftIndex = topRightIndex - 1
        let bottomLeftIndex = topRightIndex - verticesPerSide - 1
        let bottomRightIndex = bottomLeftIndex + 1
        
        let indice = index * 6
        triangleIndices[indice] = UInt16(topRightIndex)
        triangleIndices[indice+1] = UInt16(topLeftIndex)
        triangleIndices[indice+2] = UInt16(bottomLeftIndex)
        
        
        triangleIndices[indice+3] = UInt16(topRightIndex)
        triangleIndices[indice+4] = UInt16(bottomLeftIndex)
        triangleIndices[indice+5] = UInt16(bottomRightIndex)
    }
    
    func addCustomTerrain() {
        let p = GKPerlinNoiseSource(frequency: 10, octaveCount: 7, persistence: 0.2, lacunarity: 0.25, seed: 12345)
        let pm = GKNoise(p)
        let pmm = GKNoiseMap(pm)
        var ndx = 0
        for x in 0 ..< verticesPerSide {
            for z in 0 ..< verticesPerSide {
                vertices.append(SCNVector3(x: CGFloat(x - verticesPerSide / 2),
                                           y: CGFloat(pmm.value(at: vector_int2(x: Int32(x), y: Int32(z)))) * 5,
                                           z: CGFloat(z - verticesPerSide / 2)))
                normals.append(SCNVector3(x: 0,
                                          y: 0,
                                          z: 1))
                ndx += 1
            }
        }
        
        for i in stride(from: 0, to: totalTriangles - 2, by: 2) {
            drawTriangle(atIndex: i)
        }
        let source = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(indices: triangleIndices, primitiveType: .triangles)
        
        
        let geometry = SCNGeometry(sources: [source], elements: [element])
        
        geometry.firstMaterial?.diffuse.contents = NSColor.white
        
        let node = SCNNode(geometry: geometry)
        
        
        let scnView = self.view as! SCNView
        
        scnView.scene?.rootNode.addChildNode(node)
        
    }
}

