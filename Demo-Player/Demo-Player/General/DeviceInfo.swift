//
//  DeviceInfo.swift
//  Demo-Player
//
//  Created by Serhii Yanenko on 8/1/19.
//  Copyright © 2019 Serhii Yanenko. All rights reserved.
//

import UIKit
import Foundation

final class DeviceInfo {
    static var userInterfaceIdiom: UIUserInterfaceIdiom {
        return UIDevice.current.userInterfaceIdiom
    }
    
    static var isTablet: Bool {
        return userInterfaceIdiom == .pad
    }
    
    static var isPhone: Bool {
        return userInterfaceIdiom == .phone
    }
}
