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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
