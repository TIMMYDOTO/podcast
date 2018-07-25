//
//  PlayerView.swift
//  Podcasts
//
//  Created by Boris Esanu on 6/28/18.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit
import CoreMedia
class PlayerView: UIView {
var playerDetailsView = PlayerDetailsView()
    var uiview :UIView?
    @IBOutlet var favouriteBtn: UIButton!
    
    @IBOutlet var coverView: UIView!
    @IBOutlet var pauseBtn: UIButton!{
       
        didSet {
        
            pauseBtn.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
  
    @IBOutlet var arrowBtn: UIButton!{
        didSet {
            
            arrowBtn.addTarget(self, action: #selector(openFullPlayer), for: .touchUpInside)
        }
    }
    @objc func openFullPlayer(){

        
        self.uiview = Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)![0] as? PlayerDetailsView
        
        let window = UIApplication.shared.delegate?.window!
        
        window?.addSubview(self.uiview!)
        let maximize =  MainTabBarController()
            maximize.maximizePlayerDetails(episode: PlayerService.sharedIntance.episode, playlistEpisodes: PlayerService.sharedIntance.episodes)
        
    }
    @objc func handlePlayPause(){
      
        if PlayerService.sharedIntance.player.timeControlStatus == .paused {
            PlayerService.sharedIntance.player.play()
            pauseBtn.setImage(#imageLiteral(resourceName: "PauseWhite"), for: .normal)
           
        } else {
            PlayerService.sharedIntance.player.pause()
            pauseBtn.setImage(#imageLiteral(resourceName: "play-1"), for: .normal)
          
          
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
