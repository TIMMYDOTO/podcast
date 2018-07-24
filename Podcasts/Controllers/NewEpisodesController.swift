//
//  NewEpisodesController.swift
//  Podcasts
//
//  Created by Artyom Schiopu on 7/11/18.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit
import FeedKit
class NewEpisodesController: VCWithPlayer, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    let formatter = DateFormatter()
    var clickedPodcast = Podcast()
    
    @IBOutlet var thumbnail: UIImageView!
    
    @IBOutlet weak var episodesTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var authorLabel: UILabel!
    var episodes = [Episode]()
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
                self.descriptionLabel.text = feed.description
                self.authorLabel.text = self.podcast?.artistName
                self.authorLabel.sizeToFit()
                self.titleLabel.text = feed.title
                self.titleLabel.sizeToFit()
                self.thumbnail.sd_setImage(with: URL(string: self.podcast?.artworkUrl600 ?? ""), completed: nil)
            }
        }
    }
    var feed: RSSFeed?
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = true
        formatter.dateFormat = "MMM d"
        let feedURLs = podcasts.compactMap { $0.feedUrl }
        print(feedURLs)

      

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

    }
 
    @IBAction func handleAddToLibrary(_ sender: UIButton) {
        if   !isFavorite() {
         
       
        guard let podcast = self.podcast else { return }
        var listOfPodcasts = UserDefaults.standard.savedPodcasts()
        listOfPodcasts.append(podcast)
        let data = NSKeyedArchiver.archivedData(withRootObject: listOfPodcasts)
        UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
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
        cell.playButton.addTarget(self, action: #selector(playButtonClicked), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

      let chapterController = storyboard?.instantiateViewController(withIdentifier: "ChapterController") as! ChapterController
        chapterController.podcastName = titleLabel.text
        chapterController.episode = episodes[indexPath.row]
     chapterController.shouldPlay = false
        self.navigationController?.pushViewController(chapterController, animated: true)
//        PlayerService.sharedIntance.play(stringURL: cell.streamUrl)
    }
    
    @objc func playButtonClicked(sender: UIButton){
        print("playButtonClicked", sender.tag)
        let chapterController = storyboard?.instantiateViewController(withIdentifier: "ChapterController") as! ChapterController
        chapterController.podcastName = titleLabel.text
        chapterController.episode = episodes[sender.tag]
        chapterController.shouldPlay = true
        self.navigationController?.pushViewController(chapterController, animated: true)
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
