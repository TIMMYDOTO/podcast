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
   
    
    let collectinCellId = "collectinCellId"
    @IBOutlet var mainTableView: MainTableView!
   var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
    
    @IBOutlet var newEpisodesTableView: TableViewWithName!
    
    @IBOutlet var finishListeningTableView: TableViewWithName!
    
    @IBOutlet var downloadTableView: TableViewWithName!
    var pageControl = UIPageControl()
  

    var deletedTablesMutable = NSMutableArray()
    let cellIdNewEpisode = "cellIdNewEpisode"
    var episodes = [Episode]()
    var podcasts = UserDefaults.standard.savedPodcasts()
    
    var incompleteEpisodes = [Episode]()
    var incompleteEpisodesTime = [Double]()
    let cellIdFinishListening = "cellIdFinishListening"
    
    let cellIdDownloadCell = "downloadCell"
    let formatter = DateFormatter()
    
    var numberOfRows = NSMutableArray()
   
    @IBOutlet var collectionView: CollectionViewWithName!
    override func viewDidLoad() {
        super.viewDidLoad()
        let deletedTables = UserDefaults.standard.object(forKey: "deletedTables") as? NSArray ?? NSArray()
        deletedTablesMutable = deletedTables.mutableCopy() as! NSMutableArray

        
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
       
        navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "Arrow-1")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "Arrow-1")

        
        collectionView.nameForCollectionView = "collectionView"
        newEpisodesTableView.nameForTable = "newEpisodesTableView"
        finishListeningTableView.nameForTable = "finishListeningTableView"
        downloadTableView.nameForTable = "downloadTableView"
        
        numberOfRows.add(collectionView.nameForCollectionView)
        numberOfRows.add(newEpisodesTableView.nameForTable)
        numberOfRows.add(finishListeningTableView.nameForTable)
         if self.downloadedEpisodes.count > 0{
        numberOfRows.add(downloadTableView.nameForTable)
         }
        for table in deletedTablesMutable {
             numberOfRows.remove(table)
        }
       
        formatter.dateFormat = "MMM d, yyyy"
       

        setupNavigationBar()
        settingViews()
     pageControl.numberOfPages = 3
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.isTranslucent = false
        
        podcasts = UserDefaults.standard.savedPodcasts()
        collectionView?.reloadData()
     
        incompleteEpisodes = UserDefaults.standard.inProgressEpisodes()
        
        incompleteEpisodesTime = UserDefaults.standard.inProgressEpisodesTimes()
        
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
        
        mainTableView.reloadData()
    
    }

    func settingViews(){
     
        mainTableView.separatorStyle = .none
        mainTableView.allowsSelection = false
        collectionView.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.width, height: 230)
        
        newEpisodesTableView.frame = CGRect(x:0, y:10, width: UIScreen.main.bounds.width - 19, height: 202)

        newEpisodesTableView.isScrollEnabled = false
        newEpisodesTableView.delegate = self
    
        
        finishListeningTableView.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.width - 19, height: 202)
        
        finishListeningTableView.isScrollEnabled = false
        finishListeningTableView.delegate = self
        
        
        downloadTableView.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.width - 19, height: 202)

        downloadTableView.isScrollEnabled = false
        downloadTableView.delegate = self
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 35))
       
        let headerLabel = UILabel(frame: CGRect(x: 17, y: 6, width: 0, height: 35))
        headerLabel.font = UIFont.init(name: "SFProDisplay-Medium", size: 24)
  
        let viewAllButton = UIButton(frame: CGRect(x:view.frame.width - 100, y:8, width: 150, height: 30))
        viewAllButton.setTitle("View all...", for: .normal)
        viewAllButton.titleLabel?.font =  UIFont(name: "SFProDisplay-Semibold", size: 13)
        viewAllButton.addTarget(self, action: #selector(viewAllController), for: .touchUpInside)
        viewAllButton.setTitleColor(UIColor(red: 32.0/255.0, green: 124.0/255.0, blue: 231.0/255.0, alpha: 1.0), for: .normal)

        if tableView == newEpisodesTableView{
           
            headerLabel.text = "New Episodes"
            headerLabel.sizeToFit()
            view.addSubview(headerLabel)
            
            viewAllButton.tag = 1
            if episodes.count > 3{
            view.addSubview(viewAllButton)
            }
        return view
    }
        if tableView == finishListeningTableView{
  
            headerLabel.text = "Finish listening"
            headerLabel.sizeToFit()
            view.addSubview(headerLabel)
            
            viewAllButton.tag = 2
            if incompleteEpisodes.count > 3{
            view.addSubview(viewAllButton)
            }
            return view
    }
        
        if tableView == downloadTableView{
            headerLabel.text = "Downloaded"
            headerLabel.sizeToFit()
            view.addSubview(headerLabel)
            
            viewAllButton.tag = 2
            if downloadedEpisodes.count > 3{
            view.addSubview(viewAllButton)
            }
            return view
        }
        return nil
    }

    @objc func viewAllController(){
        if mainTableView.isEditing {
            return
        }
        let viewAllController = storyboard?.instantiateViewController(withIdentifier: "viewAllController") as! ViewAllController
     
        self.navigationController?.pushViewController(viewAllController, animated: true)
    }
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
    fileprivate func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "musica-searcher"), style: .plain, target: self, action: #selector(searchButtonPressed))

        let plusBarItem = UIBarButtonItem(image:#imageLiteral(resourceName: "plus-symbol"), style: .plain, target: self, action: #selector(openAddToHomeScreen))
        let optionsBarItem = UIBarButtonItem(image:#imageLiteral(resourceName: "Setting_icon"), style: .plain, target: self, action: #selector(optionButtonPressed))
        navigationItem.setRightBarButtonItems([optionsBarItem, plusBarItem], animated: true)

        navigationItem.titleView = UIImageView.init(image: #imageLiteral(resourceName: "icon t2"))
        
    }
    @objc fileprivate func openAddToHomeScreen(){
        let addHomeController = storyboard?.instantiateViewController(withIdentifier: "addHomeController") as! AddHomeController
        navigationController?.pushViewController(addHomeController, animated: true)

    }
    @objc fileprivate func searchButtonPressed() {
        navigationController?.pushViewController(PodcastsSearchController(), animated: true)
    }
    @objc fileprivate func optionButtonPressed(){

       mainTableView.isEditing = !mainTableView.isEditing
        if mainTableView.isEditing {
          
            collectionView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7);
            newEpisodesTableView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7);
            finishListeningTableView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7);
            downloadTableView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7);
         
            newEpisodesTableView.allowsSelection = false
            collectionView.allowsSelection = false
            finishListeningTableView.allowsSelection = false
            downloadTableView.allowsSelection = false
    
        }else{
            collectionView.transform = CGAffineTransform(scaleX: 1, y: 1);
            newEpisodesTableView.transform = CGAffineTransform(scaleX: 1, y: 1);
            finishListeningTableView.transform = CGAffineTransform(scaleX: 1, y: 1);
            downloadTableView.transform = CGAffineTransform(scaleX: 1, y: 1);
            
            collectionView.allowsSelection = true
            newEpisodesTableView.allowsSelection = true
            finishListeningTableView.allowsSelection = true
            downloadTableView.allowsSelection = true
        }
       
        
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
    
    //MARK: - TableView
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if tableView == mainTableView {
            let deletedTable = numberOfRows[indexPath.row]
            numberOfRows.removeObject(at: indexPath.row)
            
            deletedTablesMutable.add(deletedTable)
            
            
            tableView.deleteRows(at: [indexPath], with: .fade)
       
            UserDefaults.standard.set(deletedTablesMutable, forKey: "deletedTables")
        }
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if tableView.isEditing {
           
     
            
            return .delete
        }
        
        return .none
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == mainTableView {
            return 250
        }
        return tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == newEpisodesTableView {
            return self.episodes.count
//            if(self.episodes.count > 0){
//            return 3
//            }else{
//            return 0
//            }
        }
        if tableView == finishListeningTableView {
            if(self.incompleteEpisodes.count > 0){
                return 3
            }else{
                return 0
            }
        }
        if tableView == downloadTableView {
           
            return self.downloadedEpisodes.count
//            if(self.downloadedEpisodes.count > 0){
//                return 3
//            }else{
//                return 0
//            }
        }
  
        return numberOfRows.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if tableView == newEpisodesTableView! {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdNewEpisode, for: indexPath) as! NewEpisodeCell
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
            
            let url = URL(string: episodes[indexPath.row].imageUrl?.toSecureHTTPS() ?? "")
            cell.thumbNail.sd_setImage(with: url)
            
            cell.thumbNail.frame =  cell.shadowView.bounds
            cell.thumbNail.clipsToBounds = true
            cell.thumbNail.layer.cornerRadius = 10
            cell.shadowView.addSubview(cell.thumbNail)
            
            cell.title.text = self.episodes[indexPath.row].title
            cell.title.sizeToFit()
            cell.author.text = self.episodes[indexPath.row].author
             cell.author.sizeToFit()
            cell.pubdate.text =  formatter.string(from: self.episodes[indexPath.row].pubDate)
            cell.pubdate.sizeToFit()
            cell.stringURL = self.episodes[indexPath.row].streamUrl
        cell.playBtn.tag = indexPath.row
              cell.playBtn.addTarget(self, action: #selector(playButtonClicked), for: .touchUpInside)
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
            cell.titleLabel.sizeToFit()
            cell.definition.text = incompleteEpisodes[indexPath.row].description
            cell.definition.sizeToFit()
            cell.remainingTime.text = String(incompleteEpisodesTime[indexPath.row])
            cell.remainingTime.sizeToFit()
            let url = URL(string: incompleteEpisodes[indexPath.row].imageUrl?.toSecureHTTPS() ?? "")
      
            cell.thumbNail.sd_setImage(with: url, completed: nil)
             cell.thumbNail.clipsToBounds = true
            cell.thumbNail.layer.cornerRadius = 10
              cell.shadowView.addSubview(cell.thumbNail)
            cell.stringURL = incompleteEpisodes[indexPath.row].streamUrl
            cell.playBtn.tag = indexPath.row
              cell.playBtn.addTarget(self, action: #selector(playButtonClicked), for: .touchUpInside)
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
            cell.titleLabel.sizeToFit()
            cell.authorLabel.text = self.downloadedEpisodes[indexPath.row].author
            cell.authorLabel.sizeToFit()
            cell.pubdateLabel.text = formatter.string(from: self.downloadedEpisodes[indexPath.row].pubDate)
            cell.pubdateLabel.sizeToFit()
           
            cell.playBtn.tag = indexPath.row
            cell.playBtn.addTarget(self, action: #selector(playButtonClicked), for: .touchUpInside)
        
            return cell
        }
        let cell = UITableViewCell()
        if (numberOfRows[indexPath.row] as! String ) == "collectionView"{
              cell.addSubview(collectionView)
              collectionView.dataSource = self
             return cell
        }
        else if (numberOfRows[indexPath.row] as! String ) == "newEpisodesTableView"{
            cell.addSubview(newEpisodesTableView)
            newEpisodesTableView.dataSource = self
            return cell
        }
        else if (numberOfRows[indexPath.row] as! String ) == "finishListeningTableView"{
            cell.addSubview(finishListeningTableView)
            collectionView.dataSource = self
            return cell
        }
      else {
            cell.addSubview(downloadTableView)
            downloadTableView.dataSource = self
            return cell
        }

    }
    @objc func playButtonClicked(sender: UIButton){
        print("playButtonClicked", sender.tag)
        let chapterController = storyboard?.instantiateViewController(withIdentifier: "ChapterController") as! ChapterController
//        chapterController.podcastName = titleLabel.text
        chapterController.episode = episodes[sender.tag]//remake
        chapterController.shouldPlay = true
        self.navigationController?.pushViewController(chapterController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if mainTableView.isEditing {
            return
        }
              let chapterController = storyboard?.instantiateViewController(withIdentifier: "ChapterController") as! ChapterController
        if tableView == newEpisodesTableView {
           
     
//            chapterController.podcastName = titleLabel.text
            chapterController.episode = episodes[indexPath.row]
            chapterController.shouldPlay = false
            self.navigationController?.pushViewController(chapterController, animated: true)
            
        }
        if tableView == finishListeningTableView {
       
            chapterController.episode = incompleteEpisodes[indexPath.row]
            chapterController.shouldPlay = false
            self.navigationController?.pushViewController(chapterController, animated: true)
        
        }
        if tableView == downloadTableView {
            chapterController.episode = incompleteEpisodes[indexPath.row]
            chapterController.shouldPlay = false
            self.navigationController?.pushViewController(chapterController, animated: true)
         
        }
    }
    //MARK: - Collection view
    
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     
        let newEpisodeController = storyboard?.instantiateViewController(withIdentifier: "newEpisodeController") as! NewEpisodesController
        let podcast = self.podcasts[indexPath.row]
        newEpisodeController.podcast = podcast

        self.navigationController?.pushViewController(newEpisodeController, animated: true)
        
        
    }
    
}

