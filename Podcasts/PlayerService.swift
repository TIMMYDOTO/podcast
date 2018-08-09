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
class PlayerService: NSObject {
     static let sharedIntance = PlayerService()
    var commandCenter = MPRemoteCommandCenter.shared()
    
    
    let blackView = UIView()
    let activityView = UIActivityIndicatorView()
   
    var playerView:PlayerView?
    var playerItem: AVPlayerItem!
    var fileUrl:String?

    var episode: Episode?
    var episodes = [Episode]()
    var previousEpisodeTitle: String?
    var sender:UIButtonWitName?
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    var playerDetailsView = PlayerDetailsView2.initFromNib()
    
    
    override init(){
        super.init()
        playerView = UINib(nibName: "PlayerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? PlayerView
        playerView?.frame = CGRect(x: 0, y: UIScreen.main.bounds.height-47, width: UIScreen.main.bounds.width, height: 47)
        playerView?.transform = CGAffineTransform(scaleX: Constants.scale, y: Constants.scale)
        
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(handlePreviousTrack))
       setupCommandCenter()
    }

    
    func play(episode: Episode,  shouldSave: Bool, sender: UIButtonWitName?) {
        self.playerView?.coverView.isHidden = true
        self.playerDetailsView.observePlayerCurrentTime()
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
          
       
         
            if fileUrl != nil {
                self.playerItem = AVPlayerItem(url: URL(fileURLWithPath: self.fileUrl!))
                self.player.replaceCurrentItem(with: playerItem)
        
                self.player.play()
                fileUrl = nil
            }
                
            else{
                if previousEpisodeTitle == episode.title  {
                    self.player.play()
                    self.playerDetailsView.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                }
                else{
                    self.playerItem = AVPlayerItem(url: URL(string: episode.streamUrl )!)
                    self.player.replaceCurrentItem(with: playerItem)
                    self.player.play()
                    self.playerDetailsView.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                }
                
            }
            setupNowPlayingInfo()
            observeBoundaryTime()
            previousEpisodeTitle = episode.title
            playerView?.pauseBtn.setImage(#imageLiteral(resourceName: "PauseWhite"), for: .normal)
//            sender?.setBackgroundImage(#imageLiteral(resourceName: "Pause button"), for: .normal)
            playerView?.sender = sender
           
            playerView?.favouriteBtn.sd_setImage(with: URL(string: episode.imageUrl!), for: .normal )
        } catch {
            print(error)
        }
        
    }
   

    
    

    @objc  func handleNextTrack() {
        if episodes.count == 0 {
            return
        }
        let currrentEpisodeIndex = episodes.index { (ep) -> Bool in
            return episode?.title == ep.title && self.episode?.author == ep.author
        }
        guard let index = currrentEpisodeIndex else { return }
        let nextEpisode: Episode
        if index == episodes.count - 1 {
            nextEpisode = episodes[0]
        } else {
            nextEpisode = episodes[index + 1]
        }
        self.episode = nextEpisode
            setupNowPlayingInfo()
    }
    
    
    
    @objc  func handlePreviousTrack() {
        if episodes.isEmpty {
            return
        }
        let currentEpisodeIndex = episodes.index { (ep) -> Bool in
            return self.episode?.title == ep.title && self.episode?.author == ep.author
        }
        guard let index = currentEpisodeIndex else { return }
        let prevEpisode: Episode
        if index == 0 {
            let count = episodes.count
            prevEpisode = episodes[count - 1]
        } else {
            prevEpisode = episodes[index - 1]
        }
        self.episode = prevEpisode
        setupNowPlayingInfo()
    }
    
    fileprivate func  setupNowPlayingInfo() {
        
          var nowPlayingInfo = [String : Any]()
        let imageView = UIImageView()
        
        imageView.sd_setImage(with: URL(string: ((episode?.imageUrl)!)) ) { (image, _, _, _) in
            guard let image = image else { return }
            
            let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (_) -> UIImage in
                return image
            })
                nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
       let elapsedTime = CMTimeGetSeconds(player.currentTime())
        nowPlayingInfo[MPMediaItemPropertyTitle] = self.episode?.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = self.episode?.author
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            playerItem = AVPlayerItem(url: URL(string: (episode?.streamUrl)! )!)
            player.replaceCurrentItem(with: playerItem)
        self.player.play()
    }
    
    
     func setupElapsedTime(playbackRate: Float) {
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
    }
     func observeBoundaryTime() {
        let time = CMTimeMake(1, 3)
        let times = [NSValue(time: time)]
       
        self.player.addBoundaryTimeObserver(forTimes: times, queue: .main) {
            self.setupLockScreenDuration()
            print("Episode started playing")
            
           
        }
    }
    
     func setupLockScreenDuration() {
        guard let duration = self.player.currentItem?.duration else { return }
        let durationSeconds = CMTimeGetSeconds(duration)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationSeconds
    }
    
     func setupCommandCenter() {
  
   
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
    
        commandCenter.playCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.player.play()
               PlayerService.sharedIntance.playerDetailsView.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            PlayerService.sharedIntance.playerView?.pauseBtn.setImage(#imageLiteral(resourceName: "PauseWhite"), for: .normal)
         self?.setupElapsedTime(playbackRate: 1)
            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.player.pause()
            PlayerService.sharedIntance.playerDetailsView.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            PlayerService.sharedIntance.playerView?.pauseBtn.setImage(#imageLiteral(resourceName: "play-1"), for: .normal)
            self?.setupElapsedTime(playbackRate: 0)
            PlayerService.sharedIntance.saveInProgress()
            return .success
        }
    }
    
    
    func saveInProgress() {
        let inProgressEpisodes =  UserDefaults.standard.inProgressEpisodes()

        let currentTime = player.currentTime().seconds
        guard var currentEpisode = episode else { return }
       

        currentEpisode.currentTime = currentTime
        if inProgressEpisodes.contains(where: { $0.title == currentEpisode.title }){
            print("contains")
            print(currentEpisode.title)
            UserDefaults.standard.deleteEpisodeInProgress(finishEpisode: currentEpisode)
         
        }
            UserDefaults.standard.inProgressEpisode(episode: currentEpisode)

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
