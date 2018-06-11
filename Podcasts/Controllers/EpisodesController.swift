//
//  EpisodesController.swift
//  Podcasts
//
//  Created by Ivan Amidžić on 23/02/2018.
//  Copyright © 2018 Ivan Amidžić. All rights reserved.
//

import UIKit
import FeedKit

class EpisodesController: UITableViewController {
    let selectedIndex = IndexPath()
    var podcast: Podcast? {
        didSet {
            navigationItem.title = podcast?.trackName
            fetchEpisodes()
        }
    }
    var feed: RSSFeed?
    
    fileprivate func fetchEpisodes()  {
        print("Looking for episodes at feed url:", podcast?.feedUrl ?? "")
        guard let feedUrl = podcast?.feedUrl else { return }
        
        APIService.shared.fetchEpisodes(feedUrl: feedUrl) { (episodes, feed) in
            self.feed = feed
            self.episodes = episodes
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.mainDescriptionLabel.text = feed.description
            }
        }
    }
    
    fileprivate let cellId = "cellId"
    var episodes = [Episode]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBarButtons()
    }
    
    //MARK:- Setup Work
    
    fileprivate func setupNavigationBarButtons(){
        let savedPodcasts = UserDefaults.standard.savedPodcasts()
        let hasFavorited = savedPodcasts.index(where: { $0.trackName == self.podcast?.trackName && $0.artistName == self.podcast?.artistName }) != nil
        if hasFavorited {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart"), style: .plain, target: nil, action: nil)
        } else {
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleSaveFavorite))
            ]
        }
    }
    
    @objc fileprivate func handleFetchSavedPocasts() {
        print("Fetching saved podcasts from userdefaults")

        guard let data = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else { return }
        let savedPodcasts = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Podcast]
        savedPodcasts?.forEach({ (p) in
            print(p.trackName ?? "")
        })
    }
    
    @objc fileprivate func handleSaveFavorite() {
        print("Saving info into UserDefaults")
        guard let podcast = self.podcast else { return }
        var listOfPodcasts = UserDefaults.standard.savedPodcasts()
        listOfPodcasts.append(podcast)
        let data = NSKeyedArchiver.archivedData(withRootObject: listOfPodcasts)
        UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
        showBadgeHighlight()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart"), style: .plain, target: nil, action: nil)
    }
    
    fileprivate func showBadgeHighlight() {
        UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = "New"
    }
    
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 450
  }
    
    //MARK:- UITableView
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.color = .darkGray
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return episodes.isEmpty ? 200 : 0
    }
    
    let headerView: UIView = {
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .red
        return headerView
    }()

    let mainDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = self.episodes[indexPath.row]
        let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        mainTabBarController?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.episodes)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        let episode = episodes[indexPath.row]
        cell.episode = episode
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let downloadAction = UITableViewRowAction(style: .normal, title: "Download") { (_, _) in
            print("Downloading episodes")
            let episode = self.episodes[indexPath.row]
            UserDefaults.standard.downloadEpisode(episode: episode)
            APIService.shared.downloadEpisode(episode: episode)
            let cell = tableView.cellForRow(at: indexPath) as! EpisodeCell
            cell.downloadedImage.isHidden = false
        }
        return [downloadAction]
    }
}

extension EpisodesController: ReadMoreEpisodeDelegate {
    func moreTapped(cell: EpisodeCell) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
    



