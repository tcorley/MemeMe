//
//  DetailViewController.swift
//  MemeMe
//
//  Created by Corley, Tyler on 8/25/17.
//  Copyright © 2017 Corley, Tyler. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var memeImageView: UIImageView!
    var meme: Meme?
    
    override func viewWillAppear(_ animated: Bool) {
        if let meme = meme?.meme {
            memeImageView.image = meme
        }
    }
}
