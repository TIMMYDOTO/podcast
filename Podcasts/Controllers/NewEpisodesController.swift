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

        formatter.dateFormat = "MMM d"
        let feedURLs = podcasts.compactMap { $0.feedUrl }
        print(feedURLs)

//        for  podcast in podcasts{
//            APIService.shared.fetchEpisodes(feedUrl: podcast.feedUrl!) { ( episode, _) in
//
//                var myEpisode = episode
//                for (index, _) in myEpisode.enumerated(){
//                    myEpisode[index].podcast = podcast
//                }
//                self.episodes.append(contentsOf: myEpisode)
//
//                self.episodes.sort { $0.pubDate > $1.pubDate }
//                self.currentEpisodes = self.episodes
//                DispatchQueue.main.async {
//                self.episodesTableView.reloadData()
//                }
//            }
//
//        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         self.navigationController?.isNavigationBarHidden = true

     
    }
 
    @IBAction func handleAddToLibrary(_ sender: UIButton) {
        var podcasts = UserDefaults.standard.savedPodcasts()
        var podcastInArray = false
        for (_, podcast) in podcasts.enumerated() {
            if clickedPodcast.artistName == podcast.artistName{
               podcastInArray = true
                
            }
            
        }
        if podcastInArray == false {
               podcasts.append(clickedPodcast)
            let data = NSKeyedArchiver.archivedData(withRootObject: podcasts)
            UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
         
        }
    }
    
    @IBAction func handleOption(_ sender: UIButton) {
       
    }
    @IBAction func backButton(_ sender: UIButton) {
        let homeController = storyboard?.instantiateViewController(withIdentifier: "HomeController") as! HomeController
        self.navigationController?.isNavigationBarHidden = false
        
        self.navigationController?.pushViewController(homeController, animated: true)
    }
    
    
   
    
    //MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentEpisodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EpisodCell", for: indexPath) as! EpisodCell
   
        cell.title.text = self.currentEpisodes[indexPath.row].title
        cell.date.text = formatter.string(from: self.currentEpisodes[indexPath.row].pubDate)
//        cell.authorText = self.currentEpisodes[indexPath.row].author
//        cell.descriptionText = self.currentEpisodes[indexPath.row].description
        cell.streamUrl = self.currentEpisodes[indexPath.row].streamUrl
       
        cell.duration.text = getHoursMinutes(time: episodes[indexPath.row].duration ?? 0)
      
//        cell.showTitle = self.currentEpisodes[indexPath.row].podcast?.artistName
        cell.podcast = self.currentEpisodes[indexPath.row].podcast
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! EpisodCell
   
        
//        clickedPodcast = cell.podcast!
        
       
      

        PlayerService.sharedIntance.play(stringURL: cell.streamUrl)
    }
    
    
    func getHoursMinutes(time: Double) -> String {
 
        let hours = Int(time/3600)
        let minutes = Int(time/60)
        
        var finalString = ""
        if hours > 0 {
             finalString =  "| " + String(hours) + "hr "
        }
       
        if minutes > 0 {
        finalString  = finalString + String(minutes) + "m"
        }
        return finalString
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
