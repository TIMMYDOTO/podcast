//
//  VewAllCell.swift
//  Podcasts
//
//  Created by Artyom Schiopu on 7/20/18.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit

class VewAllCell: UITableViewCell {

    @IBOutlet weak var episodeImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var pubdateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("awakeFromNib")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
print("setSelected")
        // Configure the view for the selected state
    }

}
