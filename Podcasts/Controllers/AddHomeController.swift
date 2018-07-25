//
//  AddHomeController.swift
//  Podcasts
//
//  Created by Artyom Schiopu on 7/22/18.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit

class AddHomeController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    let collectinCellId = "collectinCellId"
    let cellIdNewEpisode = "cellIdNewEpisode"
    var podcasts = UserDefaults.standard.savedPodcasts()
    var episodes = [Episode]()
    
    @IBOutlet var favoritesCollectionView: UICollectionView!
    
    @IBOutlet var newEpisodesTableView: UITableView!
    @IBOutlet var finishListeningTableView: UITableView!
    @IBOutlet weak var downloadTableView: UITableView!
    let formatter = DateFormatter()
    var deletedTables = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let rightItem = UIBarButtonItem(title: "Add to Home", style: .plain, target: self, action: nil)
        rightItem.tintColor = UIColor(red: 17.0/255.0, green: 116.0/255.0, blue: 232.0/255.0, alpha: 1)
        
        rightItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "SFProDisplay-Semibold", size: 18)!], for: .normal)
        navigationItem.rightBarButtonItem = rightItem
        
        let feedURLs = podcasts.compactMap { $0.feedUrl }
        print(feedURLs)
        for url in feedURLs {
            APIService.shared.fetchEpisodes(feedUrl: url) { (episode, _) in
                self.episodes.append(contentsOf: episode)
                self.episodes.sort { $0.pubDate > $1.pubDate }
                DispatchQueue.main.async {
                    self.newEpisodesTableView.reloadData()
                }
            }
        }
        
         formatter.dateFormat = "MMM d, yyyy"
        let deletedTables: [String]?  = UserDefaults.standard.object(forKey: "deletedTables") as? [String]
        
        var yPosition:CGFloat = 0.0
        if deletedTables != nil {
            for table in deletedTables! {
            
            if table == "collectionView"{
                favoritesCollectionView.frame = CGRect(x:37,y: yPosition, width: view.frame.width-61, height: 230)
                view.addSubview(favoritesCollectionView)
                
                yPosition = yPosition + favoritesCollectionView.frame.height
                favoritesCollectionView.dataSource = self
                favoritesCollectionView.delegate = self
            }
            else if table == "newEpisodesTableView"{
                newEpisodesTableView.frame = CGRect(x:37,y: yPosition, width: view.frame.width-61, height: 230)
                newEpisodesTableView.allowsSelection = false
                newEpisodesTableView.isScrollEnabled = false
                
                view.addSubview(newEpisodesTableView)
                yPosition = yPosition + newEpisodesTableView.frame.height
                newEpisodesTableView.dataSource = self
                newEpisodesTableView.delegate = self
            }
            else if table == "finishListeningTableView"{
                finishListeningTableView.frame = CGRect(x:37,y: yPosition, width: view.frame.width-61, height: 230)
                view.addSubview(finishListeningTableView)
                finishListeningTableView.allowsSelection = false
                finishListeningTableView.isScrollEnabled = false
                
                yPosition = yPosition + finishListeningTableView.frame.height
                finishListeningTableView.dataSource = self
                finishListeningTableView.delegate = self
                
            }
            else{
                downloadTableView.frame = CGRect(x:37,y: yPosition, width: view.frame.width-61, height: 230)
                view.addSubview(downloadTableView)
                downloadTableView.allowsSelection = false
                downloadTableView.isScrollEnabled = false
                yPosition = yPosition + downloadTableView.frame.height
                downloadTableView.dataSource = self
                finishListeningTableView.delegate = self
            }
        }
        
    }
}
    
    //#MARK: - Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return self.podcasts.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectinCellId, for: indexPath) as! FavouriteCell
        
        
        cell.shadowView.layer.shadowColor = UIColor.black.cgColor
        cell.shadowView.layer.shadowOpacity = 1
        cell.shadowView.layer.shadowOffset = CGSize.zero
        cell.shadowView.layer.shadowRadius = 3
        cell.shadowView.layer.shadowPath = UIBezierPath(roundedRect: cell.shadowView.bounds, cornerRadius: 10).cgPath
        
        
        cell.favouriteThumbNail.sd_setImage(with: URL.init(string: podcasts[indexPath.row].artworkUrl600!) , completed: nil)
        cell.favouriteThumbNail.frame =  cell.shadowView.bounds
        cell.favouriteThumbNail.clipsToBounds = true
        cell.favouriteThumbNail.layer.cornerRadius = 10
        cell.shadowView.addSubview(cell.favouriteThumbNail)
        
        return cell
    }
    
    
    //#MARK: - TableView
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == newEpisodesTableView {
            return 40
        }
        if tableView == finishListeningTableView {
            return 40
        }
        if tableView == downloadTableView {
            return 40
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 35))
        let headerLabel = UILabel(frame: CGRect(x: 0, y: 6, width: 0, height: 35))
        headerLabel.font = UIFont.init(name: "SFProDisplay-Medium", size: 24)
        
        let viewAllButton = UIButton(frame: CGRect(x:view.frame.width - 100, y:8, width: 150, height: 30))
        viewAllButton.setTitle("View all...", for: .normal)
        viewAllButton.titleLabel?.font =  UIFont(name: "SFProDisplay-Semibold", size: 13)
 
        
        viewAllButton.setTitleColor(UIColor(red: 32.0/255.0, green: 124.0/255.0, blue: 231.0/255.0, alpha: 1.0), for: .normal)
        
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        
       
        headerLabel.text = "New Episodes"
        headerLabel.sizeToFit()
        view.addSubview(headerLabel)
        
        viewAllButton.tag = 1
        if episodes.count > 3{
            view.addSubview(viewAllButton)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == newEpisodesTableView {
            return self.episodes.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == newEpisodesTableView! {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdNewEpisode, for: indexPath) as! NewEpisodeCell
            if indexPath.row == 0{
                
                let separatorLine = UIImageView.init(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: 0.5))
                
                separatorLine.backgroundColor = tableView.separatorColor
                cell.contentView.addSubview(separatorLine)
            }
            cell.layoutMargins = UIEdgeInsets.zero
            
            let url = URL(string: episodes[indexPath.row].imageUrl?.toSecureHTTPS() ?? "")
            cell.thumbNail.sd_setImage(with: url)
            cell.title.text = self.episodes[indexPath.row].title
            cell.title.sizeToFit()
            cell.author.text = self.episodes[indexPath.row].author
            cell.author.sizeToFit()
            cell.pubdate.text =  formatter.string(from: self.episodes[indexPath.row].pubDate)
            cell.pubdate.sizeToFit()
            cell.stringURL = self.episodes[indexPath.row].streamUrl
            
            return cell
        }
        return UITableViewCell()
    }
}
