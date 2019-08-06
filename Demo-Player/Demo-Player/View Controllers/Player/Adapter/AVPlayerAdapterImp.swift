//
//  AVPlayerAdapterImp.swift
//  Demo-Player
//
//  Created by Serhii Yanenko on 8/6/19.
//  Copyright © 2019 Serhii Yanenko. All rights reserved.
//

import AVKit
import AVFoundation

class AVPlayerAdapterImp: NSObject, PlayerAdapter {
    
    var observationContext = 0
    var playbackTimeObserver: Any?
    
    private(set) var player: AVPlayer!
    
    private(set) lazy var playerRenderingView: PlayerRenderingView = {
        let playerRenderingView = PlayerRenderingView()
        playerRenderingView.backgroundColor = .black
        if let layer = playerRenderingView.layer as? AVPlayerLayer {
            layer.player = self.player
        }
        return playerRenderingView
    }()
    
    private var seekIsContinuous = false
    private var hasSetupMediaOptions = false
    
    
    
    // MARK: - Initializers
    
    override required init() {
        player = AVPlayer()
        super.init()
        subscribeToNotifications()
        addObservation(to: player)
    }
    
    deinit {
        unsubscribeFromNotifications()
        removeObservation(from: player.currentItem)
        removeObservation(from: player)
        player = nil
    }
    
    
    
