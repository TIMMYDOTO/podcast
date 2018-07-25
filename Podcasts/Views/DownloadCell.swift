//
//  DownloadCell.swift
//  Podcasts
//
//  Created by Artyom Schiopu on 7/23/18.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit

class DownloadCell: UITableViewCell {
    @IBOutlet var thumbNailImgView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var pubdateLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var playBtn: UIButton!
    @IBOutlet var shadowView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
