//
//  Episodes.swift
//  Podcasts
//
//  Created by Boris Esanu on 7/11/18.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit

class EpisodCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var duration: UILabel!
    
    @IBOutlet weak var dateAndDuration: UILabel!

    var streamUrl: String!

    @IBOutlet var playButton: UIButton!
    
    var podcast:Podcast?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
}
