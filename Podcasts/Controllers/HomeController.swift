//
//  HomeController.swift
//  Podcasts
//
//  Created by Ivan Amidžić on 07/06/2018.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
class HomeController: VCWithPlayer, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    let noContentLabel = UILabel()
    var pageControl = UIPageControl()
    
    let collectinCellId = "collectinCellId"
    @IBOutlet var mainTableView: MainTableView!
    var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
    
    @IBOutlet var newEpisodesTableView: TableViewWithName!
    
    @IBOutlet var finishListeningTableView: TableViewWithName!
    
    @IBOutlet var downloadTableView: TableViewWithName!
    
    @IBOutlet var collectionView: CollectionViewWithName!
    var containerCollectionView = UIView()
    
    
    var deletedTablesMutable = NSMutableArray()
    let cellIdNewEpisode = "cellIdNewEpisode"
    var episodes = [Episode]()
    var podcasts = UserDefaults.standard.savedPodcasts()
    
    
    var incompleteEpisodes = UserDefaults.standard.inProgressEpisodes()
    var incompleteEpisodesTime = UserDefaults.standard.inProgressEpisodesTimes()
    let cellIdFinishListening = "cellIdFinishListening"
    
    let cellIdDownloadCell = "downloadCell"
    let formatter = DateFormatter()
    
    var numberOfRows = NSMutableArray()
    var plusBarItem: UIBarButtonItem!
    
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
        
        
        formatter.dateFormat = "MMM d, yyyy"
        
        
        setupNavigationBar()
        settingViews()
        
    }
    func getEpisodes(){
        let feedURLs = self.podcasts.compactMap { $0.feedUrl }
        print(feedURLs)
        var i = 0
        for url in feedURLs {
            i = i + 1
            if i == 6
            {
                break
            }
            APIService.shared.fetchEpisodes(feedUrl: url) { (episode, _) in
                
                self.episodes.append(contentsOf: episode)
                self.episodes.sort { $0.pubDate > $1.pubDate }
                DispatchQueue.main.async {
                    print("new request")
                    
                    self.newEpisodesTableView.reloadData()
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.isTranslucent = false
        
        incompleteEpisodes = UserDefaults.standard.inProgressEpisodes()
        
        incompleteEpisodesTime = UserDefaults.standard.inProgressEpisodesTimes()
        finishListeningTableView.reloadData()
        
        
        numberOfRows.removeAllObjects()
        numberOfRows.add(collectionView.nameForCollectionView)
        numberOfRows.add(newEpisodesTableView.nameForTable)
        if incompleteEpisodes.count > 0 {
            numberOfRows.add(finishListeningTableView.nameForTable)
        }
        let deletedTables = UserDefaults.standard.object(forKey: "deletedTables") as? NSArray ?? NSArray()
        deletedTablesMutable = deletedTables.mutableCopy() as! NSMutableArray
        for table in deletedTablesMutable {
            numberOfRows.remove(table)
        }
        podcasts = UserDefaults.standard.savedPodcasts()
        
        if numberOfRows.contains("newEpisodesTableView") {
            getEpisodes()
        }
        
        
        
        
        
        collectionView?.reloadData()
        
        
        downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
        if self.downloadedEpisodes.count > 0{
            
            
            downloadTableView.isScrollEnabled = false
            downloadTableView.delegate = self
            if !numberOfRows.contains(downloadTableView.nameForTable){
                
                numberOfRows.add(downloadTableView.nameForTable)
            }
            
            print("numberOfRows",numberOfRows)
            downloadTableView.reloadData()
            
        }
        if numberOfRows.count > 0{noContentLabel.removeFromSuperview()}
        mainTableView.reloadData()
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    func settingViews(){
        
        mainTableView.separatorStyle = .none
        mainTableView.allowsSelection = false
        
        containerCollectionView.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.width-10, height: 266)
        collectionView.frame = CGRect(x:0, y:0, width: containerCollectionView.frame.size.width, height: 244)
        
        pageControl.frame = CGRect(x: containerCollectionView.frame.width/2 - 19, y: 238, width: 39, height: 37)
        containerCollectionView.addSubview(collectionView)
        containerCollectionView.addSubview(pageControl)
        
        
        
        pageControl.currentPageIndicatorTintColor = UIColor(red: 9.0/255.0, green: 152.0/255.0, blue: 190.0/255.0, alpha: 1)
        pageControl.pageIndicatorTintColor = UIColor(red: 117.0/255.0, green: 117.0/255.0, blue: 117.0/255.0, alpha: 1)
        
        
        
        
        newEpisodesTableView.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.width - 19, height: 225)
        
        newEpisodesTableView.isScrollEnabled = false
        newEpisodesTableView.delegate = self
        
        
        finishListeningTableView.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.width - 19, height: 225)
        //        finishListeningTableView.backgroundColor = .green
        finishListeningTableView.isScrollEnabled = false
        finishListeningTableView.delegate = self
        
        
        downloadTableView.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.width - 19, height: 225)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 35))
        
        let headerLabel = UILabel(frame: CGRect(x: 17, y: 6, width: 0, height: 35))
        headerLabel.font = UIFont.init(name: "SFProDisplay-Medium", size: 24)
        
        let viewAllButton = UIButtonWitName(frame: CGRect(x:tableView.frame.width - 77, y:8, width: 0, height: 30))
        if mainTableView.isEditing {
            viewAllButton.frame = CGRect(x:tableView.frame.width + 25, y:8, width: 0, height: 30)
        }
        
        viewAllButton.setTitle("View all...", for: .normal)
        viewAllButton.sizeToFit()
        viewAllButton.contentHorizontalAlignment = .right
        viewAllButton.titleLabel?.font =  UIFont(name: "SFProDisplay-Semibold", size: 13)
        viewAllButton.addTarget(self, action: #selector(viewAllController), for: .touchUpInside)
        viewAllButton.setTitleColor(UIColor(red: 32.0/255.0, green: 124.0/255.0, blue: 231.0/255.0, alpha: 1.0), for: .normal)
        
        if tableView == newEpisodesTableView{
            viewAllButton.nameForButton = "newEpisodesTableView"
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
            viewAllButton.nameForButton = "finishListeningTableView"
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
            viewAllButton.nameForButton = "downloadTableView"
            headerLabel.text = "Downloads"
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
    
    @objc func viewAllController(sender: UIButtonWitName){
        if mainTableView.isEditing {
            return
        }
        let viewAllController = storyboard?.instantiateViewController(withIdentifier: "viewAllController") as! ViewAllController
        viewAllController.nameOfTable = sender.nameForButton
        self.navigationController?.pushViewController(viewAllController, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == mainTableView{
            return 0
        }
        else{ return 40 }
        
        
    }
    fileprivate func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "musica-searcher"), style: .plain, target: self, action: #selector(searchButtonPressed))
        
        plusBarItem = UIBarButtonItem(image:#imageLiteral(resourceName: "plus-symbol"), style: .plain, target: self, action: #selector(openAddToHomeScreen))
        plusBarItem.isEnabled = false
        
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
            plusBarItem.isEnabled = true
            containerCollectionView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7);
            newEpisodesTableView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7);
            finishListeningTableView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7);
            downloadTableView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7);
            
            newEpisodesTableView.allowsSelection = false
            collectionView.allowsSelection = false
            finishListeningTableView.allowsSelection = false
            downloadTableView.allowsSelection = false
            
        }else{
            plusBarItem.isEnabled = false
            containerCollectionView.transform = CGAffineTransform(scaleX: 1, y: 1);
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
            if !deletedTablesMutable.contains(deletedTable){
                deletedTablesMutable.add(deletedTable)
            }
            
            
            
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            if numberOfRows.count == 0{
                
                noContentLabel.text = "No content to show"
                noContentLabel.font = UIFont.init(name: "SFProDisplay-Light", size: 35)
                noContentLabel.sizeToFit()
                noContentLabel.center =  CGPoint(x: UIScreen.main.bounds.size.width*0.5,y: UIScreen.main.bounds.size.height*0.4)
                noContentLabel.textColor = UIColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 1)
                
                mainTableView.addSubview(noContentLabel)
            }
            print("deleted tables:", deletedTablesMutable)
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
            
            return 260
        }
        
        return 63
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
        
        return numberOfRows.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == newEpisodesTableView! {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdNewEpisode, for: indexPath) as! NewEpisodeCell
            if indexPath.row == 0{
                
                let separatorLine = UIImageView.init(frame: CGRect(x: 19, y: 0, width: UIScreen.main.bounds.size.width-19, height: 0.5))
                
                separatorLine.backgroundColor = tableView.separatorColor
                cell.contentView.addSubview(separatorLine)
            }
            cell.layoutMargins = UIEdgeInsets.zero
            
            cell.shadowView.layer.shadowColor = UIColor.black.cgColor
            cell.shadowView.layer.shadowOpacity = 1
            cell.shadowView.layer.shadowOffset = CGSize.zero
            cell.shadowView.layer.shadowRadius = 3
            cell.shadowView.layer.shadowPath = UIBezierPath(roundedRect: cell.shadowView.bounds, cornerRadius: 10).cgPath
            
            
            
            if episodes[indexPath.row].imageUrl != nil{
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
                cell.playBtn.tag = indexPath.row
                cell.playBtn.addTarget(self, action: #selector(playButtonClicked), for: .touchUpInside)
            }
            return cell
        }
        if tableView == finishListeningTableView! {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdFinishListening, for: indexPath) as! FinishListening
            if indexPath.row == 0{
                
                let separatorLine = UIImageView.init(frame: CGRect(x: 19, y: 0, width: UIScreen.main.bounds.size.width-19, height: 0.5))
                
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
            
            
            cell.definition.text = self.incompleteEpisodes[indexPath.row].author
            //            cell.definition.sizeToFit()
            //            cell.definition.text = incompleteEpisodes[indexPath.row].description
            //            cell.definition.sizeToFit()
            
            let time = self.incompleteEpisodesTime[indexPath.row]
            print("row:", indexPath.row, time)
            if let fullTime = self.incompleteEpisodes[indexPath.row].duration {
                let timeRemaining = fullTime - time
                cell.remainingTime.text = timeRemaining.asString(style: .abbreviated) + " remaining"
                cell.remainingTime.textAlignment = .right
            }
            
            
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
                
                let separatorLine = UIImageView.init(frame: CGRect(x: 19, y: 0, width: UIScreen.main.bounds.size.width-19, height: 0.5))
                
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
            cell.pubdateLabel.textAlignment = .right
            cell.playBtn.tag = indexPath.row
            cell.playBtn.addTarget(self, action: #selector(playButtonClicked), for: .touchUpInside)
            
            return cell
        }
        let cell = UITableViewCell()
        if (numberOfRows[indexPath.row] as! String ) == "collectionView"{
            containerCollectionView.tag = 1
            cell.addSubview(containerCollectionView)
            
            collectionView.dataSource = self
            return cell
        }
        else if (numberOfRows[indexPath.row] as! String ) == "newEpisodesTableView"{
            cell.addSubview(newEpisodesTableView)
            self.newEpisodesTableView.dataSource = self
            return cell
        }
        else if (numberOfRows[indexPath.row] as! String ) == "finishListeningTableView"{
            cell.addSubview(finishListeningTableView)
            finishListeningTableView.dataSource = self
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
            return
        }
        if tableView == finishListeningTableView {
            
            chapterController.episode = incompleteEpisodes[indexPath.row]
            chapterController.shouldPlay = false
            self.navigationController?.pushViewController(chapterController, animated: true)
            return
        }
        if tableView == downloadTableView {
            chapterController.episode = downloadedEpisodes[indexPath.row]
            chapterController.shouldPlay = false
            self.navigationController?.pushViewController(chapterController, animated: true)
            return
        }
    }
    //MARK: - Collection view
    
    var currentPage = 0
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        self.currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        self.pageControl.currentPage = self.currentPage
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.hidesForSinglePage = true
        let numberOfPages = Float(self.podcasts.count) / 6.0
        
        pageControl.numberOfPages = Int(numberOfPages.rounded(.up))
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

