//
//  GenrePodcasts.swift
//  Podcasts
//
//  Created by Ivan Amidžić on 10/06/2018.
//  Copyright © 2018 Ivan Amidžić. All rights reserved.
//

import UIKit


class GenrePodcasts: UITableViewController {
    
    var genreIndex: Int?
    let cellId = "cellId"
    var podcasts = [Podcast]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchFeaturedPodcasts()
        setupNavigationBar()
    }
    
    func fetchFeaturedPodcasts() {
        APIService.shared.fetchPodcastsByGenre(genreId: genreIndex!) { (podcasts) in
            self.podcasts = podcasts
            self.tableView.reloadData()
        }
    }
    
    func setupNavigationBar() {
        navigationItem.title = "Genre Podcasts"
    }
    
    //MARK:- UITableView
    
    fileprivate func setupTableView() {
        tableView.tableFooterView = UIView()
        let nib = UINib(nibName: "PodcastCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PodcastCell
        let podcasts = self.podcasts[indexPath.row]
        cell.podcast = podcasts
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episodesController = EpisodesController()
        let podcast = self.podcasts[indexPath.row]
        episodesController.podcast = podcast
        navigationController?.pushViewController(episodesController, animated: true)
    }
}
