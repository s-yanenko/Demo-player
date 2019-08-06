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


class PlayerViewController: ViewController {
    
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
    
    private(set) var player: AVPlayer!
    
    private(set) lazy var renderingView: PlayerRenderingView = {
        let playerRenderingView = PlayerRenderingView()
        playerRenderingView.backgroundColor = .black
        if let layer = playerRenderingView.layer as? AVPlayerLayer {
            layer.player = self.player
        }
        return playerRenderingView
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        view.clipsToBounds = true
        player = AVPlayer()
        subscribeToNotifications()
        configureRendering()
    
        setupPlayback()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    // MARK: - Overrides
    
    
    
    

    
    
    // MARK: - Private
    
    func setupPlayback() {
        guard let playbackUrl = URL(string: GlobalConstants.playbackPath) else {
            return
            // showError
        }
        let asset = AVURLAsset(url: playbackUrl)
        let playerItem = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    func configureRendering() {
        renderingView.frame = view.bounds
        renderingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        renderingView.translatesAutoresizingMaskIntoConstraints = true
        view.insertSubview(renderingView, at: 0)
    }
    
    
    @IBAction func clouseButtonTouched(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playButtonTouched(_ sender: Any) {
        player.play()
        pauseButton.isHidden = false
        playButton.isHidden = true
    }
    
    @IBAction func pauseButtonTouched(_ sender: Any) {
        player.pause()
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
