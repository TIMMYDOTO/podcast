//
//  CategoriesViewController.swift
//  Podcasts
//
//  Created by Ivan Amidžić on 10/06/2018.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit


class FeaturedController: UITableViewController {
    
    let cellId = "cellId"
    var podcasts = [Podcast]()
    override func viewDidLoad() {
        self.view.transform = CGAffineTransform(scaleX: Constants.scale, y: Constants.scale)
        super.viewDidLoad()
        setupTableView()
        fetchFeaturedPodcasts()
        setupNavigationBar()
    }
    
    func fetchFeaturedPodcasts() {
        APIService.shared.fetchPopularPodcasts { (podcasts) in
            self.podcasts = podcasts
            self.tableView.reloadData()
        }
    }
    
    func setupNavigationBar() {
        navigationItem.title = "Featured Podcast"
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .black
        
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
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.color = .darkGray
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }
    
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return podcasts.isEmpty ? 200 : 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newEpisodeController = storyboard.instantiateViewController(withIdentifier: "newEpisodeController") as! NewEpisodesController
        
        let podcast = self.podcasts[indexPath.row]
        newEpisodeController.podcast = podcast
      
        navigationController?.pushViewController(newEpisodeController, animated: true)
    }
}
