//
//  VCWithPlayer.swift
//  Podcasts
//
//  Created by Artyom Schiopu on 6/28/18.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit

class VCWithPlayer: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(PlayerService.sharedIntance.playerView!)
      
        
 
    }

 
}
