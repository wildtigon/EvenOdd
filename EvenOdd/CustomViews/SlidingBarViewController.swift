//
//  SlidingBarViewController.swift
//  EvenOdd
//
//  Created by Nguyễn Tiến Đạt on 3/24/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import UIKit
import SWRevealViewController



class SlidingBarViewController: UITableViewController {
    
    //IBOutlets
    @IBOutlet weak var ibImageCover: UIImageView!
    @IBOutlet weak var ibImageAvatar: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
    }
    
    
    //Functions
    private func initView(){
        //circle uiimageview
        ibImageAvatar.layer.cornerRadius = ibImageAvatar.frame.size.height/2
        
        // download image
        if self.ibImageAvatar.image != nil {
            self.ibImageAvatar.alpha = 1
            self.ibImageCover.alpha = 1
            return
        }
        self.ibImageAvatar.alpha = 0
        self.ibImageCover.alpha = 0
        
        
        let url = NSURL(string: "https://www.chemtecpest.com/images/blog/black-widow-spider-with-hour-glass-marking.jpg")!
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 15
        configuration.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        let session = NSURLSession(configuration: configuration)
        let task = session.dataTaskWithURL(url, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if error != nil {
                return
            }
            
            if let response = response as? NSHTTPURLResponse {
                if response.statusCode / 100 != 2 {
                    return
                }
                if let data = data, let image = UIImage(data: data) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.ibImageAvatar.image = image
                        self.ibImageCover.setBlurImage(image)
                        
                        UIView.animateWithDuration(0.5, animations: { () -> Void in
                            self.ibImageAvatar.alpha = 1
                            self.ibImageCover.alpha = 1

                        }) { (finished: Bool) -> Void in
                        }
                    })
                }
            }
        })
        task.resume()
  }
    
    // TableView
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.revealViewController().revealToggle(nil)
        switch indexPath.row {
        case 0:
            
            break
        case 1:
            
            break
        case 2:
            //Logout
            self.parentViewController?.navigationController?.popViewControllerAnimated(true)
            break
        default:
            
            break
        }
    }
}
