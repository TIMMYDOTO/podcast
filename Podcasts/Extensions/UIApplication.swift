//
//  UIApplication.swift
//  Podcasts
//
//  Created by Ivan Amidžić on 13/03/2018.
//  Copyright © 2018 Ivan Amidžić. All rights reserved.
//

import UIKit

extension UIApplication {
    static func mainTabBarController() -> MainTabBarController? {
//        let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        return shared.keyWindow?.rootViewController as? MainTabBarController
    }
}
