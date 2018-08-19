//
//  MiniMap.swift
//  BVGHackaton2018
//
//  Created by Daniel Montano on 18.08.18.
//  Copyright © 2018 Daniel Montano. All rights reserved.
//

import Foundation
import UIKit

class MiniMap: UIView {
    
    @IBOutlet weak var c1: UIView!
    @IBOutlet weak var c2: UIView!
    @IBOutlet weak var c3: UIView!
    @IBOutlet weak var c4: UIView!
    @IBOutlet weak var c5: UIView!
    @IBOutlet weak var c6: UIView!
    @IBOutlet weak var c7: UIView!
    @IBOutlet weak var c8: UIView!
    @IBOutlet weak var c9: UIView!
    @IBOutlet weak var c10: UIView!
    
    var grid: [[UIView]]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 10
        
    }
    
    func setup(){
        
        grid = [[c1,c2],[c3,c4],[c5,c6],[c7,c8],[c9, c10]]
        
        for n in 0...grid.count - 1 {
            let view1 = grid[n][0]
            let view2 = grid[n][1]
            
            view1.layer.borderColor = UIColor.init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
            view1.layer.borderWidth = 0.5
            
            view2.layer.borderColor = UIColor.init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
            view2.layer.borderWidth = 0.5
        }
    }
    
    func clearAll(){
        for n in 0...grid.count - 1 {
            clear(index: n)
        }
    }
    
    func clear(index: Int){
        let view1 = grid[index][0]
        let view2 = grid[index][1]

        view1.backgroundColor = UIColor.clear
        view2.backgroundColor = UIColor.clear
    }
    
    func drawCurrentPosition(x: Int, y: Int){
        
        let view = grid[y][x]
        
        view.backgroundColor = UIColor.red
        view.layer.borderColor = UIColor.init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        view.layer.borderWidth = 0.5
    }
    
    func redraw(squares:[(Int,Int)]){
        
        clearAll()
        
        for square in squares {
            drawCurrentPosition(x: square.0, y: square.1)
        }
        
    }

    
}
