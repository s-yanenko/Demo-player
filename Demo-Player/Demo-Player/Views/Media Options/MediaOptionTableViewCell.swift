//
//  MediaOptionTableViewCell.swift
//  Demo-Player
//
//  Created by Serhii Yanenko on 8/8/19.
//  Copyright © 2019 Serhii Yanenko. All rights reserved.
//

import Foundation
import UIKit

class MediaOptionTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    
    var option: PlayerMediaOption? {
        didSet {
            titleLabel.text = option?.title
        }
    }
    
    
    
    // MARK: - Overrides
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkmarkImageView.isHidden = !selected
        adjustColors()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        adjustColors()
    }
    
    
    
    // MARK: - Private
    
    private func adjustColors() {
        let alpha: CGFloat = isHighlighted || isSelected ? 1 : 0.7
        checkmarkImageView.tintColor = checkmarkImageView.tintColor.withAlphaComponent(alpha)
    }
}
