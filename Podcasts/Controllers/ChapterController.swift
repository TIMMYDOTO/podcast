//
//  ChapterController.swift
//  Podcasts
//
//  Created by Boris Esanu on 7/19/18.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer
class ChapterController: VCWithPlayer, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var downloadButton: UIButton!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var artWorkImage: UIImageView!
    @IBOutlet weak internal var episodeNameLabel: UILabel!
    @IBOutlet weak internal var infoLabel: UILabel!
    @IBOutlet weak internal var descriptionLabel: UILabel!
    @IBOutlet weak internal var tableView: UITableView!
    var previousSender: UIButtonWitName?
    var podcastName: String!
    var episode: Episode!
    var currentChapterArray = [Chapter]()
    var shouldPlay:Bool!
    var previousCell: ChapterCell?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.isTranslucent = true
        
        if currentChapterArray.count == 0 {
            tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: 0)
        }
        var contentRect = CGRect.zero
        for view in scrollView.subviews {
            contentRect = contentRect.union(view.frame)
            
        }
        
        contentRect.size.height = contentRect.size.height + 70
        scrollView.contentSize = contentRect.size
        scrollView.bringSubview(toFront: tableView)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            self.currentChapterArray = self.fetchChapters(PlayerService.sharedIntance.playerItem.asset.availableChapterLocales)
            if self.currentChapterArray.count > 0{
                  self.tableView.isHidden = false
                self.tableView.reloadData()
                self.tableView.frame = CGRect(x: 0, y: self.descriptionLabel.frame.size.height + self.descriptionLabel.frame.origin.y + 5, width: self.view.frame.size.width, height: UIScreen.main.bounds.height - (self.descriptionLabel.frame.size.height + self.descriptionLabel.frame.origin.y + 5) - 47)
              
            }
            if !self.shouldPlay{
                PlayerService.sharedIntance.playerView?.handlePlayPause(notSave: true, sender: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func fillInDesign(completionHandler: @escaping ()->()){
        
        DispatchQueue.main.async {
            self.loadViewIfNeeded()
            self.navigationController?.navigationBar.topItem?.title = "";
        
            let rightItem = UIBarButtonItem(title: self.podcastName, style: .plain, target: self, action: nil)
            rightItem.tintColor = UIColor(red: 17.0/255.0, green: 116.0/255.0, blue: 232.0/255.0, alpha: 1)
            
            rightItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "SFProDisplay-Semibold", size: 18)!], for: .normal)
            self.navigationItem.rightBarButtonItem = rightItem
            //        podcastNameLabel.text = podcastName
            
            self.episodeNameLabel.text = self.episode.title
            self.episodeNameLabel.textAlignment = .right
            self.shadowView.layer.shadowColor = UIColor.black.cgColor
            self.shadowView.layer.shadowOpacity = 1
            self.shadowView.layer.shadowOffset = CGSize.zero
            self.shadowView.layer.shadowRadius = 3
            self.shadowView.layer.shadowPath = UIBezierPath(roundedRect: self.shadowView.bounds, cornerRadius: 10).cgPath
            self.artWorkImage.frame = self.shadowView.bounds
            self.artWorkImage.clipsToBounds = true
            self.artWorkImage.layer.cornerRadius = 10
            self.shadowView.addSubview(self.artWorkImage)
            
        
        }
     
            self.getDownloadSize(url: URL(string: self.episode.streamUrl)!) { (size, err) in
          
                let podCastSize = Double(size)/1024.0/1024.0
                var str = String(podCastSize)
                if str.contains("-"){
                    str = "\"404\""
                }
                
                let duration = NewEpisodesController.getHoursMinutes(time: self.episode.duration!)
                
                if str == "\"404\"" {
                    DispatchQueue.main.async {
                        self.infoLabel.text = self.daysBetween(start: self.episode.pubDate, end: Date.init()) + " days ago | \(duration) | \(str)"
                        NSLog("\(#function) end")
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.infoLabel.text = self.daysBetween(start: self.episode.pubDate, end: Date.init()) + " days ago | \(duration) | \(podCastSize.cleanValue)mb"
                        NSLog("\(#function) end")
                    }
                }
            }
        
            
        DispatchQueue.main.async {
            NSLog("\(#function) start 2nd dispatch")
            self.descriptionLabel.text = self.episode.description
            self.descriptionLabel.sizeToFit()
            
            if !self.shouldPlay {
                PlayerService.sharedIntance.play(episode: self.episode, shouldSave: false, sender: nil)
            }
            else{
                PlayerService.sharedIntance.play(episode: self.episode, shouldSave: true, sender: nil)
            }
        
//            self.currentChapterArray = self.fetchChapters(PlayerService.sharedIntance.playerItem.asset.availableChapterLocales)
//            if !self.shouldPlay{
//                PlayerService.sharedIntance.playerView?.handlePlayPause(notSave: true, sender: nil)
//            }
            
     
            self.artWorkImage.sd_setImage(with: URL(string: self.episode.imageUrl!))
            completionHandler()
            IJProgressView.shared.hideProgressView()
          }
    }
    

