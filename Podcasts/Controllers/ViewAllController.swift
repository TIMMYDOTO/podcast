//
//  ViewAllController.swift
//  Podcasts
//
//  Created by Boris Esanu on 7/19/18.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit

class ViewAllController: VCWithPlayer, UITableViewDataSource, UITableViewDelegate {
    var nameOfTable : String!
    var previousSender: UIButtonWitName?
    let podcasts = UserDefaults.standard.savedPodcasts()
    var episodes = [Episode]()
    var formatter = DateFormatter()
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        var title = ""
        
        formatter.dateFormat = "MMM d, yyyy"
        
        let feedURLs =  podcasts.compactMap { $0.feedUrl }
        
        print(feedURLs)
   
        if nameOfTable == "newEpisodesTableView" {
        episodes = UserDefaults.standard.newEpisodes()
                title = "New Episodes"
        }
         if nameOfTable == "finishListeningTableView" {
            
           episodes = UserDefaults.standard.inProgressEpisodes()
            title = "Finish Listening"
        }
         if nameOfTable == "downloadTableView" {
           episodes = UserDefaults.standard.downloadedEpisodes()
            title = "Downloads"
        }
        let rightItem = UIBarButtonItem(title: title, style: .plain, target: self, action: nil)
        rightItem.tintColor = UIColor(red: 17.0/255.0, green: 116.0/255.0, blue: 232.0/255.0, alpha: 1)
        
        rightItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "SFProDisplay-Semibold", size: 18)!], for: .normal)
        navigationItem.rightBarButtonItem = rightItem
    }

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
         

            if nameOfTable == "downloadTableView"{
                UserDefaults.standard.deleteDownloadedEpisode(episode: episodes[indexPath.row])
         
            }
            episodes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chapterController = storyboard?.instantiateViewController(withIdentifier: "ChapterController") as! ChapterController
//        chapterController.podcastName = titleLabel.text
        chapterController.episode = episodes[indexPath.row]
        chapterController.shouldPlay = false
            self.navigationController?.navigationBar.topItem?.title = ""
        chapterController.fillInDesign() {
        
            self.navigationController?.pushViewController(chapterController, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "VewAllCell", for: indexPath) as! VewAllCell
      
        cell.titleLabel.text = episodes[indexPath.row].title

        cell.authorLabel.text = self.episodes[indexPath.row].podcast?.trackName
        cell.authorLabel.sizeToFit()
        cell.pubdateLabel.text =  formatter.string(from: self.episodes[indexPath.row].pubDate)
     
        cell.shadowView.layer.shadowColor = UIColor.black.cgColor
        cell.shadowView.layer.shadowOpacity = 1
        cell.shadowView.layer.shadowOffset = CGSize.zero
        cell.shadowView.layer.shadowRadius = 3
        cell.shadowView.layer.shadowPath = UIBezierPath(roundedRect: cell.shadowView.bounds, cornerRadius: 10).cgPath
        cell.episodeImageView.sd_setImage(with: URL(string: episodes[indexPath.row].imageUrl!))
        cell.episodeImageView.frame =  cell.shadowView.bounds
        cell.episodeImageView.clipsToBounds = true
        cell.episodeImageView.layer.cornerRadius = 10
        cell.shadowView.addSubview(cell.episodeImageView)
        cell.playButton.episode = self.episodes[indexPath.row]
        cell.playButton.addTarget(self, action: #selector(playButtonClicked), for: .touchUpInside)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    @objc func playButtonClicked(sender: UIButtonWitName){
        PlayerService.sharedIntance.episodes = episodes
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
        PlayerService.sharedIntance.play(episode: sender.episode!, shouldSave: true, sender: sender)
        previousSender = sender
    }
}
