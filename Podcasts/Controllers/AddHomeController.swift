//
//  AddHomeController.swift
//  Podcasts
//
//  Created by Boris Esanu on 7/22/18.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit

class AddHomeController: VCWithPlayer, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    
    let collectinCellId = "collectinCellId"
    let cellIdNewEpisode = "cellIdNewEpisode"
    let cellIdFinishListening = "cellIdFinishListening"
    let cellIdDownloadCell = "cellIdDownloadCell"
    
    var podcasts = UserDefaults.standard.savedPodcasts()
    var episodes = [Episode]()
    var incompleteEpisodes = UserDefaults.standard.inProgressEpisodes()
    var incompleteEpisodesTime = UserDefaults.standard.inProgressEpisodesTimes()
    var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
    
    @IBOutlet var favoritesCollectionView: UICollectionView!
    @IBOutlet var newEpisodesTableView: UITableView!
    @IBOutlet var finishListeningTableView: UITableView!
    @IBOutlet weak var downloadTableView: UITableView!
    
    let formatter = DateFormatter()
    
    var deletedTables = [String]()
    var yPosition = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.subviews.forEach({ $0.removeFromSuperview() })
        yPosition = 0.0
        let rightItem = UIBarButtonItem(title: "Add to Home", style: .plain, target: self, action: nil)
        rightItem.tintColor = UIColor(red: 17.0/255.0, green: 116.0/255.0, blue: 232.0/255.0, alpha: 1)
        
        rightItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "SFProDisplay-Semibold", size: 18)!], for: .normal)
        navigationItem.rightBarButtonItem = rightItem
        
    
        
         formatter.dateFormat = "MMM d, yyyy"
        if (UserDefaults.standard.object(forKey: "deletedTables") != nil) {
             deletedTables = UserDefaults.standard.object(forKey: "deletedTables") as! [String]
        }

      
        if deletedTables.count > 0 {
            for table in deletedTables {
            
            if table == "collectionView"{
                favoritesCollectionView.frame = CGRect(x:29,y: yPosition, width: view.frame.width-61, height: 230)
                scrollView.addSubview(favoritesCollectionView)
                
                let plusButton = UIButtonWitName(frame: CGRect(x:0, y:12.7, width: 16, height: 16))
                plusButton.setBackgroundImage(#imageLiteral(resourceName: "plus-symbol"), for: .normal)
                plusButton.addTarget(self, action: #selector(plusButtonClicked), for: .touchUpInside)
                plusButton.nameForButton = "collectionView"
                favoritesCollectionView.addSubview(plusButton)

     
                
                yPosition = yPosition + favoritesCollectionView.frame.height+100
                favoritesCollectionView.dataSource = self
                favoritesCollectionView.delegate = self
            }
            else if table == "newEpisodesTableView"{
                
                var i = 0
               
                let feedURLs = podcasts.compactMap { $0.feedUrl }
                print(feedURLs)
                for url in feedURLs {
                    i = i + 1
                    if i == 4
                    {
                        break
                    }
                    APIService.shared.fetchEpisodes(feedUrl: url) { (episode, _) in
                        self.episodes.append(contentsOf: episode)
                        self.episodes.sort { $0.pubDate > $1.pubDate }
                        DispatchQueue.main.async {
                            self.newEpisodesTableView.reloadData()
                        }
                    }
                }
                
                newEpisodesTableView.frame = CGRect(x:29,y: yPosition, width: 300, height: 202)
              
                newEpisodesTableView.allowsSelection = false
                newEpisodesTableView.isScrollEnabled = false
                
                scrollView.addSubview(newEpisodesTableView)
                yPosition = yPosition + newEpisodesTableView.frame.height + 100
                newEpisodesTableView.dataSource = self
                newEpisodesTableView.delegate = self
                

        let createPlaylist = UIButton(frame: CGRect(x:100, y:newEpisodesTableView.frame.origin.y + newEpisodesTableView.frame.size.height + 40, width: 164, height: 36))
                createPlaylist.setBackgroundImage(#imageLiteral(resourceName: "CreatePlaylist"), for: .normal)
                scrollView.addSubview(createPlaylist)
            }
            else if table == "finishListeningTableView"{
                finishListeningTableView.frame = CGRect(x:29,y: yPosition, width: 300, height: 202)
                scrollView.addSubview(finishListeningTableView)
                
                let createPlaylist = UIButton(frame: CGRect(x:100, y:finishListeningTableView.frame.origin.y + finishListeningTableView.frame.size.height + 40, width: 164, height: 36))
                createPlaylist.setBackgroundImage(#imageLiteral(resourceName: "CreatePlaylist"), for: .normal)
                scrollView.addSubview(createPlaylist)
                
                
                finishListeningTableView.allowsSelection = false
                finishListeningTableView.isScrollEnabled = false
                
                yPosition = yPosition + finishListeningTableView.frame.height+100
                finishListeningTableView.dataSource = self
                finishListeningTableView.delegate = self
                
           
                
            }
            else{
                downloadTableView.frame = CGRect(x:29,y: yPosition, width: 300, height: 202)
                scrollView.addSubview(downloadTableView)
                 let createPlaylist = UIButton(frame: CGRect(x:100, y:downloadTableView.frame.origin.y + downloadTableView.frame.size.height + 40, width: 164, height: 36))
                createPlaylist.setBackgroundImage(#imageLiteral(resourceName: "CreatePlaylist"), for: .normal)
                scrollView.addSubview(createPlaylist)
                downloadTableView.allowsSelection = false
                downloadTableView.isScrollEnabled = false
                yPosition = yPosition + downloadTableView.frame.height + 100
                downloadTableView.dataSource = self
                downloadTableView.delegate = self
            }
        }
        
    }
}
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollView.contentSize = CGSize(width:self.view.frame.size.width, height: yPosition + 200)
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

     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
     return 54
    }

    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
          return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 35))
        let headerLabel = UILabel(frame: CGRect(x: 23, y: 6, width: 0, height: 35))
        headerLabel.font = UIFont.init(name: "SFProDisplay-Medium", size: 24)

        
     
        let plusButton = UIButtonWitName(frame: CGRect(x:0, y:12.7, width: 16, height: 16))
        plusButton.setBackgroundImage(#imageLiteral(resourceName: "plus-symbol"), for: .normal)
        plusButton.addTarget(self, action: #selector(plusButtonClicked), for: .touchUpInside)
        view.addSubview(plusButton)
       
        if tableView == newEpisodesTableView {
            headerLabel.text = "New Episodes"
            plusButton.nameForButton = "newEpisodesTableView"
            headerLabel.sizeToFit()
            plusButton.tag = 0
         
        }
        if tableView == finishListeningTableView {
            headerLabel.text = "Finish Listening"
            plusButton.nameForButton = "finishListeningTableView"
            headerLabel.sizeToFit()
            plusButton.tag = 1
        }
        if tableView == downloadTableView {
            headerLabel.text = "Downloads"
            plusButton.nameForButton = "downloadTableView"
            headerLabel.sizeToFit()
            plusButton.tag = 2
        }
        
        let viewAllButton = UIButton(frame: CGRect(x:tableView.frame.width - 100, y:8, width: 150, height: 30))
        viewAllButton.setTitle("View all...", for: .normal)
        viewAllButton.titleLabel?.font =  UIFont(name: "SFProDisplay-Semibold", size: 13)
 
        
        viewAllButton.setTitleColor(UIColor(red: 32.0/255.0, green: 124.0/255.0, blue: 231.0/255.0, alpha: 1.0), for: .normal)
        
        
       
     
        view.addSubview(headerLabel)
        
  
        if episodes.count > 3{
            view.addSubview(viewAllButton)
        }
    
        if incompleteEpisodes.count > 3{
            view.addSubview(viewAllButton)
        }
     
        if downloadedEpisodes.count > 3{
            view.addSubview(viewAllButton)
        }
        return view
    }
    
    @objc func plusButtonClicked(sender: UIButtonWitName){

     deletedTables = deletedTables.filter{$0 != sender.nameForButton}
     UserDefaults.standard.set(deletedTables, forKey: "deletedTables")
   
        viewDidLoad()
        viewWillAppear(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == newEpisodesTableView {
            if(self.episodes.count > 2){
                return 3
            }else{
                return self.episodes.count
            }
        }
        if tableView == finishListeningTableView {
            if(self.incompleteEpisodes.count > 2){
                return 3
            }else{
                return self.incompleteEpisodes.count
            }
        }
        if tableView == downloadTableView {
            if(self.downloadedEpisodes.count > 2){
                return 3
            }else{
                return self.downloadedEpisodes.count
            }
        }
        return 3
}
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == newEpisodesTableView! {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdNewEpisode, for: indexPath) as! NewEpisodeCell
            if indexPath.row == 0{
                
                let separatorLine = UIImageView.init(frame: CGRect(x: 22, y: 0, width: cell.frame.width, height: 0.75))
                
                separatorLine.backgroundColor = tableView.separatorColor
                cell.contentView.addSubview(separatorLine)
            }

            cell.shadowView.layer.shadowColor = UIColor.black.cgColor
            cell.shadowView.layer.shadowOpacity = 1
            cell.shadowView.layer.shadowOffset = CGSize.zero
            cell.shadowView.layer.shadowRadius = 3
            cell.shadowView.layer.shadowPath = UIBezierPath(roundedRect: cell.shadowView.bounds, cornerRadius: 9).cgPath
            
            let url = URL(string: episodes[indexPath.row].imageUrl?.toSecureHTTPS() ?? "")
            cell.thumbNail.sd_setImage(with: url)
            cell.thumbNail.frame =  cell.shadowView.bounds
            cell.thumbNail.clipsToBounds = true
            cell.thumbNail.layer.cornerRadius = 10
            cell.shadowView.addSubview(cell.thumbNail)
            cell.title.text = self.episodes[indexPath.row].title
            
            cell.author.text = self.episodes[indexPath.row].author
        
            cell.pubdate.text =  formatter.string(from: self.episodes[indexPath.row].pubDate)
      
            cell.stringURL = self.episodes[indexPath.row].streamUrl
       
            return cell
        }
        if tableView == finishListeningTableView! {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdFinishListening, for: indexPath) as! FinishListening
            if indexPath.row == 0{
                
                let separatorLine = UIImageView.init(frame: CGRect(x: 19, y: 0, width: tableView.frame.size.width, height: 0.5))
                
                separatorLine.backgroundColor = tableView.separatorColor
                cell.contentView.addSubview(separatorLine)
            }
            
            cell.layoutMargins = UIEdgeInsets.zero
            
            cell.shadowView.layer.shadowColor = UIColor.black.cgColor
            cell.shadowView.layer.shadowOpacity = 1
            cell.shadowView.layer.shadowOffset = CGSize.zero
            cell.shadowView.layer.shadowRadius = 3
            cell.shadowView.layer.shadowPath = UIBezierPath(roundedRect: cell.shadowView.bounds, cornerRadius: 10).cgPath
            
            cell.titleLabel.text = incompleteEpisodes[indexPath.row].title
           
            cell.definition.text = incompleteEpisodes[indexPath.row].description
            
            let time = self.incompleteEpisodesTime[indexPath.row]

            
            if let fullTime = self.incompleteEpisodes[indexPath.row].duration {
                let timeRemaining = fullTime - time
                cell.remainingTime.text = timeRemaining.asString(style: .abbreviated) + " remaining"
                
            }
         
       
            let url = URL(string: incompleteEpisodes[indexPath.row].imageUrl?.toSecureHTTPS() ?? "")
            
            cell.thumbNail.sd_setImage(with: url, completed: nil)
            cell.thumbNail.clipsToBounds = true
            cell.thumbNail.layer.cornerRadius = 10
            cell.shadowView.addSubview(cell.thumbNail)
            cell.stringURL = incompleteEpisodes[indexPath.row].streamUrl
            cell.playBtn.tag = indexPath.row
       
            return cell
        }
        if tableView == downloadTableView! {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdDownloadCell, for: indexPath) as! DownloadCell
            if indexPath.row == 0{
                
                let separatorLine = UIImageView.init(frame: CGRect(x: 19, y: 0, width: tableView.frame.width, height: 0.5))
                
                separatorLine.backgroundColor = tableView.separatorColor
                cell.contentView.addSubview(separatorLine)
            }
            cell.layoutMargins = UIEdgeInsets.zero
            
            cell.shadowView.layer.shadowColor = UIColor.black.cgColor
            cell.shadowView.layer.shadowOpacity = 1
            cell.shadowView.layer.shadowOffset = CGSize.zero
            cell.shadowView.layer.shadowRadius = 3
            cell.shadowView.layer.shadowPath = UIBezierPath(roundedRect: cell.shadowView.bounds, cornerRadius: 10).cgPath
            
            let url = URL(string: downloadedEpisodes[indexPath.row].imageUrl?.toSecureHTTPS() ?? "")
            cell.thumbNailImgView.sd_setImage(with: url)
            cell.thumbNailImgView.frame =  cell.shadowView.bounds
            cell.thumbNailImgView.clipsToBounds = true
            cell.thumbNailImgView.layer.cornerRadius = 10
            cell.shadowView.addSubview(cell.thumbNailImgView)
            
            
            cell.titleLabel.text = self.downloadedEpisodes[indexPath.row].title

            cell.authorLabel.text = self.downloadedEpisodes[indexPath.row].author
 
            cell.pubdateLabel.text = formatter.string(from: self.downloadedEpisodes[indexPath.row].pubDate)
   
            
            cell.playBtn.tag = indexPath.row
        
            
            return cell
        }

        return UITableViewCell()
    }
}
