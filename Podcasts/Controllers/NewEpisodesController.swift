//
//  NewEpisodesController.swift
//  Podcasts
//
//  Created by Boris Esanu on 7/11/18.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit
import MediaPlayer
import FeedKit
class NewEpisodesController: VCWithPlayer, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    var incompleteEpisodes = UserDefaults.standard.inProgressEpisodes()
    let formatter = DateFormatter()
    var clickedPodcast = Podcast()
    var previousSender: UIButtonWitName?
    @IBOutlet var thumbnail: UIImageView!
    
    @IBOutlet weak var episodesTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet var addToLibraryButton: UIButton!
    
    @IBOutlet weak var authorLabel: UILabel!
    var episodes = UserDefaults.standard.newEpisodes()
    var currentEpisodes = [Episode]()
    var podcasts = UserDefaults.standard.savedPodcasts()
    
    var podcast: Podcast? {
        didSet {
          
            fetchEpisodes()
           
        }
    }
    
    
    fileprivate func fetchEpisodes()  {
        print("Looking for episodes at feed url:", podcast?.feedUrl ?? "")
        guard let feedUrl = podcast?.feedUrl else { return }
        
        APIService.shared.fetchEpisodes(feedUrl: feedUrl) { (episodes, feed) in
            self.feed = feed
            self.episodes = episodes
            self.currentEpisodes = self.episodes
            DispatchQueue.main.async {
                self.episodesTableView.reloadData()
                feed.description =  feed.description?.replacingOccurrences(of: "\n", with: "")
             
                self.descriptionLabel.text = feed.description?.withoutHtml
                self.authorLabel.text = self.podcast?.artistName
 
                self.titleLabel.text = feed.title
                self.thumbnail.sd_setImage(with: URL(string: self.podcast?.artworkUrl600 ?? ""), completed: nil)
            }
        }
    }
    var feed: RSSFeed?
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        
        if isFavorite() {
             addToLibraryButton.setTitle("Remove from Library", for: .normal)
        }else{
             addToLibraryButton.setTitle("Add to Library", for: .normal)
        }
        addToLibraryButton.layer.cornerRadius = 20
        navigationController?.navigationBar.topItem?.title = "";
    
        self.navigationController?.navigationBar.isTranslucent = true
        formatter.dateFormat = "MMM d"
        let feedURLs = podcasts.compactMap { $0.feedUrl }
        print(feedURLs)
    
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView.alpha = 0.8
        visualEffectView.frame = self.thumbnail.bounds
        
        self.thumbnail.addSubview(visualEffectView)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
       
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 140
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    fileprivate func isFavorite() -> Bool{
        let savedPodcasts = UserDefaults.standard.savedPodcasts()
        let hasFavorited = savedPodcasts.index(where: { $0.trackName == self.podcast?.trackName && $0.artistName == self.podcast?.artistName }) != nil
        if hasFavorited {
            
            return true
        } else {
            return false
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .white
        if let selectionIndexPath = episodesTableView.indexPathForSelectedRow {
            self.episodesTableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }
 
    @IBAction func handleAddToLibrary(_ sender: UIButton) {
        
        if   !isFavorite() {

        guard let podcast = self.podcast else { return }

            
            APIService.shared.fetchEpisodes(feedUrl: podcast.feedUrl!) { (episodes, rss) in
                for episode in episodes{
                    if self.incompleteEpisodes.contains(where: { $0.title == episode.title}){
                        
                    }else{
                        
                        self.episodes.append(episode)
                        //
                        
                    }
                    
                }
                
                for var episode in episodes{
                    episode.podcast = podcast
                    UserDefaults.standard.newEpisode(episode: episode)
                    
                    
                }
              
            }
    
        var listOfPodcasts = UserDefaults.standard.savedPodcasts()
        listOfPodcasts.append(podcast)
        let data = NSKeyedArchiver.archivedData(withRootObject: listOfPodcasts)
        UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
            
            addToLibraryButton.setTitle("Remove from Library", for: .normal)
       
        }else{
            addToLibraryButton.setTitle("Add to Library", for: .normal)
            UserDefaults.standard.deletePodcast(podcast: podcast!)
//            guard let podcast = self.podcast else { return }
            
            
//            APIService.shared.fetchEpisodes(feedUrl: podcast.feedUrl!) { (episodes, rss) in
                for episode in episodes{
                    UserDefaults.standard.deleteNewEpisode(episode: episode)
                }
                
                
//            }
            
        }
    }
    @IBAction func handleOption(_ sender: UIButton) {
       
    }

 
    //MARK: - TableView
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentEpisodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EpisodCell", for: indexPath) as! EpisodCell
        if indexPath.row == 0 {
            let separatorLine = UIImageView.init(frame: CGRect(x: 19, y: 0, width: cell.frame.width-38, height: 0.5))
            
            separatorLine.backgroundColor = tableView.separatorColor
            cell.contentView.addSubview(separatorLine)
        }
        cell.title.text = self.currentEpisodes[indexPath.row].title
        cell.dateAndDuration.text = String(format: "%@ | %@", formatter.string(from: self.currentEpisodes[indexPath.row].pubDate), NewEpisodesController.getHoursMinutes(time: episodes[indexPath.row].duration ?? 0))
        cell.dateAndDuration.sizeToFit()
        cell.streamUrl = self.currentEpisodes[indexPath.row].streamUrl
     
        cell.podcast = self.currentEpisodes[indexPath.row].podcast
        
        cell.playButton.tag = indexPath.row
        cell.playButton.episode = self.currentEpisodes[indexPath.row]
        cell.playButton.addTarget(self, action: #selector(playButtonClicked), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        PlayerService.sharedIntance.episodes = episodes
      let chapterController = storyboard?.instantiateViewController(withIdentifier: "ChapterController") as! ChapterController
        chapterController.podcastName = titleLabel.text
        chapterController.episode = episodes[indexPath.row]
        chapterController.shouldPlay = false
         self.navigationController?.navigationBar.topItem?.title = "";
        chapterController.fillInDesign() {
            self.navigationController?.pushViewController(chapterController, animated: true)
        }
//        PlayerService.sharedIntance.play(stringURL: cell.streamUrl)
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
        
//        PlayerService.sharedIntance.saveInProgress()
        sender.setBackgroundImage(#imageLiteral(resourceName: "Pause button"), for: .normal)
        let delta = Int64(currentEpisodes[sender.tag].currentTime ?? 0.0)
        let seekToSeconds = CMTimeMake(delta, 1)
        PlayerService.sharedIntance.play(episode: sender.episode!, shouldSave: false, sender: sender)
        PlayerService.sharedIntance.player.seek(to: seekToSeconds)
         previousSender = sender
    }
 class func getHoursMinutes(time: Double) -> String {
    
    let hours = Int(time / 3600)
    let minutes = Int(time / 60) % 60
    return "\(hours)hr \(minutes)m"
    }


    //MARK: - Search
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else{
            currentEpisodes = episodes
            episodesTableView.reloadData()
            return
            
        }
        self.currentEpisodes = episodes.filter({ (episode) -> Bool in
        
            return  episode.title.lowercased().contains(searchText.lowercased())
           
        })
        episodesTableView.reloadData()
    }
   

    
}

