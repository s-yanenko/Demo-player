//
//  PlayerViewController+Mobile.swift
//  Demo-Player
//
//  Created by Serhii Yanenko on 8/5/19.
//  Copyright © 2019 Serhii Yanenko. All rights reserved.
//

import Foundation
import UIKit

extension PlayerViewController {
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
