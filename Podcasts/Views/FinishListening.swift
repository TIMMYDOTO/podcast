//
//  FinishListening.swift
//  Podcasts
//
//  Created by Artyom Schiopu on 7/9/18.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit

class FinishListening: UITableViewCell {

    
    @IBOutlet var definition: UILabel!
    @IBOutlet var remainingTime: UILabel!
    @IBOutlet var thumbNail: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var playBtn: UIButton!
    
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
