//
//  MainCell.swift
//  Podcasts
//
//  Created by Artyom Schiopu on 7/4/18.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit

class MainCell: UITableViewCell {

    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var newEpisodesTableView: UITableView!
    
    @IBOutlet var finishListening: UITableView!
   
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
   


    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
       
        
        // Configure the view for the selected state
    }


}
