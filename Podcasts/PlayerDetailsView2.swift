//
//  PlayerDetailsView2.swift
//  Podcasts
//
//  Created by Artyom Schiopu on 7/31/18.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer


class PlayerDetailsView2: UIView, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var episodeImageView: UIImageView!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var volumeSlider: UISlider!

    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var currentTimeLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var episodeTitleLabel: UILabel!
    @IBOutlet var episodeDescriptionLabel: UILabel!
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet var playbackSpeedButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    var currentChapterArray = [Chapter]()


    var episode: Episode! {
        didSet{
            episodeTitleLabel.text = episode.title
            authorLabel.text = episode.author
            episodeDescriptionLabel.text = episode.description
            guard let url = URL(string: episode.imageUrl ?? "") else { return }
            episodeImageView.sd_setImage(with: url)
            episodeImageView.layer.cornerRadius = 8.0
//             guard let image = image else { return }
             var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
//            let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (_) -> UIImage in
//                return image
//            })
//            nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
               MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }
    static func initFromNib() -> PlayerDetailsView2 {
             
        return Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView2
        
    }
        override func awakeFromNib() {
         
            setupTableView()
            setupVolumeView()
            setupInterruptionObserver()
               self.transform = CGAffineTransform(scaleX: Constants.scale, y: Constants.scale)
             volumeSlider.setValue(AVAudioSession.sharedInstance().outputVolume, animated: true)
    }
    
    fileprivate func setupInterruptionObserver() {
 
        NotificationCenter.default.addObserver(self, selector: #selector(volumeChanged(notification:)),
                                               name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"),
                                               object: nil)
    }
    @objc func volumeChanged(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            if let volumeChangeType = userInfo["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? String {
                if volumeChangeType == "ExplicitVolumeChange" {
                    let volume = notification.userInfo!["AVSystemController_AudioVolumeNotificationParameter"] as! Float
                    volumeSlider.value = volume
                }
            }
        }
    }
    //MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentChapterArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cellId")
        let delta = Int64(currentChapterArray[indexPath.row].start)
        let time = CMTimeMake(delta, 1)
        cell.detailTextLabel?.text = time.toDisplayString()
        cell.textLabel?.text = currentChapterArray[indexPath.row].title
        //        cell.detailTextLabel?.text = "\(startTime)"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        let delta = Int64(currentChapterArray[indexPath.row].start)
        let fifteenSeconds = CMTimeMake(delta, 1)
        PlayerService.sharedIntance.player.seek(to: fifteenSeconds)
    }
    
    
    fileprivate func setupVolumeView() {
        let volumeView = MPVolumeView(frame: CGRect(x:-500, y:-100, width:0, height:0))
        volumeView.alpha = 0.001
      self.addSubview(volumeView)

    }
     func observePlayerCurrentTime() {
        let interval = CMTimeMake(1, 2)
        PlayerService.sharedIntance.player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            self?.currentTimeLabel.text = time.toDisplayString()
            let durationTime = PlayerService.sharedIntance.player.currentItem?.duration
            self?.durationLabel.text = durationTime?.toDisplayString()
            self?.updateCurrentTimeSlider()
        }
    }
    fileprivate func  updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(PlayerService.sharedIntance.player.currentTime())
        let durationSeconds = CMTimeGetSeconds(PlayerService.sharedIntance.player.currentItem?.duration ?? CMTimeMake(1, 1  ))
        let percentage = currentTimeSeconds / durationSeconds
        self.currentTimeSlider.value = Float(percentage)
    }
    fileprivate func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
    }
    @IBAction func handleDismiss(_ sender: UIButton) {
              self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseIn, animations:{ self.frame = CGRect(x:0, y:UIScreen.main.bounds.height+20, width:UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)}) { (hasFinished) in
            
        }
        
    }
    
    @IBAction func playbackSpeedBtnPressed(_ sender: UIButton) {
        sender.tag += 1
        if sender.tag > 3 { sender.tag = 0}
        switch  sender.tag {
        case 1:
            PlayerService.sharedIntance.player.rate = 1.5
            playbackSpeedButton.setTitle("\(PlayerService.sharedIntance.player.rate)", for: .normal)
        case 2:
            PlayerService.sharedIntance.player.rate = 2.0
            playbackSpeedButton.setTitle("\(PlayerService.sharedIntance.player.rate)", for: .normal)
        case 3:
            PlayerService.sharedIntance.player.rate = 0.5
            playbackSpeedButton.setTitle("\(PlayerService.sharedIntance.player.rate)", for: .normal)
        default:
            PlayerService.sharedIntance.player.rate = 1.0
            playbackSpeedButton.setTitle("\(PlayerService.sharedIntance.player.rate)", for: .normal)
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
    @IBAction func handleVolumeChanged(_ sender: UISlider) {
        MPVolumeView.setVolume(volume: sender.value)
    }
    @IBAction func handleCurrentTimeSliderChange(_ sender: UISlider) {
        let percentage = currentTimeSlider.value
        guard let duration = PlayerService.sharedIntance.player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, Int32(NSEC_PER_SEC))
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSeconds
        PlayerService.sharedIntance.player.seek(to: seekTime)
    }
    @IBAction func handlePlayPause(_ sender: UIButton) {
        if PlayerService.sharedIntance.player.timeControlStatus == .paused {
            PlayerService.sharedIntance.player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            PlayerService.sharedIntance.playerView?.pauseBtn.setImage(#imageLiteral(resourceName: "PauseWhite"), for: .normal)
               currentChapterArray = self.fetchChapters(PlayerService.sharedIntance.playerItem.asset.availableChapterLocales)
            if currentChapterArray.count == 0
            {tableView.frame =  .zero}
            else{
                tableView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 350)
                scrollView.bringSubview(toFront: tableView)
            tableView.reloadData()
            }
            var contentRect = CGRect.zero
            
            for view in scrollView.subviews {
                contentRect = contentRect.union(view.frame)
            }
            print("contentRect.size", contentRect.size)
            scrollView.contentSize = contentRect.size
            
            
            enlargeEpisodeImageView()
            self.setupElapsedTime(playbackRate: 1)
        } else {
            PlayerService.sharedIntance.player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
             PlayerService.sharedIntance.playerView?.pauseBtn.setImage(#imageLiteral(resourceName: "play-1"), for: .normal)

            shrinkEpisodeImageView()
            self.setupElapsedTime(playbackRate: 0)
        }
    }
    fileprivate func enlargeEpisodeImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = .identity
        })
    }
    fileprivate func setupElapsedTime(playbackRate: Float) {
        let elapsedTime = CMTimeGetSeconds(PlayerService.sharedIntance.player.currentTime())
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
    }
    
     fileprivate let shrunkenTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    fileprivate func shrinkEpisodeImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = .identity
            self.episodeImageView.transform = self.shrunkenTransform
        })
    }
  
    func fetchChapters(_ chapterLocales: [Locale]) -> [Chapter] {
        var chapterIndex = 1
        let chapterLocale = PlayerService.sharedIntance.playerItem.asset.availableChapterLocales
        var chapters = [Chapter]()
        for locale in chapterLocale {
            let chapterMetaData = PlayerService.sharedIntance.playerItem.asset.chapterMetadataGroups(withTitleLocale: locale, containingItemsWithCommonKeys: [AVMetadataKey.commonKeyArtwork])
            for chapterData in chapterMetaData {
                let chapter = Chapter(title: AVMetadataItem.metadataItems(from: chapterData.items, withKey: AVMetadataKey.commonKeyTitle, keySpace: AVMetadataKeySpace.common).first?.value?.copy(with: nil) as? String ?? "Chapter", start: Int(CMTimeGetSeconds(chapterData.timeRange.start)), duration: Int(CMTimeGetSeconds(chapterData.timeRange.duration)), index: chapterIndex)
                chapters.append(chapter)
                chapterIndex += 1
            }
        }
        return chapters
    }
}
extension MPVolumeView {
    static func setVolume( volume: Float) {
        let volumeView = MPVolumeView()
        volumeView.isHidden = true
        volumeView.alpha = 0.01
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume;
        }
    }
}
