//
//  ChapterCell.swift
//  Podcasts
//
//  Created by Artyom Schiopu on 7/20/18.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit

class ChapterCell: UITableViewCell {

    @IBOutlet weak var chapterNameLabel: UILabel!
    
    @IBOutlet weak var chapterStartTimeLabel: UILabel!
    
    @IBOutlet weak var chapterStartButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  

}
