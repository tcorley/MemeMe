//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Corley, Tyler on 8/23/17.
//  Copyright © 2017 Corley, Tyler. All rights reserved.
//

import Foundation
import UIKit

class MemeTableViewController: UITableViewController {
    
    var memes = [Meme]()
    
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    //memeCell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MemeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "memeCell", for: indexPath) as! MemeTableViewCell
        let meme = memes[indexPath.row]
        
        cell.topTextLabel?.text = meme.topText
        cell.bottomTextLabel?.text = meme.bottomText
        cell.memeImageView?.image = meme.meme
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let meme = memes[indexPath.row]
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        controller.meme = meme
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    @IBAction func goToEditMeme(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editMemeVC = storyboard.instantiateViewController(withIdentifier: "MemeEditorViewController")
        present(editMemeVC, animated: true, completion: nil)
    }
}