    // MARK: - Overrides
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let currentKeyPath = keyPath, context == &observationContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        switch currentKeyPath {
        case #keyPath(AVPlayer.rate):
            guard let currentChage = change,
                let new = currentChage[.newKey] as? Int,
                let old = currentChage[.oldKey] as? Int,
                new != old,
                currentPlaybackState != .suspended,
                currentState != .seeking else {
                    return
            }
            switch new {
            case 0:
                currentPlaybackState = .paused
            case 1:
                currentPlaybackState = .running
            default:
                break
            }
        case #keyPath(AVPlayerItem.status):
            guard let currentChage = change,
                let new = currentChage[.newKey] as? Int,
                let old = currentChage[.oldKey] as? Int,
                new != old,
                currentState != .seeking else {
                    return
            }
            switch new {
            case AVPlayerItem.Status.readyToPlay.rawValue:
                currentState = .readyToPlay
            case AVPlayerItem.Status.failed.rawValue:
                currentState = .failed
            default:
                break
            }
        case #keyPath(AVPlayerItem.isPlaybackBufferEmpty):
            guard let currentChage = change,
                let new = currentChage[.newKey] as? Bool,
                let old = currentChage[.oldKey] as? Bool,
                new != old,
                currentState != .seeking else {
                    return
            }
            if new {
                currentState = .loading
            }
        case #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp):
            guard let currentChage = change,
                let new = currentChage[.newKey] as? Bool,
                let old = currentChage[.oldKey] as? Bool,
                new != old,
                currentState != .seeking else {
                    return
            }
            if new {
                currentState = .readyToPlay
            }
        default:
            break
        }
    }
    
    
    
    // MARK: - Protocols
    // MARK: - PlayerAdapter
    
    weak var delegate: PlayerAdapterDelegate?
    
    var renderingView: UIView {
        return playerRenderingView
    }
    
    var currentState: PlayerAdapterState = .undefined {
        didSet {
            guard oldValue != currentState else {
                return
            }
            if oldValue == .loading {
                if !hasSetupMediaOptions {
                    hasSetupMediaOptions = true
                    setupAudioOptions()
                    setupSubtitleOptions()
                }
            }
            delegate?.playerAdapter(self, didChangeStateFrom: oldValue, to: currentState)
            if currentState == .failed {
                let error = player.error ?? PlayerAdapterError.undefined
                delegate?.playerAdapter(self, didEncounterAnError: error)
            }
        }
    }
    
    var currentPlaybackState: PlaybackState = .paused {
        didSet {
            guard oldValue != currentPlaybackState else {
                return
            }
            delegate?.playerAdapter(self, didChangePlaybackStateFrom: oldValue, to: currentPlaybackState)
        }
    }
    
    var currentPlayerItemDurationInSeconds: TimeInterval {
        guard let duration = player.currentItem?.duration, CMTIME_IS_NUMERIC(duration) else {
            return 0
        }
        return CMTimeGetSeconds(duration)
    }
    
    var currentPlayerItemPositionInSeconds: TimeInterval {
        guard let currentTime = player.currentItem?.currentTime(), CMTIME_IS_NUMERIC(currentTime) else {
            return 0
        }
        return CMTimeGetSeconds(currentTime)
    }
    
    var currentAudioOption: PlayerMediaOption? {
        didSet {
            guard let playerItem = player.currentItem, let audioSelectionGroup = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.audible) else {
                return
            }
            let options = audioSelectionGroup.options.enumerated().filter {
                $0.offset == currentAudioOption?.index && $0.element.locale?.identifier == currentAudioOption?.identifier
            }
            playerItem.select(options.first?.element, in: audioSelectionGroup)
        }
    }
    
    var currentSubtitleOption: PlayerMediaOption? {
        didSet {
            guard let playerItem = player.currentItem, let subtitlesSelectionGroup = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.legible) else {
                return
            }
            let nonForcedSubtitles = AVMediaSelectionGroup.mediaSelectionOptions(from: subtitlesSelectionGroup.options, withoutMediaCharacteristics: [AVMediaCharacteristic.containsOnlyForcedSubtitles])
            let options = nonForcedSubtitles.enumerated().filter {
                $0.offset == currentSubtitleOption?.index && $0.element.locale?.identifier == currentSubtitleOption?.identifier
            }
            playerItem.select(options.first?.element, in: subtitlesSelectionGroup)
        }
    }
    
    var preselectedAudioLanguageIdentifier: String?
    var preselectedSubtitleLanguageIdentifier: String?
    var audioOptions: [PlayerMediaOption] = []
    var subtitleOptions: [PlayerMediaOption] = []
    var isMarkedSuspended: Bool = false
    
    func load(with playbackPath: String) throws {
        currentState = .loading
        hasSetupMediaOptions = false
        currentAudioOption = nil
        currentSubtitleOption = nil
        audioOptions = []
        subtitleOptions = []
        guard let playbackUrl = URL(string: playbackPath) else {
            throw PlayerAdapterError.noStreamUrl
        }
        removeObservation(from: player.currentItem)
        let asset = AVURLAsset(url: playbackUrl)
        let playerItem = AVPlayerItem(asset: asset)
        addObservation(to: playerItem)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    func resume() {
        guard !isMarkedSuspended else {
            pause()
            return
        }
        currentPlaybackState = .running
        player.play()
        addPlaybackTimeObserver()
    }
    
    func pause() {
        currentPlaybackState = .paused
        player.pause()
        removePlaybackTimeObserver()
    }
    
    func suspend() {
        currentPlaybackState = .suspended
        player.pause()
        removePlaybackTimeObserver()
    }
    
    func stop() {
        currentState = .undefined
        currentAudioOption = nil
        currentSubtitleOption = nil
        audioOptions = []
        subtitleOptions = []
        removePlaybackTimeObserver()
        removeObservation(from: player.currentItem)
        player.replaceCurrentItem(with: nil)
    }
    
    func seek(to seconds: TimeInterval, continuous: Bool) {
        guard let timeToSeek = timeToSeek(from: seconds) else {
            return
        }
        currentState = .seeking
        seekIsContinuous = continuous
        player.pause()
        removePlaybackTimeObserver()
        player.seek(to: timeToSeek.value, toleranceBefore: timeToSeek.tolerance, toleranceAfter: timeToSeek.tolerance) { [weak self] finished in
            guard let `self` = self, !self.seekIsContinuous, finished else {
                return
            }
            self.correctSeekingState()
        }
    }
    
    
    
    // MARK: - Public
    
    func correctSeekingState() {
        // Correct current state.
        guard currentState == .seeking,
            !seekIsContinuous,
            let currentItem = player.currentItem,
            currentItem.status == .readyToPlay,
            player.status == .readyToPlay else {
                return
        }
        currentState = .readyToPlay
        guard player.rate == 0 else {
            return
        }
        if isMarkedSuspended {
            pause()
        }
        else {
            player.play()
            addPlaybackTimeObserver()
        }
    }
    
    
    
    // MARK: - Private
    // MARK: - Seeking
    
    private func timeToSeek(from seconds: TimeInterval) -> (value: CMTime, tolerance: CMTime)? {
        guard let playerCurrentItem = player.currentItem,
            let seekableRange = playerCurrentItem.seekableTimeRanges.last as? CMTimeRange else {
                return nil
        }
        let startSeekableSeconds = CMTimeGetSeconds(seekableRange.start)
        let endSeekableSeconds = CMTimeGetSeconds(seekableRange.end)
        var secondsToSeek: TimeInterval {
            if seconds < startSeekableSeconds {
                return startSeekableSeconds
            }
            else if seconds > endSeekableSeconds {
                return endSeekableSeconds
            }
            else { return seconds }
        }
        let timeToSeek = CMTime(seconds: secondsToSeek, preferredTimescale: seekableRange.start.timescale)
        let seekTolerance = CMTime(seconds: 0, preferredTimescale: seekableRange.start.timescale)
        guard CMTIME_IS_NUMERIC(timeToSeek), CMTIME_IS_NUMERIC(seekTolerance) else {
            return nil
        }
        
        return (timeToSeek, seekTolerance)
    }
    
    
    
    // MARK: - Media options
    
    private func setupAudioOptions() {
        guard let playerItem = player.currentItem, let audioSelectionGroup = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.audible) else {
            audioOptions = []
            return
        }
        audioOptions = audioSelectionGroup.options.enumerated().compactMap { (index, option) in
            guard let locale = option.locale, option.isPlayable else {
                return nil
            }
            let playerMediaOption = PlayerMediaOption(index: index, locale: locale)
            return playerMediaOption
        }
        if let defaultLang = preselectedAudioLanguageIdentifier,
            let defaultOption = audioOptions.first(where: { $0.languageCode == defaultLang }) {
            currentAudioOption = defaultOption
        }
        else if let englishOption = audioOptions.first(where: { $0.languageCode == "en" }) {
            currentAudioOption = englishOption
        }
        else {
            currentAudioOption = audioOptions.first
        }
    }
    
    private func setupSubtitleOptions() {
        guard let playerItem = player.currentItem, let subtitlesSelectionGroup = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.legible) else {
            subtitleOptions = []
            return
        }
        let nonForcedSubtitles = AVMediaSelectionGroup.mediaSelectionOptions(from: subtitlesSelectionGroup.options, withoutMediaCharacteristics: [AVMediaCharacteristic.containsOnlyForcedSubtitles])
        subtitleOptions = nonForcedSubtitles.enumerated().compactMap { (index, option) in
            guard let locale = option.locale, option.isPlayable else {
                return nil
            }
            let playerMediaOption = PlayerMediaOption(index: index, locale: locale)
            return playerMediaOption
        }
        if let defaultLang = preselectedSubtitleLanguageIdentifier,
            let defaultOption = subtitleOptions.first(where: { $0.languageCode == defaultLang }) {
            currentSubtitleOption = defaultOption
        }
        else {
            currentSubtitleOption = nil
        }
    }
}



