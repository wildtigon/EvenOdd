//
//  MenuViewController.swift
//  EvenOdd
//
//  Created by Nguyễn Tiến Đạt on 3/21/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

//Constants
//let kLengthUserPass = 5

// A delay function
func delay(seconds seconds: Double, completion:()->()) {
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
    
    dispatch_after(popTime, dispatch_get_main_queue()) {
        completion()
    }
}

class MenuViewController: BaseViewController {
    
    //IBOutlet
    @IBOutlet weak var ibTxtUserName: UITextField!
    @IBOutlet weak var ibTxtUserPass: UITextField!
    
    @IBOutlet weak var ibValidUserName: UILabel!
    @IBOutlet weak var ibValidUserPass: UILabel!
    
    @IBOutlet weak var ibTxtLabel: UILabel!
    @IBOutlet weak var ibButtonLogin: UIButton!
    
    @IBOutlet weak var cloud1: UIImageView!
    @IBOutlet weak var cloud2: UIImageView!
    @IBOutlet weak var cloud3: UIImageView!
    @IBOutlet weak var cloud4: UIImageView!
    
    let minimalUsernameLength = 5
    let minimalPasswordLength = 5
    
    var isFirstValidUserName = true
    var isFirstValidUserPass = true
    
    //Variables
    var statusPosition = CGPoint.zero
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    let status = UIImageView(image: UIImage(named: "banner"))
    let info = UILabel()
    let label = UILabel()
    
