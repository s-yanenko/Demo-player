//
//  PlayerViewController.swift
//  Demo-Player
//
//  Created by Serhii Yanenko on 8/1/19.
//  Copyright © 2019 Serhii Yanenko. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation


class PlayerViewController: ViewController, PlayerAdapterDelegate, MediaOptionsViewControllerDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var playerControlsView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBOutlet weak var skipForwardButton: UIButton!
    @IBOutlet weak var skipBackwardButton: UIButton!
    @IBOutlet weak var mediaOptionsButton: UIButton!
    
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var seekSlider: UISlider!
    @IBOutlet weak var playerRenderingView: UIView!
    @IBOutlet weak var renderingViewTapGesture: UITapGestureRecognizer!
    
    var shouldShowStatusBar = true
    
    lazy var adapter: PlayerAdapter = {
        var adapter = AVPlayerAdapterImp.init()
        adapter.delegate = self
        return adapter
    }()
    
    private var durationInSeconds: TimeInterval = 0 {
        didSet {
            updateTimingInfo()
        }
    }
    
    private var currentTimeInSeconds: TimeInterval {
        return elapsedInSeconds
    }
    
    private var elapsedInSeconds: TimeInterval = 0 {
        didSet {
            updateTimingInfo()
        }
    }
    
    private var skipBackwardInSeconds: TimeInterval {
        return GlobalConstants.secondsToSkipBackwardTimeInterval
    }
    
    private var skipForwardInSeconds: TimeInterval {
        return GlobalConstants.secondsToSkipForwardTimeInterval
    }
    
    private var valueRangeForTracking: ClosedRange<Float> {
        guard durationInSeconds != 0 else {
            return 0...0
        }
        let range: ClosedRange<TimeInterval> = 0...adapter.currentPlayerItemDurationInSeconds
        return Float(range.lowerBound / durationInSeconds)...Float(range.upperBound/durationInSeconds)
    }
    private var additionalSkipTimer: Timer?
    private var controlsDisappearingTimer: Timer?
    
    private var isContinuousSeek: Bool = false
    private var isContinuousSkip: Bool = false
    
    private var internalCurrentTimeInSeconds: TimeInterval = 0 {
        didSet {
            guard durationInSeconds != 0 else {
                return
            }
            let progress = Float(internalCurrentTimeInSeconds / ceil(durationInSeconds))
            seekSlider.setValue(progress, animated: true)
        }
    }
    
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToNotifications()
        configureRendering()
        configureStyling()
        setupPlayback()
    }
    
    deinit {
        stopControlsDisappearingTimer()
        stopAdditionalSkipTimer()
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    // MARK: - PlayerAdapterDelegate
    
    func playerAdapter(_ playerAdapter: PlayerAdapter, didChangeStateFrom oldState: PlayerAdapterState, to newState: PlayerAdapterState) {

    }
    
    func playerAdapter(_ playerAdapter: PlayerAdapter, didChangePlaybackStateFrom oldState: PlaybackState, to newPlaybackState: PlaybackState) {
        if newPlaybackState == .running {
            startControlsDisappearingTimer()
        }
    }
    
    func playerAdapter(_ playerAdapter: PlayerAdapter, didEncounterAnError error: Error) {
        adapter.suspend()
        handleError(error, handler: { [weak self] in
            self?.closePlayer()
            })
    }
    
    func playerAdapterDidPlayToEnd(_ playerAdapter: PlayerAdapter) {
        closePlayer()
    }
    
    func playerAdapter(_ playerAdapter: PlayerAdapter, didChangeCurrentTimeTo seconds: TimeInterval) {
        durationInSeconds = adapter.currentPlayerItemDurationInSeconds
        elapsedInSeconds = seconds
    }
    
    func playerAdapter(_ playerAdapter: PlayerAdapter, needsToDismissPlayerAnimated animated: Bool) {
        closePlayer()
    }
    
    
    
    // MARK: - MediaOptionsViewControllerDelegate
    
    func mediaOptionsController(_ viewController: MediaOptionsViewController, didAskToSwitchAudioOptionOn option: PlayerMediaOption?) {
        adapter.currentAudioOption = option
        adapter.preselectedAudioLanguageIdentifier = option?.languageCode
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func mediaOptionsController(_ viewController: MediaOptionsViewController, didAskToSwitchSubtitleOptionOn option: PlayerMediaOption?) {
        adapter.currentSubtitleOption = option
        adapter.preselectedSubtitleLanguageIdentifier = option?.languageCode
        viewController.dismiss(animated: true, completion: nil)
    }

    
    
    // MARK: - Private
    // MARK: - General
    
    private func closePlayer() {
        adapter.stop()
        dismiss(animated: true, completion: nil)
    }
    
    private func configureStyling() {
        makeControlsViewVisible(true, animated: true)
        skipBackwardButton.setTitle(String(format: "%.f", skipBackwardInSeconds), for: .normal)
        skipForwardButton.setTitle(String(format: "%.f", skipForwardInSeconds), for: .normal)
    }
    
    private func setupPlayback() {
        do {
            try adapter.load(with: GlobalConstants.playbackPath)
        }
        catch let err {
            print("Failed to start playback: \(err)")
            handleError(err)
        }
       
    }
    
    private func configureRendering() {
        adapter.renderingView.frame = playerRenderingView.bounds
        adapter.renderingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        adapter.renderingView.translatesAutoresizingMaskIntoConstraints = true
        playerRenderingView.insertSubview(adapter.renderingView, at: 0)
    }
    
    private func showMediaOptionsController() {
        let mediaOptionsController = UIStoryboard(name: "Player", bundle: nil).instantiateViewController(withIdentifier: "MediaOptions") as! MediaOptionsViewController
        mediaOptionsController.delegate = self
        mediaOptionsController.audioOptions = adapter.audioOptions
        
        var options = adapter.subtitleOptions
        let offSubtitlesOption = PlayerMediaOption(index: 0, title: "Off", identifier: "Off", languageCode: "en")
        options.insert(offSubtitlesOption, at: 0)
        if adapter.currentSubtitleOption == nil {
            adapter.currentSubtitleOption = offSubtitlesOption
        }
        
        mediaOptionsController.subtitleOptions = options
        mediaOptionsController.currentAudioOption = adapter.currentAudioOption
        mediaOptionsController.currentSubtitleOption = adapter.currentSubtitleOption
        mediaOptionsController.modalPresentationStyle = .fullScreen
        present(mediaOptionsController, animated: true, completion: nil)
    }
    
    
    
    // MARK: - Timing
    
    private func updateTimingInfo() {
        guard durationInSeconds != 0 else {
            elapsedTimeLabel.text = "00:00"
            remainingTimeLabel.text = "00:00"
            seekSlider.setValue(0, animated: true)
            return
        }
        let duration = ceil(durationInSeconds)
        let elapsed = ceil(elapsedInSeconds)
        let remaining = duration - elapsed
        elapsedTimeLabel.text = timeString(from: elapsed)
        remainingTimeLabel.text = timeString(from: remaining, prefix: "-")
        
        if !isContinuousSeek && !isContinuousSkip {
            // We shouldn't update progress if user currently seeking.
            let progress = Float(elapsed / duration)
            seekSlider.setValue(progress, animated: true)
        }
    }
    
    private func timeString(from seconds: TimeInterval, prefix: String = "") -> String {
        let timeComponents = seconds.timeComponents()
        var timeComponentStrings = [timeComponents.minutes, timeComponents.seconds].map {
            String(format: "%02d", $0)
        }
        if timeComponents.hours > 0 {
            let hoursString = String(format: "%d", timeComponents.hours)
            timeComponentStrings.insert(hoursString, at: 0)
        }
        return "\(prefix)\(timeComponentStrings.joined(separator: ":"))"
    }
    
    private func handleSeek(to seconds: TimeInterval) {
        if isContinuousSeek {
            internalCurrentTimeInSeconds = seconds
            adapter.seek(to: seconds, continuous: isContinuousSeek)
            adapter.resume()
        }
        else {
            elapsedInSeconds = internalCurrentTimeInSeconds
            
        }
        startControlsDisappearingTimer()
    }
    
    
    
    // MARK: - Seeking
    
    private func handleSkip(to seconds: TimeInterval) {
        internalCurrentTimeInSeconds = seconds
        if isContinuousSkip {
            restartAdditionalSkipTimer()
            adapter.seek(to: seconds, continuous: isContinuousSkip)
            adapter.resume()
        }
        else {
            elapsedInSeconds = internalCurrentTimeInSeconds
        }
        startControlsDisappearingTimer()
    }
    
    private func restartAdditionalSkipTimer() {
        stopAdditionalSkipTimer()
        additionalSkipTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                                   target: self,
                                                   selector: #selector(handleAdditionalSkip),
                                                   userInfo: nil,
                                                   repeats: true)
    }
    
    @objc private func handleAdditionalSkip(_ timer: Timer) {
        isContinuousSkip = false
        handleSkip(to: self.currentTimeInSeconds)
    }
    
    private func stopAdditionalSkipTimer() {
        additionalSkipTimer?.invalidate()
        additionalSkipTimer = nil
    }
    
    
    
    // MARK: - Controls presentation
    
    func startControlsDisappearingTimer() {
        stopControlsDisappearingTimer()
        controlsDisappearingTimer = Timer.scheduledTimer(timeInterval: GlobalConstants.controlsDisappearingTimeInterval,
                                                         target: self,
                                                         selector: #selector(handleControlsDissapearing),
                                                         userInfo: nil,
                                                         repeats: true)
    }
    
    func stopControlsDisappearingTimer() {
        controlsDisappearingTimer?.invalidate()
        controlsDisappearingTimer = nil
    }
    
    @objc private func handleControlsDissapearing(_ timer: Timer) {
        makeControlsViewVisible(false, animated: true)
    }
    
    func makeControlsViewVisible(_ visible: Bool, animated: Bool) {
        renderingViewTapGesture.isEnabled = !visible
        shouldShowStatusBar = visible
        setNeedsStatusBarAppearanceUpdate()
        let alpha: CGFloat = visible ? 1 : 0
        guard animated else {
            playerControlsView.alpha = alpha
            return
        }
        UIView.animate(withDuration: GlobalConstants.defaultAnimationDuration, animations: { [weak self] in
            self?.playerControlsView.alpha = alpha
            }, completion: { [weak self] _ in
                if visible {
                    self?.startControlsDisappearingTimer()
                }
        })
    }
    
    
    // MARK: - Actions
    
    @IBAction func clouseButtonTouched(_ sender: Any) {
        closePlayer()
    }
    
    @IBAction func playButtonTouched(_ sender: Any) {
        adapter.resume()
        pauseButton.isHidden = false
        playButton.isHidden = true
        startControlsDisappearingTimer()
    }
    
    @IBAction func pauseButtonTouched(_ sender: Any) {
        adapter.pause()
        playButton.isHidden = false
        pauseButton.isHidden = true
    }
    
    @IBAction func skipBackwardButtonTouched(_ sender: Any) {
        isContinuousSkip = true
        handleSkip(to: max(currentTimeInSeconds - skipBackwardInSeconds, 0))
    }
    
    @IBAction func skipForwardButtonTouched(_ sender: Any) {
        isContinuousSkip = true
        handleSkip(to: min(currentTimeInSeconds + skipForwardInSeconds, durationInSeconds))
    }
    
    @IBAction func mediaOptionsButtonTouched(_ sender: Any) {
        showMediaOptionsController()
    }
    
    @IBAction func seekControlTouched(_ sender: UISlider) {
        isContinuousSeek = false
        let value = max(valueRangeForTracking.lowerBound, min(sender.value, valueRangeForTracking.upperBound))
        handleSeek(to: TimeInterval(value) * ceil(durationInSeconds))
    }
    
    @IBAction func seekControlValueChanged(_ sender: UISlider) {
        isContinuousSeek = true
        let value = max(valueRangeForTracking.lowerBound, min(sender.value, valueRangeForTracking.upperBound))
        handleSeek(to: TimeInterval(value) * ceil(durationInSeconds))
    }
    @IBAction func renderingViewGestureTapped(_ sender: UITapGestureRecognizer) {
        makeControlsViewVisible(true, animated: true)
    }
}
