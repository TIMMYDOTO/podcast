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
   
        let window = UIApplication.shared.keyWindow!
        window.addSubview(PlayerService.sharedIntance.playerView!)
        
        
 
    }

 
}
