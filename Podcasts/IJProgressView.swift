//
//  IJProgressView.swift
//  Clubzz
//
//  Created by Savca Marin on 7/13/18.
//  Copyright © 2018 MacBook Air. All rights reserved.
//

import UIKit

open class IJProgressView {
    
    var containerView = UIView()
        var progressView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    open class var shared: IJProgressView {
        struct Static {
            static let instance: IJProgressView = IJProgressView()
        }
        return Static.instance
    }
    
    open func showProgressView(_ view: UIView, withFrame: Bool = false, withBackgroundColor: Bool = true) {
        containerView.frame = view.frame
        let viewCenter = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        containerView.center = viewCenter
        
        if withBackgroundColor {
            containerView.backgroundColor = UIColor(hex: 0x000000, alpha: 0.2)
        } else {
            containerView.backgroundColor = UIColor(hex: 0x000000, alpha: 0.05)
        }
        
        if withFrame {
            progressView.frame.size = CGSize(width: 80, height: 80)
            progressView.center = viewCenter
            progressView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            progressView.clipsToBounds = true
            progressView.layer.cornerRadius = 10
        }
        activityIndicator.frame.size = CGSize(width: 40, height: 40)
        activityIndicator.center = viewCenter
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.startAnimating()

        
        if withFrame {
            containerView.addSubview(progressView)
            containerView.addSubview(activityIndicator)
        } else {
            containerView.addSubview(activityIndicator)
        }
        containerView.alpha = 0

        view.addSubview(containerView)
        
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, animations: {
                self.containerView.alpha = 1
            }, completion: nil)
        }
    }
    
    open func hideProgressView() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, animations: {
                self.containerView.alpha = 0
            }, completion: { _ in
                self.activityIndicator.stopAnimating()
                self.containerView.removeFromSuperview()
            })
        }
    }
}

extension UIColor {
    
    convenience init(hex: UInt32, alpha: CGFloat) {
        let red = CGFloat((hex & 0xFF0000) >> 16)/256.0
        let green = CGFloat((hex & 0xFF00) >> 8)/256.0
        let blue = CGFloat(hex & 0xFF)/256.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
