//
//  InProgressController.swift
//  Podcasts
//
//  Created by Ivan Amidžić on 12/06/2018.
//  Copyright © 2018 Ivan Amidžić. All rights reserved.
//

import UIKit
import AVFoundation

class InProgressController: UITableViewController {

    var incompleteEpisodes = [Episode]()
    var inprogressEpisodes = UserDefaults.standard.inProgressEpisodes()
    var incompleteEpisodesTime = [Double]()
    var inProgressEpisodesTime = UserDefaults.standard.inProgressEpisodesTimes()

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        incompleteEpisodes = UserDefaults.standard.inProgressEpisodes()
        incompleteEpisodesTime = UserDefaults.standard.inProgressEpisodesTimes()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return incompleteEpisodes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = incompleteEpisodes[indexPath.row].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = self.incompleteEpisodes[indexPath.row]
        let time = self.inProgressEpisodesTime[indexPath.row]
        let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        mainTabBarController?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.incompleteEpisodes)
        let durationInSeconds = Float64(time)
        let seekTime = CMTimeMakeWithSeconds(durationInSeconds, Int32(NSEC_PER_SEC))
        mainTabBarController?.playerDetailsView.player.seek(to: seekTime)

        
    }
}
