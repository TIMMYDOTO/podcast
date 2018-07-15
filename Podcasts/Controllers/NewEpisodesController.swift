//
//  NewEpisodesController.swift
//  Podcasts
//
//  Created by Artyom Schiopu on 7/11/18.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit

class NewEpisodesController: VCWithPlayer, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    let formatter = DateFormatter()

    
    @IBOutlet weak var episodesTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var authorLabel: UILabel!
    var episodes = [Episode]()
    var currentEpisodes = [Episode]()
    let podcasts = UserDefaults.standard.savedPodcasts()
    override func viewDidLoad() {
        super.viewDidLoad()
       
        formatter.dateFormat = "MMM d"
        let feedURLs = podcasts.compactMap { $0.feedUrl }
        print(feedURLs)
        for url in feedURLs {
            APIService.shared.fetchEpisodes(feedUrl: url) { (episode, _) in
                self.episodes.append(contentsOf: episode)
                self.episodes.sort { $0.pubDate > $1.pubDate }
                self.currentEpisodes = self.episodes
                DispatchQueue.main.async {
                    self.episodesTableView.reloadData()
                }
            }
        }
       

    }
    

    @IBAction func handleAddToLibrary(_ sender: UIButton) {
        
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
        cell.authorText = self.currentEpisodes[indexPath.row].author
        cell.descriptionText = self.currentEpisodes[indexPath.row].description
        cell.streamUrl = self.currentEpisodes[indexPath.row].streamUrl
       
        cell.duration.text = getHoursMinutes(time: episodes[indexPath.row].duration ?? 0)

        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! EpisodCell
        descriptionLabel.text = cell.descriptionText
        authorLabel.text = cell.authorText
        titleLabel.text = cell.title.text
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
