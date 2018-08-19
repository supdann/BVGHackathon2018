//
//  Arrow.swift
//  BVGHackaton2018
//
//  Created by Daniel Montano on 18.08.18.
//  Copyright © 2018 Daniel Montano. All rights reserved.
//

import Foundation
import ARKit

class Arrow: SCNNode {
    func loadModel(n: Int) {
        
        guard let virtualObjectScene = SCNScene(named: "Arrow\(n).scn") else { return }
        let wrapperNode = SCNNode()
        for child in virtualObjectScene.rootNode.childNodes {
            wrapperNode.addChildNode(child)
        }
        addChildNode(wrapperNode)
    }
}
