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

 
    @IBOutlet var favouriteBtn: UIButton!
    var sender:UIButtonWitName?
    var previousSender = UIButtonWitName()
    @IBOutlet var coverView: UIView!
    var homeVC:VCWithPlayer!
    
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
           PlayerService.sharedIntance.playerDetailsView.episode = PlayerService.sharedIntance.episode
 PlayerService.sharedIntance.playerDetailsView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      PlayerService.sharedIntance.playerDetailsView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height+20, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseIn, animations:{ PlayerService.sharedIntance.playerDetailsView.frame = CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)}) { (hasFinished) in
            
        }
        self.superview?.addSubview(PlayerService.sharedIntance.playerDetailsView)
        self.superview?.bringSubview(toFront: PlayerService.sharedIntance.playerDetailsView)
       
    }
    @objc func handlePlayPause(notSave: Bool, sender : UIButtonWitName?){

        if PlayerService.sharedIntance.player.timeControlStatus == .paused {
            PlayerService.sharedIntance.player.play()
            if self.sender != nil{
                previousSender.setBackgroundImage(#imageLiteral(resourceName: "Pause button"), for: .normal)
                previousSender = sender!
                self.sender?.setBackgroundImage(#imageLiteral(resourceName: "Pause button"), for: .normal)
            }
            pauseBtn.setImage(#imageLiteral(resourceName: "PauseWhite"), for: .normal)
            PlayerService.sharedIntance.playerDetailsView.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
           
        } else {
            if !notSave{
            PlayerService.sharedIntance.saveInProgress()
            }
            if self.sender != nil{
                self.sender?.setBackgroundImage(#imageLiteral(resourceName: "play-button-2"), for: .normal)
            }
    
            PlayerService.sharedIntance.player.pause()
            pauseBtn.setImage(#imageLiteral(resourceName: "play-1"), for: .normal)
            PlayerService.sharedIntance.playerDetailsView.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
          homeVC.viewWillAppear(false)
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

