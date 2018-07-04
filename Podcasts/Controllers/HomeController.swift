//
//  HomeController.swift
//  Podcasts
//
//  Created by Ivan Amidžić on 07/06/2018.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit
import SDWebImage
class HomeController: VCWithPlayer, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {

   
   var collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout.init())
   fileprivate let collectinCellId = "collectinCellId"
    
    var pageControl = UIPageControl()
    var tableView = UITableView()
    
    let cellId = "cellId"
    
    var episodes = [Episode]()
    var podcasts = UserDefaults.standard.savedPodcasts()
    var incompleteEpisodes = [Episode]()
    
    let formatter = DateFormatter()
    var numberOfRows = NSMutableArray();
   var thisWidth:CGFloat = 0
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
                    self.tableView.reloadData()
                }
            }
        }
        tableView.register(UINib(nibName: "NewEpisodeCell", bundle: nil), forCellReuseIdentifier: cellId)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 106, height: 106)
        layout.minimumInteritemSpacing = 6
        layout.minimumLineSpacing = 10
        
        layout.scrollDirection = .horizontal
        collectionView.frame = CGRect(x: 17, y: (self.navigationController?.navigationBar.frame.size.height)!+50, width:UIScreen.main.bounds.width - 34, height: 230)
        collectionView.backgroundColor = UIColor.clear
        collectionView.collectionViewLayout = layout
        collectionView.register(UINib(nibName:"FavouriteCell", bundle: nil), forCellWithReuseIdentifier: collectinCellId)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = true
//        collectionView.isPagingEnabled = true
        
        tableView.frame = CGRect(x: 17, y: collectionView.frame.size.height+200, width: UIScreen.main.bounds.width - 34, height: UIScreen.main.bounds.height - collectionView.frame.size.height)
        tableView.delegate = self
        tableView.dataSource = self
        
        setupNavigationBar()
        view.addSubview(collectionView)
        view.addSubview(tableView)
     pageControl.numberOfPages = 3
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


    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        pageControl.currentPage = indexPath.section
    }
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
    
  
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "New Episodes"
    }
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! NewEpisodeCell
        let url = URL(string: episodes[indexPath.row].imageUrl?.toSecureHTTPS() ?? "")
        cell.thumbNail.sd_setImage(with: url)
    cell.title.text = episodes[indexPath.row].title
    cell.author.text = episodes[indexPath.row].author
    cell.pubdate.text =  formatter.string(from: episodes[indexPath.row].pubDate)
        
    return cell
        
}

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count",episodes.count)
        return episodes.count
    }

     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let layout = UICollectionViewFlowLayout()
//        let favoritesController = FavoritesController(collectionViewLayout: layout)
//        let unplayedController = UnplayedController()
//        let inProgressController = InProgressController()
//        let vc = [favoritesController, unplayedController, inProgressController]
//        navigationController?.pushViewController(vc[indexPath.row], animated: true)
    }
}


