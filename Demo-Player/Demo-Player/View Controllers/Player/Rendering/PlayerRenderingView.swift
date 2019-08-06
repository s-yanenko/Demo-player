//
//  PlayerRenderingView.swift
//  Demo-Player
//
//  Created by Serhii Yanenko on 8/2/19.
//  Copyright © 2019 Serhii Yanenko. All rights reserved.
//

import AVFoundation
import UIKit

class PlayerRenderingView: UIView {
    
    // MARK: - Overrides
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
