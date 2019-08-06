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


class PlayerViewController: ViewController, PlayerAdapterDelegate {
    
    
    // MARK: - Properties
    
    @IBOutlet weak var playerControlsView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBOutlet weak var skipForwardButton: UIButton!
    @IBOutlet weak var skipBackwardButton: UIButton!
    @IBOutlet weak var mediaOptionsButton: UIButton!
    
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var seekSlider: UISlider!
    
    lazy var adapter: PlayerAdapter = {
        var adapter = AVPlayerAdapterImp.init()
        adapter.delegate = self
        return adapter
    }()
    
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        subscribeToNotifications()
        configureRendering()
    
        setupPlayback()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    // MARK: - Overrides
    
    
    
    // MARK: - PlayerAdapterDelegate
    
    func playerAdapter(_ playerAdapter: PlayerAdapter, didChangeStateFrom oldState: PlayerAdapterState, to newState: PlayerAdapterState) {
        if newState == .failed {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func playerAdapter(_ playerAdapter: PlayerAdapter, didChangePlaybackStateFrom oldState: PlaybackState, to newPlaybackState: PlaybackState) {
        if newPlaybackState == .running {
            //startControlsDisappearingTimer()
        }
    }
    
    func playerAdapter(_ playerAdapter: PlayerAdapter, didEncounterAnError error: Error) {
        adapter.suspend()
        //showError
    }
    
    func playerAdapterDidPlayToEnd(_ playerAdapter: PlayerAdapter) {
        dismiss(animated: true, completion: nil)
    }
    
    func playerAdapter(_ playerAdapter: PlayerAdapter, didChangeCurrentTimeTo seconds: TimeInterval) {
        
    }
    
    func playerAdapter(_ playerAdapter: PlayerAdapter, needsToDismissPlayerAnimated animated: Bool) {
        dismiss(animated: animated, completion: nil)
    }
    

    
    
    // MARK: - Private
    
    func setupPlayback() {
        do {
            try adapter.load(with: GlobalConstants.playbackPath)
        }
        catch let err {
            print("Failed to start playback: \(err)")
            // show error
        }
       
    }
    
    func configureRendering() {
        adapter.renderingView.frame = view.bounds
        adapter.renderingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        adapter.renderingView.translatesAutoresizingMaskIntoConstraints = true
        view.insertSubview(adapter.renderingView, at: 0)
    }
    
    
    @IBAction func clouseButtonTouched(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playButtonTouched(_ sender: Any) {
        adapter.resume()
        pauseButton.isHidden = false
        playButton.isHidden = true
    }
    
    @IBAction func pauseButtonTouched(_ sender: Any) {
        adapter.pause()
        playButton.isHidden = false
        pauseButton.isHidden = true
    }
    
    @IBAction func skipBackwardButtonTouched(_ sender: Any) {
        
    }
    
    @IBAction func skipForwardButtonTouched(_ sender: Any) {
        
    }
    
    @IBAction func mediaOptionsButtonTouched(_ sender: Any) {
        
    }
    
    @IBAction func seekControlTouched(_ sender: Any) {
        
    }
    
    
}
