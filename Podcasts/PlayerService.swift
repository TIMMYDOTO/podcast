//
//  PlayerService.swift
//  Podcasts
//
//  Created by Artyom Schiopu on 6/28/18.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer
class PlayerService {
    var playerView:PlayerView?
    var playerItem: AVPlayerItem!
    let player = AVPlayer()
    static let sharedIntance = PlayerService ()
    var episode: Episode?
    var episodes = [Episode]()

     init(){
        
        playerView = UINib(nibName: "PlayerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? PlayerView
        playerView?.frame = CGRect(x: 0, y: UIScreen.main.bounds.height-47, width: UIScreen.main.bounds.width, height: 47)

    }

    
    func play(stringURL: String) {
        if stringURL.isEmpty {
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            playerItem = AVPlayerItem(url: URL(string: stringURL )!)
            player.replaceCurrentItem(with: playerItem)
            player.play()
            playerView?.pauseBtn.setImage(#imageLiteral(resourceName: "PauseWhite"), for: .normal)
        } catch {
            print(error)
        }
        
        
       
        
    }
 
}
