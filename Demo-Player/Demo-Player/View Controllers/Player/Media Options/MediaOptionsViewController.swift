//
//  MediaOptionsViewController.swift
//  Demo-Player
//
//  Created by Serhii Yanenko on 8/8/19.
//  Copyright © 2019 Serhii Yanenko. All rights reserved.
//

import Foundation
import UIKit

class MediaOptionsViewController: ViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Inner types
    
    private struct Constants {
        static let reuseIdentifier = "mediaOptionCell"
        static let audioLabelText = "Audio"
        static let subtitleLabelText = "Subtitles"
    }
    
    
    
    // MARK: - Properties
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var backgroundView: UIVisualEffectView!
    @IBOutlet weak var contentView: UIScrollView!
    
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var audioTitleLabel: UILabel!
    @IBOutlet weak var audioTable: UITableView!
    @IBOutlet weak var subtitlesView: UIView!
    @IBOutlet weak var subtitleTitleLabel: UILabel!
    @IBOutlet weak var subtitleTable: UITableView!
    @IBOutlet private weak var audiosTableViewHeightConstraint: NSLayoutConstraint?
    @IBOutlet private weak var subtitlesTableViewHeightConstraint: NSLayoutConstraint?
    
    weak var delegate: MediaOptionsViewControllerDelegate?
    
    var audioOptions: [PlayerMediaOption] = []
    
    var subtitleOptions: [PlayerMediaOption] = []
    
    var currentAudioOption: PlayerMediaOption? {
        didSet {
            updateAudioOptionSelection()
        }
    }
    
    var currentSubtitleOption: PlayerMediaOption? {
        didSet {
            updateSubtitleOptionSelection()
        }
    }
    
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioTitleLabel.text = Constants.audioLabelText
        subtitleTitleLabel.text = Constants.subtitleLabelText
        updateAudioOptionsLayout()
        updateSubtitleOptionsLayout()
        updateAudioOptionSelection()
        updateSubtitleOptionSelection()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configurePresentation()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    
    
    // MARK: - Protocols
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case audioTable:
            return audioOptions.count
        case subtitleTable:
            return subtitleOptions.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.reuseIdentifier, for: indexPath) as? MediaOptionTableViewCell else {
            return UITableViewCell()
        }
        cell.separatorInset = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
        var option: PlayerMediaOption?
        switch tableView {
        case audioTable:
            guard audioOptions.indices.contains(indexPath.row) else {
                return cell
            }
            option = audioOptions[indexPath.row]
        case subtitleTable:
            guard subtitleOptions.indices.contains(indexPath.row) else {
                return cell
            }
            option = subtitleOptions[indexPath.row]
        default:
            break
        }
        cell.option = option
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case audioTable:
            guard audioOptions.indices.contains(indexPath.row) else {
                return
            }
            let option = audioOptions[indexPath.row]
            currentAudioOption = option
            delegate?.mediaOptionsController(self, didAskToSwitchAudioOptionOn: option)
        case subtitleTable:
            guard subtitleOptions.indices.contains(indexPath.row) else {
                return
            }
            let option = subtitleOptions[indexPath.row]
            currentSubtitleOption = option
            delegate?.mediaOptionsController(self, didAskToSwitchSubtitleOptionOn: option)
        default:
            break
        }
    }
    
    
    
    // MARK: - Private
    
    func configurePresentation() {
        modalPresentationCapturesStatusBarAppearance = true
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        transitioningDelegate = nil
    }
    
    private func updateAudioOptionsLayout() {
        audioTable.reloadData()
        updateAudioOptionSelection()
        updateTableLayout()
    }
    
    private func updateSubtitleOptionsLayout() {
        subtitleTable.reloadData()
        updateSubtitleOptionSelection()
        updateTableLayout()
    }
    
    private func updateTableLayout() {
        let sharedHeight = max(audioTable.contentSize.height, subtitleTable.contentSize.height)
        audiosTableViewHeightConstraint?.constant = sharedHeight
        subtitlesTableViewHeightConstraint?.constant = sharedHeight
    }
    
    private func updateAudioOptionSelection() {
        guard let option = currentAudioOption, let index = audioOptions.index(where: { $0 == option }), isViewLoaded else {
            return
        }
        audioTable.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
    }
    
    private func updateSubtitleOptionSelection() {
        guard let option = currentSubtitleOption, let index = subtitleOptions.index(where: { $0 == option }), isViewLoaded else {
            return
        }
        subtitleTable.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