extension AVPlayerAdapterImp {
    
    func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidPlayToEndTime(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: nil)
    }
    
    func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addPlaybackTimeObserver() {
        removePlaybackTimeObserver()
        playbackTimeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: DispatchQueue.main) { [weak self] _ in
            guard let `self` = self else {
                return
            }
            self.correctSeekingState()
            self.delegate?.playerAdapter(self, didChangeCurrentTimeTo: self.currentPlayerItemPositionInSeconds)
        }
    }
    
    func removePlaybackTimeObserver() {
        guard let playbackTimeObserver = playbackTimeObserver else {
            return
        }
        player.removeTimeObserver(playbackTimeObserver)
        self.playbackTimeObserver = nil
    }
    
    func addObservation(to playerItem: AVPlayerItem?) {
        guard let item = playerItem else {
            return
        }
        item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.new, .old], context: &observationContext)
        item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty), options: [.new, .old], context: &observationContext)
        item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp), options: [.new, .old], context: &observationContext)
    }
    
    func removeObservation(from playerItem: AVPlayerItem?) {
        guard let item = playerItem else {
            return
        }
        item.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        item.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty))
        item.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp))
    }
    
    func removeObservation(from player: AVPlayer?) {
        guard let player = player else {
            return
        }
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.rate))
    }
    
    func addObservation(to player: AVPlayer?) {
        guard let player = player else {
            return
        }
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.rate), options: [.new, .old], context: &observationContext)
    }
    
    @objc private func playerItemDidPlayToEndTime(_ notification: Notification) {
        guard let finishedItem = notification.object as? AVPlayerItem, finishedItem == player.currentItem else {
            return
        }
        currentState = .finished
        delegate?.playerAdapterDidPlayToEnd(self)
    }
}
