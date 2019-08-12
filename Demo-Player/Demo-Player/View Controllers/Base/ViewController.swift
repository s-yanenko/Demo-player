//
//  ViewController.swift
//  Demo-Player
//
//  Created by Serhii Yanenko on 8/5/19.
//  Copyright © 2019 Serhii Yanenko. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return DeviceInfo.isTablet ? .landscape : .allButUpsideDown
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    // MARK: - Public
    
    func handleError(_ error: Error, handler: (() -> Void)? = nil) {
        switch error {
        case let adapterError as PlayerAdapterError:
            showPlayerAdapterAlert(for: adapterError, handler: handler)
        default:
            showGenericAlert()
        }
    }
    
    
    
    // MARK: - Private
    
    private func showPlayerAdapterAlert(for error: PlayerAdapterError, handler: (() -> Void)? = nil) {
        switch error {
        case .invalidTime:
            showAlert(message: "Invalid time received.", handler: handler)
        case .noSeekableTimeRanges:
            showAlert(message: "Seek is impossible.", handler: handler)
        case .noStreamUrl:
            showAlert(message: "Failed to get stream URL.", handler: handler)
        case .streamInterruption:
            showAlert(message: "Stream interrupted. Please check your connection.", handler: handler)
        case .undefined:
            showGenericAlert(handler: handler)
        }
    }
    
    private func showGenericAlert(handler: (() -> Void)? = nil) {
        let message = "Something went wrong. Please try again."
        showAlert(message: message, handler: handler)
    }
    
    private func showAlert(message: String, title: String? = nil, handler: (() -> Void)? = nil) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            let titleToUse = title ?? "Error Occurred"
            let alert = UIAlertController(title: titleToUse, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {  _ in handler?() } ))
            topController.present(alert, animated: true, completion: nil)
        }
    }
}
