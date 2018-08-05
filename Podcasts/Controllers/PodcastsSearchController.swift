//
//  PodcastsSearchController.swift
//  Podcasts
//
//  Created by Ivan Amidžić on 18/02/2018.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit
import Alamofire

class PodcastsSearchController: UITableViewController, UISearchBarDelegate {
    let controllers = ["Top Charts", "Categories"]
    var podcasts = [Podcast]()
    let vcs = [FeaturedController(), CategoriesController()]
    let cellId = "cellId"
    let controllerCellId = "controllerCellId"
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rightItem = UIBarButtonItem(title: "", style: .done, target: self, action: #selector(backButton))
        rightItem.image = #imageLiteral(resourceName: "ArrowRightSide")
        self.navigationItem.rightBarButtonItem = rightItem
        
        let leftItem = UIBarButtonItem(title: "Discover", style: .plain, target: self, action: nil)
        leftItem.tintColor = UIColor(red: 17.0/255.0, green: 116.0/255.0, blue: 232.0/255.0, alpha: 1)
        
        leftItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "SFProDisplay-Semibold", size: 18)!], for: .normal)
        navigationItem.leftBarButtonItem = leftItem
       navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setupSearchBar()
        setupTableView()
    }
    
    @objc func backButton(){
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setupTableView() {
        tableView.tableFooterView = UIView()
        let nib = UINib(nibName: "PodcastCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .black
        
    }
    //MARK:- Setup Work
    
    fileprivate func setupSearchBar() {
        self.definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    var timer: Timer?
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (timer) in
            APIService.shared.fetchPodcasts(searchText: searchText) { (podcasts) in
                self.podcasts = podcasts
                self.tableView.reloadData()
            }
        })
    }
    //MARK:- UITableView
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if podcasts.count == 0 {
            navigationController?.pushViewController(vcs[indexPath.row], animated: true)
        }
            
        else{
       let storyboard = UIStoryboard(name: "Main", bundle: nil)
   let newEpisodeController = storyboard.instantiateViewController(withIdentifier: "newEpisodeController") as! NewEpisodesController
      
    
        let podcast = self.podcasts[indexPath.row]
        newEpisodeController.podcast = podcast
       newEpisodeController.navigationController?.isNavigationBarHidden = true
        navigationController?.pushViewController(newEpisodeController, animated: true)
        }
    }
    

    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.podcasts.count > 0 ? 0 : 250
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if podcasts.count == 0 {
          return controllers.count
        }
        return podcasts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        if podcasts.count == 0 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: controllerCellId)
             cell.textLabel?.text = controllers[indexPath.row]
            return cell
        }
       
          let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PodcastCell
        let podcast = self.podcasts[indexPath.row]
        cell.podcast = podcast
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         if podcasts.count == 0 {
            return 44
        }
        return 132
    }
    
}
