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
    
    override func viewDidLoad() {
        
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
}
