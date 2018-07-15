//
//  PlayerView.swift
//  Podcasts
//
//  Created by Artyom Schiopu on 6/28/18.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit
import CoreMedia
class PlayerView: UIView {
    
    @IBOutlet var favouriteBtn: UIButton!

    @IBOutlet var pauseBtn: UIButton!{
        didSet {
        
            pauseBtn.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
  
    @IBOutlet var arrowBtn: UIButton!
        
    @objc func handlePlayPause(){
        if PlayerService.sharedIntance.player.timeControlStatus == .paused {
            PlayerService.sharedIntance.player.play()
            pauseBtn.setImage(#imageLiteral(resourceName: "PauseWhite"), for: .normal)
           
        } else {
            PlayerService.sharedIntance.player.pause()
            pauseBtn.setImage(#imageLiteral(resourceName: "play-button-2"), for: .normal)
          
          
        }
    }
    
    @IBAction func handleRewind(_ sender: UIButton) {
        seekToCurrentTime(delta: -15)
    }
    
    @IBAction func handleFastForward(_ sender: UIButton) {
        seekToCurrentTime(delta: 15)
    }
    
    fileprivate func seekToCurrentTime(delta: Int64) {
        let fifteenSeconds = CMTimeMake(delta, 1)
        let seekTime = CMTimeAdd(PlayerService.sharedIntance.player.currentTime(), fifteenSeconds)
        PlayerService.sharedIntance.player.seek(to: seekTime)
    }
}
