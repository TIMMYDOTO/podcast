//
//  NewEpisodeCell.swift
//  Podcasts
//
//  Created by Artyom Schiopu on 7/2/18.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit

class NewEpisodeCell: UITableViewCell {

    @IBOutlet var thumbNail: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var pubdate: UILabel!
    @IBOutlet var author: UILabel!
    @IBOutlet var playBtn: UIButton!
    @IBOutlet var shadowView: UIView!
    var stringURL = String()
    
    
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
