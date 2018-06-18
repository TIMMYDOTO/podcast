//
//  UIApplication.swift
//  Podcasts
//
//  Created by Ivan Amidžić on 13/03/2018.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit

extension UIApplication {
    static func mainTabBarController() -> MainTabBarController? {
        return shared.keyWindow?.rootViewController as? MainTabBarController
    }
}
