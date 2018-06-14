//
//  UserDefaults.swift
//  Podcasts
//
//  Created by Ivan Amidžić on 18/03/2018.
//  Copyright © 2018 Ivan Amidžić. All rights reserved.
//

import Foundation
import AVFoundation

extension UserDefaults {
    
    static let favoritedPodcastKey = "favoritedPodcastKey"
    static let downloadEpisodesKey = "downloadEpisodesKey"
    static let inProgressEpisodeKey = "inProgressEpisodeKey"
    static let inProgressEpisodeTimeKey = "inProgressEpisodeTimeKey"
    
    
    
    
        func inProgressEpisodeTime(time: Double) {
                var currentTime = inProgressEpisodesTimes()
                currentTime.insert(time, at: 0)
                UserDefaults.standard.set(currentTime, forKey: UserDefaults.inProgressEpisodeTimeKey)
        }
    
    
    func inProgressEpisodesTimes() -> [Double] {
        let inProgressEpisodeTime = array(forKey: UserDefaults.inProgressEpisodeTimeKey) as? [Double] ?? [Double]()
        return inProgressEpisodeTime

    }
    
//    func inProgressEpisodeTime(time: Double) {
//        do {
//            var currentTime = inProgressEpisodesTimes()
//            currentTime.insert(time, at: 0)
//            let data = try JSONEncoder().encode(currentTime)
//            UserDefaults.standard.set(data, forKey: UserDefaults.inProgressEpisodeTimeKey)
//        } catch let encodeErr {
//            print("Failed to encode episode:", encodeErr)
//        }
//    }
//
//    func inProgressEpisodesTimes() -> [Double] {
//        guard let inProgressEpisodeTime = data(forKey: UserDefaults.inProgressEpisodeTimeKey) else { return [] }
//        do {
//            let episodesTime = try JSONDecoder().decode([Double].self, from: inProgressEpisodeTime)
//            return episodesTime
//        } catch let decodeErr{
//            print("Failed to decode:", decodeErr)
//        }
//        return []
//    }

    func inProgressEpisode(episode: Episode) {
        do {
            var episodes = inProgressEpisodes()
            episodes.insert(episode, at: 0)
            let data = try JSONEncoder().encode(episodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.inProgressEpisodeKey)
        } catch let encodeErr {
            print("Failed to encode episode:", encodeErr)
        }
    }
    
    func inProgressEpisodes() -> [Episode] {
        guard let inprogressEpisodes = data(forKey: UserDefaults.inProgressEpisodeKey) else { return [] }
        do {
        let episodes = try JSONDecoder().decode([Episode].self, from: inprogressEpisodes)
        return episodes
    } catch let decodeErr{
        print("Failed to decode:", decodeErr)
    }
    return []

    }
    
    func deleteInProgressTime(time: Double, indexPath: Int) {
        var inProgressTime = inProgressEpisodesTimes()
        inProgressTime.remove(at: indexPath)
    }
    
    func downloadEpisode(episode: Episode) {
        do {
            var episodes = downloadedEpisodes()
            episodes.insert(episode, at: 0)
            let data = try JSONEncoder().encode(episodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadEpisodesKey)
        } catch let encodeErr {
            print("Failed to encode episode:", encodeErr)
        }
    }
    
    func downloadedEpisodes() -> [Episode] {
        guard let episodesData = data(forKey: UserDefaults.downloadEpisodesKey) else { return [] }
        do {
            let episodes = try JSONDecoder().decode([Episode].self, from: episodesData)
            return episodes
        } catch let decodeErr {
            print("Failed to decode:", decodeErr)
        }
        return []
    }
    
    func deleteEpisode(episode: Episode) {
        let savedEpisodes = downloadedEpisodes()
        let filteredEpisodes = savedEpisodes.filter { (episode) -> Bool in
            return episode.title != episode.title
        }
        do {
            let data = try JSONEncoder().encode(filteredEpisodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadEpisodesKey)
        } catch let encodeErr {
            print("Failed to encode episode:", encodeErr)
        }
    }
    
    func deleteEpisodeInProgress(episode: Episode) {
       let inProgressEpisodesArray = inProgressEpisodes()
        let filteredInProgressEpisodesArray = inProgressEpisodesArray.filter { (episode) -> Bool in
            return episode.title != episode.title
        }
        do {
            let data = try JSONEncoder().encode(filteredInProgressEpisodesArray)
            UserDefaults.standard.set(data, forKey: UserDefaults.inProgressEpisodeKey)
        } catch let encodeErr {
            print("Encode Error", encodeErr)
        }
    }
    
    func savedPodcasts() -> [Podcast] {
        
        guard let savedPodcastsData = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else { return [] }
        guard let savedPodcasts = NSKeyedUnarchiver.unarchiveObject(with: savedPodcastsData) as? [Podcast] else { return [] }
        return savedPodcasts
    }
    
    
    func deletePodcast(podcast: Podcast) {
        let podcasts = savedPodcasts()
        let filteredPodasts = podcasts.filter { (p) -> Bool in
            return p.trackName != podcast.trackName && p.artistName != podcast.artistName
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: filteredPodasts)
        UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
    }
    
}
