//
//  PlayerService.swift
//  Podcasts
//
//  Created by Artyom Schiopu on 6/28/18.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit

class PlayerService {
    var playerView:PlayerView?

    static let sharedIntance = PlayerService ()
    
     init(){
        
        playerView = UINib(nibName: "PlayerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? PlayerView
        playerView?.frame = CGRect(x: 0, y: UIScreen.main.bounds.height-47, width: UIScreen.main.bounds.width, height: 47)
        
    }

    

    
   
    
}
