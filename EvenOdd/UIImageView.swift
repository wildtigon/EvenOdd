//
//  UIImageView.swift
//  EvenOdd
//
//  Created by Nguyễn Tiến Đạt on 3/24/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import UIKit
import GPUImage

extension UIImageView {

    func setRandomDownloadImage(width: Int, height: Int) {
        if self.image != nil {
            self.alpha = 1
            return
        }
        self.alpha = 0
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
                        self.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            self.alpha = 1
                        }) { (finished: Bool) -> Void in
                        }
                    })
                }
            }
        })
        task.resume()
    }
    
    func setBlurImage(image: UIImage){
        self.image = image
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.backgroundColor = UIColor.clearColor()
            
            let blurEffect = UIBlurEffect(style: .Light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.bounds
            blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            self.addSubview(blurEffectView)         }
        
    }
}
