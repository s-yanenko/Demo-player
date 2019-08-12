//
//  PlayerAdapter.swift
//  Demo-Player
//
//  Created by Serhii Yanenko on 8/6/19.
//  Copyright © 2019 Serhii Yanenko. All rights reserved.
//

import Foundation
import UIKit

/// Errors, commonly thrown by all player adapters.
enum PlayerAdapterError: Error {
    /// Unknown error.
    case undefined
    /// Adapter failed to load stream, because there in on url exist.
    case noStreamUrl
    /// Adapter failed some opertaion because of using invalid time parameter.
    case invalidTime
    /// Adapter failed to seek, because of absence seekable ranges.
    case noSeekableTimeRanges
    /// Adapter stream interrupted.
    case streamInterruption
}

/// States which indicates current status of adatapter.
enum PlayerAdapterState {
    /// Initial state.
    case undefined
    /// Player is loading asset.
    case loading
    /// Player is buffering stream.
    case seeking
    /// Player is ready to start playback.
    case readyToPlay
    /// Playback finished.
    case finished
    /// Playback failed.
    case failed
}

/// States of playback.
enum PlaybackState {
    /// Player is paused.
    case paused
    /// Player is currently playing.
    case running
    /// Player was running before, but now it suspended.
    case suspended
}

/// Represents the object which is used by adapter to control stream audio and subtitles.
class PlayerMediaOption {
    let index: Int
    let title: String
    let identifier: String
    let languageCode: String?
    
    init(index: Int, title: String, identifier: String, languageCode: String?) {
        self.index = index
        self.title = title
        self.identifier = identifier
        self.languageCode = languageCode
    }
    
    init(index: Int, title: String) {
        self.index = index
        self.title = title
        self.identifier = title
        self.languageCode = Locale(identifier: title).languageCode
    }
    
    convenience init(index: Int, locale: Locale) {
        let identifier = locale.identifier
        let title = locale.localizedString(forLanguageCode: identifier) ?? locale.identifier
        let languageCode = locale.languageCode
        self.init(index: index, title: title, identifier: identifier, languageCode: languageCode)
    }
}

extension PlayerMediaOption: Equatable {
    static func == (lhs: PlayerMediaOption, rhs: PlayerMediaOption) -> Bool {
        return lhs.index == rhs.index && lhs.identifier == rhs.identifier
    }
}


/// Delegate for player adapter.
protocol PlayerAdapterDelegate: class {
    
    /// Informs delegate, that adapter state is changed.
    ///
    /// - Parameters:
    ///   - playerAdapter: Adapter state of which was changed.
    ///   - oldState: Previous adapter state.
    ///   - newState: New adapter state.
    func playerAdapter(_ playerAdapter: PlayerAdapter, didChangeStateFrom oldState: PlayerAdapterState, to newState: PlayerAdapterState)
    
    /// Informs delegate, that adapter playback state is changed.
    ///
    /// - Parameters:
    ///   - playerAdapter: Adapter where playback state was changed.
    ///   - oldState: Previous playback state.
    ///   - newState: New playback state.
    func playerAdapter(_ playerAdapter: PlayerAdapter, didChangePlaybackStateFrom oldState: PlaybackState, to newPlaybackState: PlaybackState)
    
    /// Informs delegate, that some error occured.
    ///
    /// - Parameters:
    ///   - playerAdapter: Adapter where error occured.
    ///   - error: Error which happened.
    func playerAdapter(_ playerAdapter: PlayerAdapter, didEncounterAnError error: Error)
    
    /// Informs delegate, that asset was payed to end.
    ///
    /// - Parameter playerAdapter: Adapter where action happened.
    func playerAdapterDidPlayToEnd(_ playerAdapter: PlayerAdapter)
    
    /// Informs delegate, that current playback time is changed.
    ///
    /// - Parameter playerAdapter: Adapter where action happened.
    ///   - seconds: Current playback time.
    func playerAdapter(_ playerAdapter: PlayerAdapter, didChangeCurrentTimeTo seconds: TimeInterval)
    
    /// Informs delegate, that adapter requires to dismiss the player.
    ///
    /// - Parameter playerAdapter: Adapter where action happened.
    /// - Parameter animated: Defines if transition should be animated.
    func playerAdapter(_ playerAdapter: PlayerAdapter, needsToDismissPlayerAnimated animated: Bool)
}

protocol PlayerAdapter {
    var delegate: PlayerAdapterDelegate? { get set }
    var renderingView: UIView { get }
    var currentState: PlayerAdapterState { get }
    var currentPlaybackState: PlaybackState { get }
    var currentPlayerItemDurationInSeconds: TimeInterval { get }
    var currentPlayerItemPositionInSeconds: TimeInterval { get }
    var preselectedAudioLanguageIdentifier: String? { get set }
    var preselectedSubtitleLanguageIdentifier: String? { get set }
    var currentAudioOption: PlayerMediaOption? { get set }
    var currentSubtitleOption: PlayerMediaOption? { get set }
    var audioOptions: [PlayerMediaOption] { get }
    var subtitleOptions: [PlayerMediaOption] { get }
    var isMarkedSuspended: Bool { get }
    
    init()
    func load(with playbackPath: String) throws
    func resume()
    func pause()
    func suspend()
    func stop()
    func seek(to seconds: TimeInterval, continuous: Bool)
}


