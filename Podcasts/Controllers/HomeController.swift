//
//  HomeController.swift
//  Podcasts
//
//  Created by Ivan Amidžić on 07/06/2018.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit

class HomeController: UITableViewController {
    
    let cellId = "cellId"
    let controllers = ["Favorites", "Unplayed", "In Progress"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    fileprivate func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "search"), style: .plain, target: self, action: #selector(searchButtonPressed))
    }
    
    @objc fileprivate func searchButtonPressed() {
        navigationController?.pushViewController(PodcastsSearchController(), animated: true)
    }
    
    //MARK:- UITableView
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: cellId)
        cell.textLabel?.text = controllers[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controllers.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let layout = UICollectionViewFlowLayout()
        let favoritesController = FavoritesController(collectionViewLayout: layout)
        let unplayedController = UnplayedController()
        let inProgressController = InProgressController()
        let vc = [favoritesController, unplayedController, inProgressController]
        navigationController?.pushViewController(vc[indexPath.row], animated: true)
    }
}


