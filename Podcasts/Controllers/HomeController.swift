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
  

    let deletedTables = NSMutableArray()
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
   
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
       
        navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "Arrow-1")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "Arrow-1")

        
        collectionView.nameForCollectionView = "collectionView"
        newEpisodesTableView.nameForTable = "newEpisodesTableView"
        finishListeningTableView.nameForTable = "finishListeningTableView"
        downloadTableView.nameForTable = "downloadTableView"
        
        numberOfRows.add(collectionView)
        numberOfRows.add(newEpisodesTableView)
        numberOfRows.add(finishListeningTableView)
        numberOfRows.add(downloadTableView)
        formatter.dateFormat = "MMM d, yyyy"
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
    
    }

    func settingViews(){
     
        mainTableView.separatorStyle = .none
        mainTableView.allowsSelection = false
        collectionView.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.width, height: 230)
        
        newEpisodesTableView.frame = CGRect(x:17, y:10, width: UIScreen.main.bounds.width - 34, height: 210)

        newEpisodesTableView.isScrollEnabled = false
        newEpisodesTableView.delegate = self
    
        
        finishListeningTableView.frame = CGRect(x:17, y:0, width: UIScreen.main.bounds.width - 34, height: 230)
        
        finishListeningTableView.isScrollEnabled = false
        finishListeningTableView.delegate = self
        
        
        downloadTableView.frame = CGRect(x:17, y:0, width: UIScreen.main.bounds.width - 34, height: 230)

        downloadTableView.isScrollEnabled = false
        downloadTableView.delegate = self
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 35))

        let headerLabel = UILabel(frame: CGRect(x: 0, y: 6, width: 0, height: 35))
        headerLabel.font = UIFont.init(name: "Helvetica", size: 24)
  
        let viewAllButton = UIButton(frame: CGRect(x:view.frame.width - 100, y:8, width: 150, height: 30))
        viewAllButton.setTitle("View all...", for: .normal)
        viewAllButton.titleLabel?.font =  UIFont(name: "Helvetica", size: 13)
        viewAllButton.addTarget(self, action: #selector(viewAllController), for: .touchUpInside)
        viewAllButton.setTitleColor(UIColor(red: 32.0/255.0, green: 124.0/255.0, blue: 231.0/255.0, alpha: 1.0), for: .normal)

        if tableView == newEpisodesTableView{
            tableView.layoutMargins = UIEdgeInsets.zero
            tableView.separatorInset = UIEdgeInsets.zero
            headerLabel.text = "New Episodes"
            headerLabel.sizeToFit()
            view.addSubview(headerLabel)
            
            viewAllButton.tag = 1
            view.addSubview(viewAllButton)
     
        return view
    }
        if tableView == finishListeningTableView{
            tableView.layoutMargins = UIEdgeInsets.zero
            tableView.separatorInset = UIEdgeInsets.zero
            headerLabel.text = "Finish listening"
            headerLabel.sizeToFit()
            view.addSubview(headerLabel)
            
            viewAllButton.tag = 2
            view.addSubview(viewAllButton)
            return view
    }
        
        if tableView == downloadTableView{
            tableView.layoutMargins = UIEdgeInsets.zero
            tableView.separatorInset = UIEdgeInsets.zero
            headerLabel.text = "Downloaded"
            headerLabel.sizeToFit()
            view.addSubview(headerLabel)
            
            viewAllButton.tag = 2
            view.addSubview(viewAllButton)
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
    
        }else{
            collectionView.transform = CGAffineTransform(scaleX: 1, y: 1);
            newEpisodesTableView.transform = CGAffineTransform(scaleX: 1, y: 1);
            finishListeningTableView.transform = CGAffineTransform(scaleX: 1, y: 1);
            downloadTableView.transform = CGAffineTransform(scaleX: 1, y: 1);
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
            let deletedTable = numberOfRows[indexPath.row] as! TableViewWithName
            numberOfRows.removeObject(at: indexPath.row)
            
            deletedTables.add(deletedTable.nameForTable)
            
            
            tableView.deleteRows(at: [indexPath], with: .fade)
       
            UserDefaults.standard.set(deletedTables, forKey: "deletedTables")
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
            if(self.episodes.count > 0){
            return 3
            }else{
            return 0
            }
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
        if tableView == finishListeningTableView! {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdFinishListening, for: indexPath) as! FinishListening
            if indexPath.row == 0{
               
                let separatorLine = UIImageView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0.5))
                
                separatorLine.backgroundColor = tableView.separatorColor
                cell.contentView.addSubview(separatorLine)
            }
            cell.layoutMargins = UIEdgeInsets.zero
            cell.titleLabel.text = incompleteEpisodes[indexPath.row].title
            cell.titleLabel.sizeToFit()
            cell.definition.text = incompleteEpisodes[indexPath.row].description
            cell.definition.sizeToFit()
            cell.remainingTime.text = String(incompleteEpisodesTime[indexPath.row])
            cell.remainingTime.sizeToFit()
            let url = URL(string: incompleteEpisodes[indexPath.row].imageUrl?.toSecureHTTPS() ?? "")
      
            cell.thumbNail.sd_setImage(with: url, completed: nil)
            
            cell.stringURL = incompleteEpisodes[indexPath.row].streamUrl
            return cell
        }
        if tableView == downloadTableView! {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdDownloadCell, for: indexPath) as! DownloadCell
            if indexPath.row == 0{
                
                let separatorLine = UIImageView.init(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: 0.5))
                
                separatorLine.backgroundColor = tableView.separatorColor
                cell.contentView.addSubview(separatorLine)
            }
            cell.layoutMargins = UIEdgeInsets.zero
            let url = URL(string: downloadedEpisodes[indexPath.row].imageUrl?.toSecureHTTPS() ?? "")
            cell.thumbNailImgView.sd_setImage(with: url)
            cell.titleLabel.text = self.downloadedEpisodes[indexPath.row].title
            cell.titleLabel.sizeToFit()
            cell.authorLabel.text = self.downloadedEpisodes[indexPath.row].author
            cell.authorLabel.sizeToFit()
            cell.pubdateLabel.text =  formatter.string(from: self.downloadedEpisodes[indexPath.row].pubDate)
            cell.pubdateLabel.sizeToFit()
           
            
            return cell
        }
        let cell = UITableViewCell()
        if indexPath.row == 0{
            cell.addSubview(collectionView)
    
            collectionView.dataSource = self
            
        }else if(indexPath.row == 1){
            
            cell.addSubview(newEpisodesTableView)
          
            newEpisodesTableView.dataSource = self
        }else if(indexPath.row == 2){
            cell.addSubview(finishListeningTableView)
            
            finishListeningTableView.dataSource = self
        }
        else if(indexPath.row == 3){
            cell.addSubview(downloadTableView)
            
            downloadTableView.dataSource = self
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if mainTableView.isEditing {
            return
        }
       
        if tableView == newEpisodesTableView {
            let cell = tableView.cellForRow(at: indexPath) as! NewEpisodeCell
            if cell.playBtn.currentBackgroundImage == UIImage.init(named: "play-button-2"){
                cell.playBtn.setBackgroundImage(UIImage(named: "Pause button"), for: .normal)
                PlayerService.sharedIntance.play(episode: self.episodes[indexPath.row])
            }

            
        }
        if tableView == finishListeningTableView {
            let cell = tableView.cellForRow(at: indexPath) as! FinishListening
            cell.playBtn.setImage(#imageLiteral(resourceName: "PauseWhite"), for: .normal)
            PlayerService.sharedIntance.play(episode: self.incompleteEpisodes[indexPath.row])
        }
        if tableView == downloadTableView {
            let cell = tableView.cellForRow(at: indexPath) as! DownloadCell
            cell.playBtn.setImage(#imageLiteral(resourceName: "PauseWhite"), for: .normal)
            PlayerService.sharedIntance.play(episode: self.downloadedEpisodes[indexPath.row])
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
        if mainTableView.isEditing {
            return
        }
        let newEpisodeController = storyboard?.instantiateViewController(withIdentifier: "newEpisodeController") as! NewEpisodesController
        let podcast = self.podcasts[indexPath.row]
        newEpisodeController.podcast = podcast

        self.navigationController?.pushViewController(newEpisodeController, animated: true)
        
        
    }
    
}

