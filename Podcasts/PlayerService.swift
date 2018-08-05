//
//  PlayerService.swift
//  Podcasts
//
//  Created by Boris Esanu on 6/28/18.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer
class PlayerService {
    let blackView = UIView()
    let activityView = UIActivityIndicatorView()
    static let sharedIntance = PlayerService()
    var playerView:PlayerView?
    var playerItem: AVPlayerItem!
   var playerDetailsView = PlayerDetailsView2.initFromNib()

    var episode: Episode?
    var episodes = [Episode]()
    
    var sender:UIButtonWitName?
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
     init(){
        
        playerView = UINib(nibName: "PlayerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? PlayerView
        playerView?.frame = CGRect(x: 0, y: UIScreen.main.bounds.height-47, width: UIScreen.main.bounds.width, height: 47)
        playerView?.transform = CGAffineTransform(scaleX: Constants.scale, y: Constants.scale)
    }

    
    func play(episode: Episode,  shouldSave: Bool, sender: UIButtonWitName?) {
        self.playerView?.coverView.isHidden = true
      PlayerService.sharedIntance.playerDetailsView.observePlayerCurrentTime()
        if episode.streamUrl.isEmpty {
            return
        }
        self.episode = episode
        if shouldSave {
            PlayerService.sharedIntance.saveInProgress()
        }
     
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
             try AVAudioSession.sharedInstance().setActive(true)
            UIApplication.shared.beginReceivingRemoteControlEvents()
            setupCommandCenter()
            playerItem = AVPlayerItem(url: URL(string: episode.streamUrl )!)
            player.replaceCurrentItem(with: playerItem)
            player.play()
            playerView?.pauseBtn.setImage(#imageLiteral(resourceName: "PauseWhite"), for: .normal)
            sender?.setBackgroundImage(#imageLiteral(resourceName: "Pause button"), for: .normal)
            playerView?.sender = sender
           
            playerView?.favouriteBtn.sd_setImage(with: URL(string: episode.imageUrl!), for: .normal )
        } catch {
            print(error)
        }
        
        
       
        
    }
    
    private func setupCommandCenter() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: "PodCasts"]
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyArtist: episode?.title ?? "404"]
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.player.play()
               PlayerService.sharedIntance.playerDetailsView.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            PlayerService.sharedIntance.playerView?.pauseBtn.setImage(#imageLiteral(resourceName: "PauseWhite"), for: .normal)
         
            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.player.pause()
             PlayerService.sharedIntance.playerDetailsView.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            PlayerService.sharedIntance.playerView?.pauseBtn.setImage(#imageLiteral(resourceName: "play-1"), for: .normal)
            return .success
        }
    }
    
    
    func saveInProgress() {
     var inProgressEpisode =  UserDefaults.standard.inProgressEpisodes()

        let currentTime = player.currentTime().seconds
        guard let currentEpisode = episode else { return }
       
            if let row = inProgressEpisode.index(where: {$0.title == episode?.title}) {
                inProgressEpisode[row] = currentEpisode
        
            }
            else{
                UserDefaults.standard.inProgressEpisode(episode: currentEpisode)
        }
            
            
        UserDefaults.standard.inProgressEpisodeTime(time: currentTime)
    }
//    func showActivity(show: Bool){
//        let win:UIWindow = ((UIApplication.shared.delegate?.window)!)!
//        blackView.frame =  CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
//        blackView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
//        activityView.activityIndicatorViewStyle = .gray
//        
//        activityView.center = blackView.center
//        activityView.startAnimating()
//        if show == false {
//            activityView.removeFromSuperview()
//            blackView.removeFromSuperview()
//            return
//        }
//        blackView.addSubview(activityView)
//        
//        win.addSubview(blackView)
//    }
}
