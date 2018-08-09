//
//  UIButtonWitName.swift
//  Podcasts
//
//  Created by Boris Esanu on 7/27/18.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit

class UIButtonWitName: UIButton {

    var nameForButton = String()
    var episode:Episode!
   var seekTime: Double?
    var vc = TableViewWithName()
     var addedTouchArea = CGFloat(40)


    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        let newBound = CGRect(
            x: self.bounds.origin.x - addedTouchArea,
            y: self.bounds.origin.y - addedTouchArea,
            width: self.bounds.width + 2 * addedTouchArea,
            height: self.bounds.width + 2 * addedTouchArea
        )
        return newBound.contains(point)
    }
    
  
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    //    override init(){
//        super.init()
//        self.addedTouchArea = 50
//    }
}
