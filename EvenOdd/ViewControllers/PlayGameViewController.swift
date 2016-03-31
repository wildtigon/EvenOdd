//
//  PlayGameViewController.swift
//  EvenOdd
//
//  Created by Nguyễn Tiến Đạt on 3/21/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import UIKit
import SWRevealViewController
import Firebase

class PlayGameViewController: UIViewController {
    
    //IBOutlets
    @IBOutlet weak var ibButtonMenu: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "Home"
        
        if self.revealViewController() != nil {
            ibButtonMenu.target = self.revealViewController()
            ibButtonMenu.action = #selector(self.revealViewController().revealToggle)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
//        self.navigationController?.setNavigationBarHidden(true, animated: animated);
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func ibaClose(sender: AnyObject) {
        
    }
    
}