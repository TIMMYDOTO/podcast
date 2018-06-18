//
//  InProgressController.swift
//  Podcasts
//
//  Created by Ivan Amidžić on 12/06/2018.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit
import AVFoundation

class InProgressController: UITableViewController {

    var incompleteEpisodes = [Episode]()
    var inprogressEpisodes = UserDefaults.standard.inProgressEpisodes()
    var incompleteEpisodesTime = [Double]()
    var inProgressEpisodesTime = UserDefaults.standard.inProgressEpisodesTimes()
    let cellId = "cellId"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        incompleteEpisodes = UserDefaults.standard.inProgressEpisodes()
        incompleteEpisodesTime = UserDefaults.standard.inProgressEpisodesTimes()
        tableView.reloadData()
        setupTableView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        setupNavigationBar()
    }
    
    
    fileprivate func setupNavigationBar() {
        navigationItem.title = "In Progress"
    }
    
    //MARK:- UITableView
    
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "InProgressCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 450
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return incompleteEpisodes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! InProgressCell
        let inProgressEpisodes = incompleteEpisodes[indexPath.row]
        cell.episode = inProgressEpisodes
        let time = self.incompleteEpisodesTime[indexPath.row]
        if let fullTime = self.incompleteEpisodes[indexPath.row].duration {
            let timeRemaining = fullTime - time
            cell.durationLabel.text = timeRemaining.asString(style: .abbreviated) + " remaining"
        }
        cell.delegate = self
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
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let episode = self.incompleteEpisodes[indexPath.row]
        let time = self.inProgressEpisodesTime[indexPath.row]
        incompleteEpisodes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        UserDefaults.standard.deleteEpisodeInProgress(episode: episode)
        UserDefaults.standard.deleteInProgressTime(time: time, indexPath: indexPath.row)
        
    }
}

extension InProgressController: ReadMoreInProgressEpisodeDelegate {
    func moreTapped(cell: InProgressCell) {
            tableView.beginUpdates()
            tableView.endUpdates()
            }
}