    //Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAnimation()
        //        initRAC()
        initRx()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        startAnimation()
    }
    
    //
    //Rx
    //
    private func initRx(){
        // create valid signal
        // old way
        let userNameValid = ibTxtUserName.rx_text
            .map { $0.characters.count >= self.minimalUsernameLength }
            .shareReplay(1)
        let userPassValid = ibTxtUserPass.rx_text
            .map{ $0.characters.count >= self.minimalPasswordLength}
            .shareReplay(1)
        
        let combineValid = Observable.combineLatest(userNameValid, userPassValid){ $0 && $1}
            .shareReplay(1)
        
        
        userNameValid.bindTo(ibTxtUserPass.rx_enabled)
            .addDisposableTo(disposeBag)
        combineValid.bindTo(ibButtonLogin.rx_enabled)
            .addDisposableTo(disposeBag)
        
        
        // fast way
        ibTxtUserName.rx_text
            .map { (string: String) -> Bool in
                if (string.characters.count == 0 && self.isFirstValidUserName){
                    return true
                }else if (string.characters.count > 0 && self.isFirstValidUserName){
                    self.isFirstValidUserName = false
                    return false
                }else {
                    return string.characters.count >= self.minimalUsernameLength
                }
            }
            .bindTo(ibValidUserName.rx_hidden)
            .addDisposableTo(disposeBag)
        
        
        ibTxtUserPass.rx_text
            .map { (string: String) -> Bool in
                if (string.characters.count == 0 && self.isFirstValidUserPass){
                    return true
                }else if (string.characters.count > 0 && self.isFirstValidUserPass){
                    self.isFirstValidUserPass = false
                    return false
                }else {
                    return string.characters.count >= self.minimalPasswordLength
                }
            }
            .bindTo(ibValidUserPass.rx_hidden)
            .addDisposableTo(disposeBag)
        
        ibButtonLogin.rx_tap
            .throttle(0.3, scheduler: MainScheduler.instance)
            .subscribeNext {_ in
                if (self.ibButtonLogin.enabled){
                    self.ibButtonLogin.enabled = false
                    //Show Spinner
                    UIView.animateWithDuration(0.33, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: {
                        self.spinner.center = CGPoint(x: 30.0, y: self.ibButtonLogin.frame.size.height/2)
                        self.spinner.alpha = 1.0
                        
                        }, completion: nil)
                    
                    //Call Network
                    //fake
                    delay(seconds: 1.0) { () -> () in
                        self.spinner.center = CGPoint(x: -20.0, y: 16.0)
                        self.spinner.alpha = 0.0
                        self.ibButtonLogin.enabled = true
                        self.performSegueWithIdentifier("segue_menu_mainviewslidebar", sender: self)
                    }
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    //
    //Animation
    //
    private func initAnimation(){
        ibButtonLogin.layer.cornerRadius = 8.0
        ibButtonLogin.layer.masksToBounds = true
        
        spinner.frame = CGRect(x: -20.0, y: 6.0, width: 20.0, height: 20.0)
        spinner.startAnimating()
        spinner.alpha = 0.0
        ibButtonLogin.addSubview(spinner)
        
        status.hidden = true
        status.center = ibButtonLogin.center
        view.addSubview(status)
        
        label.frame = CGRect(x: 0.0, y: 0.0, width: status.frame.size.width, height: status.frame.size.height)
        label.font = UIFont(name: "HelveticaNeue", size: 18.0)
        label.textColor = UIColor(red: 0.89, green: 0.38, blue: 0.0, alpha: 1.0)
        label.textAlignment = .Center
        status.addSubview(label)
        
        statusPosition = status.center
        
        info.frame = CGRect(x: 0.0, y: ibButtonLogin.center.y + 60.0,
                            width: view.frame.size.width, height: 30)
        info.backgroundColor = UIColor.clearColor()
        info.font = UIFont(name: "HelveticaNeue", size: 12.0)
        info.textAlignment = .Center
        info.textColor = UIColor.whiteColor()
        info.text = "Tap on a field and enter username and password"
        view.insertSubview(info, belowSubview: ibButtonLogin)
    }
    
    private func startAnimation(){
        let formGroup = CAAnimationGroup()
        formGroup.duration = 0.5
        formGroup.fillMode = kCAFillModeBackwards
        
        let flyRight = CABasicAnimation(keyPath: "position.x")
        flyRight.fromValue = -view.bounds.size.width/2
        flyRight.toValue = view.bounds.size.width/2
        
        let fadeFieldIn = CABasicAnimation(keyPath: "opacity")
        fadeFieldIn.fromValue = 0.25
        fadeFieldIn.toValue = 1.0
        
        formGroup.animations = [flyRight, fadeFieldIn]
        ibTxtLabel.layer.addAnimation(formGroup, forKey: nil)
        
        formGroup.delegate = self
        formGroup.setValue("form", forKey: "name")
        
        formGroup.setValue(ibTxtUserName.layer, forKey: "layer")
        formGroup.beginTime = CACurrentMediaTime() + 0.3
        ibTxtUserName.layer.addAnimation(formGroup, forKey: nil)
        
        formGroup.setValue(ibTxtUserPass.layer, forKey: "layer")
        formGroup.beginTime = CACurrentMediaTime() + 0.4
        ibTxtUserPass.layer.addAnimation(formGroup, forKey: nil)
        
        let fadeIn = CABasicAnimation(keyPath: "opacity")
        fadeIn.fromValue = 0.0
        fadeIn.toValue = 1.0
        fadeIn.duration = 0.5
        fadeIn.fillMode = kCAFillModeBackwards
        fadeIn.beginTime = CACurrentMediaTime() + 0.5
        cloud1.layer.addAnimation(fadeIn, forKey: nil)
        
        fadeIn.beginTime = CACurrentMediaTime() + 0.7
        cloud2.layer.addAnimation(fadeIn, forKey: nil)
        
        fadeIn.beginTime = CACurrentMediaTime() + 0.9
        cloud3.layer.addAnimation(fadeIn, forKey: nil)
        
        fadeIn.beginTime = CACurrentMediaTime() + 1.1
        cloud4.layer.addAnimation(fadeIn, forKey: nil)
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.beginTime = CACurrentMediaTime() + 0.5
        groupAnimation.duration = 0.5
        groupAnimation.fillMode = kCAFillModeBackwards
        groupAnimation.timingFunction = CAMediaTimingFunction(
            name: kCAMediaTimingFunctionEaseIn)
        
        let scaleDown = CABasicAnimation(keyPath: "transform.scale")
        scaleDown.fromValue = 3.5
        scaleDown.toValue = 1.0
        
        let rotate = CABasicAnimation(keyPath: "transform.rotation")
        rotate.fromValue = CGFloat(M_PI_4)
        rotate.toValue = 0.0
        
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0.0
        fade.toValue = 1.0
        
        groupAnimation.animations = [scaleDown, rotate, fade]
        ibButtonLogin.layer.addAnimation(groupAnimation, forKey: nil)
        
        animateCloud(cloud1.layer)
        animateCloud(cloud2.layer)
        animateCloud(cloud3.layer)
        animateCloud(cloud4.layer)
        
        let flyLeft = CABasicAnimation(keyPath: "position.x")
        flyLeft.fromValue = info.layer.position.x + view.frame.size.width
        flyLeft.toValue = info.layer.position.x
        flyLeft.duration = 5.0
        info.layer.addAnimation(flyLeft, forKey: "infoappear")
        
        let fadeLabelIn = CABasicAnimation(keyPath: "opacity")
        fadeLabelIn.fromValue = 0.2
        fadeLabelIn.toValue = 1.0
        fadeLabelIn.duration = 4.5
        info.layer.addAnimation(fadeLabelIn, forKey: "fadein")
        
    }
    
    //funcs
    private func colorForValidity(valid : AnyObject!) -> UIColor! {
        return (valid as! Bool) ? UIColor.whiteColor() : UIColor.whiteColor()
    }
    
    //    private func isValidUserName(name : AnyObject!) -> NSNumber! {
    //        return (name as! NSString).length > kLengthUserPass;
    //    }
    //
    //    private func isValidUserPass(name : AnyObject!) -> NSNumber! {
    //        return (name as! NSString).length > kLengthUserPass;
    //    }
    
    private func animateCloud(layer: CALayer) {
        //1
        let cloudSpeed = 60.0 / Double(view.layer.frame.size.width)
        let duration: NSTimeInterval = Double(view.layer.frame.size.width - layer.frame.origin.x) * cloudSpeed
        
        //2
        let cloudMove = CABasicAnimation(keyPath: "position.x")
        cloudMove.duration = duration
        cloudMove.toValue = self.view.bounds.size.width + layer.bounds.width/2
        cloudMove.delegate = self
        cloudMove.setValue("cloud", forKey: "name")
        cloudMove.setValue(layer, forKey: "layer")
        
        layer.addAnimation(cloudMove, forKey: nil)
    }
    
    func tintBackgroundColor(layer layer: CALayer, toColor: UIColor) {
        
        let tint = CABasicAnimation(keyPath: "backgroundColor")
        tint.fromValue = layer.backgroundColor
        tint.toValue = toColor.CGColor
        tint.duration = 1.0
        layer.addAnimation(tint, forKey: nil)
        layer.backgroundColor = toColor.CGColor
    }
    
    func roundCorners(layer layer: CALayer, toRadius: CGFloat) {
        
        let round = CABasicAnimation(keyPath: "cornerRadius")
        round.fromValue = layer.cornerRadius
        round.toValue = toRadius
        round.duration = 0.33
        layer.addAnimation(round, forKey: nil)
        layer.cornerRadius = toRadius
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if let name = anim.valueForKey("name") as? String {
            if name == "form" {
                //form field found
                let layer = anim.valueForKey("layer") as? CALayer
                anim.setValue(nil, forKey: "layer")
                
                let pulse = CASpringAnimation(keyPath: "transform.scale")
                pulse.damping = 7.5
                pulse.fromValue = 1.25
                pulse.toValue = 1.0
                pulse.duration = pulse.settlingDuration
                layer?.addAnimation(pulse, forKey: nil)
            }
            
            if name == "cloud" {
                if let layer = anim.valueForKey("layer") as? CALayer {
                    anim.setValue(nil, forKey: "layer")
                    
                    layer.position.x = -layer.bounds.width/2
                    delay(seconds: 0.5, completion: {
                        self.animateCloud(layer)
                    })
                }
            }
        }
    }
    
    private func animateTextFieldWhenEndEdit(any: AnyObject!){
        let textField = any as! UITextField
        let jump = CASpringAnimation(keyPath: "position.y")
        jump.initialVelocity = 100.0
        jump.mass = 10.0
        jump.stiffness = 1500.0
        jump.damping = 50.0
        
        jump.fromValue = textField.layer.position.y + 1.0
        jump.toValue = textField.layer.position.y
        jump.duration = jump.settlingDuration
        textField.layer.addAnimation(jump, forKey: nil)
        
        textField.layer.borderWidth = 3.0
        textField.layer.borderColor = UIColor.clearColor().CGColor
        
        let flash = CASpringAnimation(keyPath: "borderColor")
        flash.damping = 7.0
        flash.stiffness = 200.0
        flash.fromValue = UIColor(red: 0.96, green: 0.27, blue: 0.0, alpha: 1.0).CGColor
        flash.toValue = UIColor.clearColor().CGColor
        flash.duration = flash.settlingDuration
        textField.layer.addAnimation(flash, forKey: nil)
    }
    
    //    private func onLogin(any: AnyObject!){
    //        let button = any as! UIButton
    //
    //        //Show Spinner
    //        UIView.animateWithDuration(0.33, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: {
    //            self.spinner.center = CGPoint(x: 30.0, y: button.frame.size.height/2)
    //            self.spinner.alpha = 1.0
    //
    //            }, completion: nil)
    //
    //        //Call Network
    //        //fake
    //        delay(seconds: 1.0) { () -> () in
    //            self.spinner.center = CGPoint(x: -20.0, y: 16.0)
    //            self.spinner.alpha = 0.0
    //
    //            self.performSegueWithIdentifier("segue_menu_mainviewslidebar", sender: self)
    //        }
    //
    //        print ("OnLogin")
    //    }
}

