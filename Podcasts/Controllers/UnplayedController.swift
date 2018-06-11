//
//  UnplayedController.swift
//  Podcasts
//
//  Created by Ivan Amidžić on 11/06/2018.
//  Copyright © 2018 Ivan Amidžić. All rights reserved.
//

import UIKit

class UnplayedController: UITableViewController {
    
    let podcasts = UserDefaults.standard.savedPodcasts()
    var episodes = [Episode]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let feedURLs = podcasts.compactMap { $0.feedUrl }
        print(feedURLs)
        for url in feedURLs {
            APIService.shared.fetchEpisodes(feedUrl: url) { (episode, _) in
                self.episodes.append(contentsOf: episode)
                self.episodes.sort { $0.pubDate > $1.pubDate }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }

}
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = episodes[indexPath.row].title
        cell.backgroundColor = .red
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }


}


