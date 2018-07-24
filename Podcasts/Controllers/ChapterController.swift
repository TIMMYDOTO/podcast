//
//  ChapterController.swift
//  Podcasts
//
//  Created by Artyom Schiopu on 7/19/18.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer
class ChapterController: VCWithPlayer, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var artWorkImage: UIImageView!
    @IBOutlet weak internal var episodeNameLabel: UILabel!
    @IBOutlet weak internal var infoLabel: UILabel!
    @IBOutlet weak internal var descriptionLabel: UILabel!
    @IBOutlet weak internal var tableView: UITableView!
    var podcastName: String!
    var episode: Episode!
    var currentChapterArray = [Chapter]()
    var shouldPlay:Bool!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       fillInDesign()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.isTranslucent = true
    }
    func fillInDesign(){
        navigationController?.navigationBar.topItem?.title = "";
        
        artWorkImage.sd_setImage(with: URL(string: episode.imageUrl!))
        let rightItem = UIBarButtonItem(title: podcastName, style: .plain, target: self, action: nil)
        rightItem.tintColor = UIColor(red: 17.0/255.0, green: 116.0/255.0, blue: 232.0/255.0, alpha: 1)

        rightItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "SFProDisplay-Semibold", size: 18)!], for: .normal)
        navigationItem.rightBarButtonItem = rightItem
//        podcastNameLabel.text = podcastName
        episodeNameLabel.text = episode.title
  
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowOffset = CGSize.zero
        shadowView.layer.shadowRadius = 3
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 10).cgPath
        artWorkImage.frame = shadowView.bounds
        artWorkImage.clipsToBounds = true
        artWorkImage.layer.cornerRadius = 10
        shadowView.addSubview(artWorkImage)
        let duration = NewEpisodesController.getHoursMinutes(time: episode.duration!)
     
            self.getDownloadSize(url: URL(string: self.episode.streamUrl)!) { (size, err) in
            let podCastSize = Double(size)/1024.0/1024.0
           self.infoLabel.text = self.daysBetween(start: self.episode.pubDate, end: Date.init()) + " days ago | \(duration) | \(podCastSize.cleanValue)mb"
                print("err: ", err ?? "no err")
        }
        
        
        descriptionLabel.text = episode.description
        PlayerService.sharedIntance.play(episode: episode)
        currentChapterArray = fetchChapters(PlayerService.sharedIntance.playerItem.asset.availableChapterLocales)
        if !shouldPlay{
            PlayerService.sharedIntance.playerView?.handlePlayPause()
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
        if currentChapterArray.count == 0 {
            tableView.isHidden = true
            
        }
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
       
        cell.chapterNameLabel.sizeToFit()
        cell.chapterStartTimeLabel.sizeToFit()
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let delta = Int64(currentChapterArray[indexPath.row].start)
        let fifteenSeconds = CMTimeMake(delta, 1)
        PlayerService.sharedIntance.player.seek(to: fifteenSeconds)
    }
    @IBAction func handleDownload(_ sender: UIButton) {
        UserDefaults.standard.downloadEpisode(episode: episode)
        APIService.shared.downloadEpisode(episode: episode)
    }
    
    @IBAction func handlePlayEpisode(_ sender: UIButton) {
        PlayerService.sharedIntance.play(episode: episode)
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
