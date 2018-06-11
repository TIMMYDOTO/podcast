//
//  EpisodeCell.swift
//  Podcasts
//
//  Created by Ivan Amidžić on 28/02/2018.
//  Copyright © 2018 Ivan Amidžić. All rights reserved.
//

import UIKit

protocol ReadMoreEpisodeDelegate {
    func moreTapped(cell: EpisodeCell)
}

class EpisodeCell: UITableViewCell {
    var episode: Episode! {
        didSet {
            titleLabel.text = episode.title
            descriptionLabel.text = episode.description
            durationLabel.text = episode.duration?.asString(style: .abbreviated)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            pubDateLabel.text = dateFormatter.string(from: episode.pubDate)
            let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
            episodeImageView.sd_setImage(with: url)
        }
    }
    
    var delegate: ReadMoreEpisodeDelegate?
    var isExpanded: Bool = false
    
    
    @IBOutlet weak var downloadedImage: UIImageView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var pubDateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.numberOfLines = 2
        }
    }
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.numberOfLines = 2
        }
    }
    
    @IBAction func moreButtonTapped(_ sender: UIButton) {
            isExpanded = !isExpanded
            descriptionLabel.numberOfLines = isExpanded ? 0 : 2
            moreButton.setTitle(isExpanded ? "Read less" : "Read more", for: .normal)
            delegate?.moreTapped(cell: self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
