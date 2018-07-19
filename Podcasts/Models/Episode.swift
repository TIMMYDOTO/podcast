//
//  Episode.swift
//  Podcasts
//
//  Created by Ivan Amidžić on 28/02/2018.
//  Copyright © 2018 Ivan Amidžić. All rights reserved.
//

import Foundation
import FeedKit


struct Episode: Codable {
 
    
    let title: String
    let pubDate: Date
    let description: String
    var imageUrl: String?
    var fileUrl: String?
    let author: String
    let streamUrl: String
    let duration: Double?
    
    var podcast:Podcast?
  
    init(feedItem: RSSFeedItem) {
  
        self.streamUrl = feedItem.enclosure?.attributes?.url ?? ""
        self.title = feedItem.title ?? ""
        self.pubDate = feedItem.pubDate ?? Date()
        self.description = feedItem.iTunes?.iTunesSubtitle ?? feedItem.description ?? ""
        self.author = feedItem.iTunes?.iTunesAuthor ?? ""
        self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
        self.duration = feedItem.iTunes?.iTunesDuration
      
       
    }

    
}

