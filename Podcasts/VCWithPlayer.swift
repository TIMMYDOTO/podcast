//
//  VCWithPlayer.swift
//  Podcasts
//
//  Created by Boris Esanu on 6/28/18.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit

class VCWithPlayer: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
           self.view.transform = CGAffineTransform(scaleX: Constants.scale, y: Constants.scale)
        let window = UIApplication.shared.keyWindow!
        window.addSubview(PlayerService.sharedIntance.playerView!)
    
 
    }

 
 
}
extension UIActivityIndicatorView {
    
    convenience init(activityIndicatorStyle: UIActivityIndicatorViewStyle, color: UIColor, placeInTheCenterOf parentView: UIView) {
        self.init(activityIndicatorStyle: activityIndicatorStyle)
        center = parentView.center
        self.color = color
        parentView.addSubview(self)
    }
}
