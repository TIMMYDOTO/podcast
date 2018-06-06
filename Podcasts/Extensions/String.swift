//
//  String.swift
//  Podcasts
//
//  Created by Ivan Amidžić on 28/02/2018.
//  Copyright © 2018 Ivan Amidžić. All rights reserved.
//

import Foundation

extension String {
    
    func toSecureHTTPS() -> String {
        return self.contains("https") ? self : self.replacingOccurrences(of: "http", with: "https")
    }
    
}