func getDownloadSize(url: URL, completion: @escaping (Int64, Error?) -> Void) {
    let timeoutInterval = 5.0
    var request = URLRequest(url: url,
                             cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                             timeoutInterval: timeoutInterval)
    request.httpMethod = "HEAD"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
        let contentLength = response?.expectedContentLength ?? NSURLSessionTransferSizeUnknown
        completion(contentLength, error)
        }.resume()
}


func daysBetween(start: Date, end: Date) -> String {
    return String(Calendar.current.dateComponents([.day], from: start, to: end).day!)
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

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    if currentChapterArray.count == 0 {
//        tableView.isHidden = true
//        
//    }
    return currentChapterArray.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "chapterCell", for: indexPath) as! ChapterCell
    if indexPath.row == 0 {
        let separatorLine = UIImageView.init(frame: CGRect(x: 19, y: 0, width: cell.frame.width-38, height: 0.5))
        
        separatorLine.backgroundColor = tableView.separatorColor
        cell.contentView.addSubview(separatorLine)
    }
    
    let delta = Int64(currentChapterArray[indexPath.row].start)
    let time = CMTimeMake(delta, 1)
    cell.chapterNameLabel.text = currentChapterArray[indexPath.row].title
    cell.chapterStartTimeLabel.text = String(currentChapterArray[indexPath.row].start)
    
    cell.chapterStartTimeLabel.text = time.toDisplayString()
    cell.chapterStartButton.addTarget(self, action: #selector(playButtonClicked), for: .touchUpInside)
    cell.chapterStartButton.tag = indexPath.row
    cell.chapterNameLabel.sizeToFit()
    cell.chapterStartTimeLabel.sizeToFit()
    return cell
}
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 45
}

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
    
    let delta = Int64(currentChapterArray[indexPath.row].start)
    let fifteenSeconds = CMTimeMake(delta, 1)
    PlayerService.sharedIntance.player.seek(to: fifteenSeconds)
    let cell = tableView.cellForRow(at: indexPath) as! ChapterCell
    
    if previousSender == cell{
        
        PlayerService.sharedIntance.player.pause()
        PlayerService.sharedIntance.playerDetailsView.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        PlayerService.sharedIntance.playerView?.pauseBtn.setImage(#imageLiteral(resourceName: "play-1"), for: .normal)
        previousCell = nil
        return
    }
    if previousCell != nil{
        previousCell?.chapterStartButton.setBackgroundImage(#imageLiteral(resourceName: "play-button-2"), for: .normal)
    }
    
    
    PlayerService.sharedIntance.player.play()
    
    
    PlayerService.sharedIntance.playerView?.pauseBtn.setImage(#imageLiteral(resourceName: "PauseWhite"), for: .normal)
    PlayerService.sharedIntance.playerDetailsView.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
    
    
    
    previousCell = cell
}

func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 70
}
func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
    view.tintColor = .white
}
@objc func playButtonClicked(sender: UIButtonWitName){
    if previousSender == sender{
        
        sender.setBackgroundImage(#imageLiteral(resourceName: "play-button-2"), for: .normal)
        PlayerService.sharedIntance.player.pause()
        PlayerService.sharedIntance.playerDetailsView.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        PlayerService.sharedIntance.playerView?.pauseBtn.setImage(#imageLiteral(resourceName: "play-1"), for: .normal)
        
        previousSender = nil
        return
    }
    if previousSender != nil{
        previousSender?.setBackgroundImage(#imageLiteral(resourceName: "play-button-2"), for: .normal)
    }
    sender.setBackgroundImage(#imageLiteral(resourceName: "Pause button"), for: .normal)
    let delta = Int64(currentChapterArray[sender.tag].start)
    let fifteenSeconds = CMTimeMake(delta, 1)
    PlayerService.sharedIntance.player.seek(to: fifteenSeconds)
    PlayerService.sharedIntance.player.play()
    
    previousSender = sender
}


@IBAction func handleDownload(_ sender: UIButton) {
    
    downloadButton.isEnabled = false
    let savedEpisodes =  UserDefaults.standard.downloadedEpisodes()
    if savedEpisodes.contains(where: { $0.title == episode.title }){
        print("contains")
    } else {
        
        APIService.shared.downloadEpisode(episode: episode)
        
    }
    
    
    
}

@IBAction func handlePlayEpisode(_ sender: UIButton) {
    
    PlayerService.sharedIntance.play(episode: episode, shouldSave: true, sender: nil)
    
}

@IBAction func handleOption(_ sender: UIButton) {
}

}
extension Double
{
    var cleanValue: String
    {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(format: "%.1f", self)
    }
}
