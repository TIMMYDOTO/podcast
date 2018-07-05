//
//  HomeController.swift
//  Podcasts
//
//  Created by Ivan Amidžić on 07/06/2018.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit
import SDWebImage
class HomeController: VCWithPlayer, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
   
    
   fileprivate let collectinCellId = "collectinCellId"
    @IBOutlet var mainTableView: UITableView!
    
    var pageControl = UIPageControl()
    var tableView = UITableView()
    
    let cellId = "cellId"
    
    var episodes = [Episode]()
    var podcasts = UserDefaults.standard.savedPodcasts()
    var incompleteEpisodes = [Episode]()
    
    let formatter = DateFormatter()
    var numberOfRows = NSMutableArray();

    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberOfRows.add(podcasts)
        numberOfRows.add(episodes)
        numberOfRows.add(incompleteEpisodes)
        
        formatter.dateFormat = "MM dd yyyy"
        let feedURLs = podcasts.compactMap { $0.feedUrl }
        print(feedURLs)
        for url in feedURLs {
            APIService.shared.fetchEpisodes(feedUrl: url) { (episode, _) in
                self.episodes.append(contentsOf: episode)
                self.episodes.sort { $0.pubDate > $1.pubDate }
                DispatchQueue.main.async {
                    self.mainTableView.reloadData()
                }
            }
        }

     
        
        setupNavigationBar()
        
     pageControl.numberOfPages = 3
    }
    
    fileprivate func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "musica-searcher"), style: .plain, target: self, action: #selector(searchButtonPressed))

        let plusBarItem = UIBarButtonItem(image:#imageLiteral(resourceName: "plus-symbol"), style: .plain, target: self, action: nil)
        let optionsBarItem = UIBarButtonItem(image:#imageLiteral(resourceName: "Setting_icon"), style: .plain, target: self, action: #selector(optionButtonPressed))
        navigationItem.setRightBarButtonItems([optionsBarItem, plusBarItem], animated: true)

        navigationItem.titleView = UIImageView.init(image: #imageLiteral(resourceName: "icon t2"))
    }
    
    @objc fileprivate func searchButtonPressed() {
        navigationController?.pushViewController(PodcastsSearchController(), animated: true)
    }
    @objc fileprivate func optionButtonPressed(){
       mainTableView.isEditing = !mainTableView.isEditing
    }
    
 
    

    //MARK: - Rearange rows
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = numberOfRows[sourceIndexPath.row]
        numberOfRows.removeObject(at: sourceIndexPath.row)
        numberOfRows.insert(item, at: destinationIndexPath.row)
    }
    
    //MARK:- TableView
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
     
     guard let tableViewCell = cell as? MainCell else { return }
    tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainCell
        if indexPath.row == 0 {
            cell.collectionView.backgroundView?.backgroundColor = UIColor.red
        }
        else if indexPath.row == 1{
            cell.newEpisodesTableView.backgroundView?.backgroundColor = UIColor.blue
        }
        else if indexPath.row == 2{
            cell.finishListening.backgroundView?.backgroundColor = UIColor.yellow
        }
       
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! FavouriteCell
        collectionCell.favouriteThumbNail.sd_setImage(with: URL.init(string: podcasts[indexPath.row].artworkUrl600!) , completed: nil)
        collectionCell.favouriteThumbNail.layer.borderColor = UIColor.black.cgColor
        collectionCell.favouriteThumbNail.layer.cornerRadius = 8.0
        
        return collectionCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
    }
}
    
//extension VCWithPlayer: UICollectionViewDelegate, UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 5
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! FavouriteCell
//            collectionCell.favouriteThumbNail.sd_setImage(with: URL.init(string: podcasts[indexPath.row].artworkUrl600!) , completed: nil)
//        collectionCell.favouriteThumbNail.layer.borderColor = UIColor.black.cgColor
//        collectionCell.favouriteThumbNail.layer.cornerRadius = 8.0
//
//        return collectionCell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
//    }
//}

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
//MARK:- CollectionView

//
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        pageControl.currentPage = indexPath.section
//    }
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return podcasts.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: collectinCellId, for: indexPath) as! FavouriteCell
//
//        collectionCell.favouriteThumbNail.sd_setImage(with: URL.init(string: podcasts[indexPath.row].artworkUrl600!) , completed: nil)
//        collectionCell.favouriteThumbNail.layer.borderColor = UIColor.black.cgColor
//        collectionCell.favouriteThumbNail.layer.cornerRadius = 8.0
//        return collectionCell
//}
//
//
//
////MARK:- UITableView
//
//
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "New Episodes"
//    }
//     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! NewEpisodeCell
//        let url = URL(string: episodes[indexPath.row].imageUrl?.toSecureHTTPS() ?? "")
//        cell.thumbNail.sd_setImage(with: url)
//
//    cell.title.text = episodes[indexPath.row].title
//    cell.author.text = episodes[indexPath.row].author
//    cell.pubdate.text =  formatter.string(from: episodes[indexPath.row].pubDate)
//
//    return cell
//
//}
//
//     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("count",episodes.count)
//        return episodes.count
//    }
//
//     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
////        let layout = UICollectionViewFlowLayout()
////        let favoritesController = FavoritesController(collectionViewLayout: layout)
////        let unplayedController = UnplayedController()
////        let inProgressController = InProgressController()
////        let vc = [favoritesController, unplayedController, inProgressController]
////        navigationController?.pushViewController(vc[indexPath.row], animated: true)
//    }



