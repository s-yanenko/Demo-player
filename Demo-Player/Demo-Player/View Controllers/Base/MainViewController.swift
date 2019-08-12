//
//  MainViewController.swift
//  Demo-Player
//
//  Created by Serhii Yanenko on 7/29/19.
//  Copyright © 2019 Serhii Yanenko. All rights reserved.
//

import UIKit
import AVKit

class MainViewController: ViewController {
    
    // MARK: - Properies
    
    @IBOutlet weak var showPlayerButton: UIButton!
    
    
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    // MARK: - Private
    // MARK: - Actions

    @IBAction func showPlayerTouch(_ sender: UIButton) {
        let playerVc = UIStoryboard(name: "Player", bundle: nil).instantiateInitialViewController() as! PlayerViewController
        present(playerVc, animated: true, completion: nil)
    }
    
}

