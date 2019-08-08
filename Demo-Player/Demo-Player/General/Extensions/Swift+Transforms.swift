//
//  Swift+Transforms.swift
//  Demo-Player
//
//  Created by Serhii Yanenko on 8/8/19.
//  Copyright © 2019 Serhii Yanenko. All rights reserved.
//

import Foundation

// MARK: - Transforms
extension TimeInterval {
    
    /// Converts seconds to Hours Minutes and Seconds tuple
    func timeComponents() -> (hours: Int, minutes: Int, seconds: Int) {
        return (Int(self) / 3600, (Int(self) % 3600) / 60, (Int(self) % 3600) % 60)
    }
}
