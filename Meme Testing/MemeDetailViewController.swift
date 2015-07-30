//
//  MemeDetailViewController.swift
//  Meme Testing
//
//  Created by Sanky Chan on 14/7/15.
//  Copyright (c) 2015 SankieInc. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    var meme: Meme!
    var memes: [Meme]!
    
    @IBOutlet weak var memeDetailImg: UIImageView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = true
        self.memeDetailImg.image = meme.memedImg
        
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        memes = appDelegate.memes
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }
    
    @IBAction func deleteMeme(sender: AnyObject) {
        delete()
        performSegueWithIdentifier("GoBack", sender: sender)
        
    }
    
    //Delete meme by its memeIndex number
    func delete(){
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.removeAtIndex(meme.memeIndex!)
        
    }

}
