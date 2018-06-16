//
//  CategoriesController.swift
//  Podcasts
//
//  Created by Ivan Amidžić on 10/06/2018.
//  Copyright © 2018 Ivan Amidžić. All rights reserved.
//

import UIKit


class CategoriesController: UITableViewController {
    
    let cellId = "cellId"
    let genres = ["Arts", "Comedy", "Education", "Kids & Family", "Health", "TV & Film", "Music", "News & Politics", "Religion & Spirituality", "Science & Medicine", "Sports & Recreation", "Technology", "Business", "Games & Hobbies", "Society & Culture", "Government & Organizations"]
    let genreIndexes = [1301, 1303, 1304, 1305, 1307, 1309, 1310, 1311, 1314, 1315, 1316, 1318, 1321, 1323, 1324, 1325]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    

    
    fileprivate func setupNavigationBar() {
        navigationItem.title = "Categories"
    }
    
    @objc fileprivate func searchButtonPressed() {
        navigationController?.pushViewController(PodcastsSearchController(), animated: true)
    }
    
    //MARK:- UITableView
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: cellId)
        cell.textLabel?.text = genres[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return genres.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let genreVC = GenrePodcasts()
        navigationController?.pushViewController(genreVC, animated: true)
        genreVC.genreName = genres[indexPath.row]
        genreVC.genreIndex = genreIndexes[indexPath.row]
    }
    
}
