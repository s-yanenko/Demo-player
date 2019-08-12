//
//  MediaOptionsViewControllerDelegate.swift
//  Demo-Player
//
//  Created by Serhii Yanenko on 8/8/19.
//  Copyright © 2019 Serhii Yanenko. All rights reserved.
//

import Foundation

/// Delegate of media options switcher controller.
protocol MediaOptionsViewControllerDelegate: class {
    
    /// Informs delegate, that audio option was selected.
    ///
    /// - Parameters:
    ///   - viewController: Controller where selection happen.
    ///   - option: Selected option.
    func mediaOptionsController(_ viewController: MediaOptionsViewController, didAskToSwitchAudioOptionOn option: PlayerMediaOption?)
    
    /// Informs delegate, that closed caption option was selected.
    ///
    /// - Parameters:
    ///   - viewController: Controller where selection happen.
    ///   - option: Selected option.
    func mediaOptionsController(_ viewController: MediaOptionsViewController, didAskToSwitchSubtitleOptionOn option: PlayerMediaOption?)
}
