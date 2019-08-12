//
//  PlayerViewController+Observers.swift
//  Demo-Player
//
//  Created by Serhii Yanenko on 8/5/19.
//  Copyright © 2019 Serhii Yanenko. All rights reserved.
//

import Foundation
import UIKit

extension PlayerViewController {
    
    // MARK: - Notification observers
    
    func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationWillResignActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationDidBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func handleApplicationWillResignActiveNotification(_ notification: Notification) {
        onApplicationWillResignActive()
    }
    
    @objc private func handleApplicationDidBecomeActiveNotification(_ notification: Notification) {
        onApplicationDidBecomeActive()
    }
    
    func onApplicationDidBecomeActive() {
        adapter.resume()
    }
    
    func onApplicationWillResignActive() {
        adapter.pause()
    }
}
