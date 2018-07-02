//
//  HomeController.swift
//  Podcasts
//
//  Created by Ivan Amidžić on 07/06/2018.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit
import SDWebImage
class HomeController: VCWithPlayer, UICollectionViewDelegate, UICollectionViewDataSource {

    
   var collectionView = UICollectionView(frame: CGRect(x: 36, y: 0, width:UIScreen.main.bounds.width-72, height: 300), collectionViewLayout: UICollectionViewFlowLayout.init())
 
//    let cellId = "cellId"
//    let controllers = ["Favorites", "Unplayed", "In Progress"]
    
    fileprivate let collectinCellId = "collectinCellId"
    var podcasts = UserDefaults.standard.savedPodcasts()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 106, height: 106)
        layout.minimumInteritemSpacing = 6
        layout.minimumLineSpacing = 6
        
        collectionView.collectionViewLayout = layout
        collectionView.register(UINib(nibName:"FavouriteCell", bundle: nil), forCellWithReuseIdentifier: collectinCellId)
        collectionView.delegate = self
        collectionView.dataSource = self
  
        setupNavigationBar()
        view.addSubview(collectionView)
        
    }
    
    fileprivate func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "musica-searcher"), style: .plain, target: self, action: #selector(searchButtonPressed))

        let plusBarItem = UIBarButtonItem(image:#imageLiteral(resourceName: "plus-symbol"), style: .plain, target: self, action: nil)
        let optionsBarItem = UIBarButtonItem(image:#imageLiteral(resourceName: "Setting_icon"), style: .plain, target: self, action: nil)
        navigationItem.setRightBarButtonItems([optionsBarItem, plusBarItem], animated: true)

        navigationItem.titleView = UIImageView.init(image: #imageLiteral(resourceName: "icon t2"))
    }
    
    @objc fileprivate func searchButtonPressed() {
        navigationController?.pushViewController(PodcastsSearchController(), animated: true)
    }
    
     //MARK:- CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: collectinCellId, for: indexPath) as! FavouriteCell
        collectionCell.favouriteThumbNail.sd_setImage(with: URL.init(string: podcasts[indexPath.row].artworkUrl600!) , completed: nil)
        collectionCell.favouriteThumbNail.layer.borderColor = UIColor.black.cgColor
        collectionCell.favouriteThumbNail.layer.cornerRadius = 8.0
        return collectionCell
    }
    
    //MARK:- UITableView
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell(style: .default, reuseIdentifier: cellId)
//        cell.textLabel?.text = controllers[indexPath.row]
//        return cell
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return controllers.count
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let layout = UICollectionViewFlowLayout()
//        let favoritesController = FavoritesController(collectionViewLayout: layout)
//        let unplayedController = UnplayedController()
//        let inProgressController = InProgressController()
//        let vc = [favoritesController, unplayedController, inProgressController]
//        navigationController?.pushViewController(vc[indexPath.row], animated: true)
//    }
}


