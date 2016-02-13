//
//  ViewController.swift
//  AccelDraw2
//
//  Created by Guo Xiaoyu on 2/6/16.
//  Copyright © 2016 Xiaoyu Guo. All rights reserved.
//

import UIKit
import CoreMotion
import AudioToolbox

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var touchCountTextField: UITextField!
    @IBOutlet weak var coorTextField: UITextField!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var vibrEnableBtn: UIButton!
    @IBOutlet weak var stickModeBtn: UIButton!
    @IBOutlet weak var settingsBtn: UIButton!
    @IBOutlet weak var ballModeBtn: UIButton!
    
    var isVibrEnable = false
    var ballMode = true
    
    var session = CMMotionManager()
    var stickMode = true
    var currPoint = CGPointMake(0, 0)
    var startDrawing = false
    var touchCount = 0
    
    var red = CGFloat(1)
    var green = CGFloat(0)
    var blue = CGFloat(0)
    var brushSize = CGFloat(5)
    var speed = CGFloat(5)
    
    var magic_ball = UIImage(named: "magic_ball")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // border for buttons
        clearButton.layer.borderWidth = CGFloat(1.0)
        clearButton.layer.borderColor = UIColor.blueColor().CGColor
        clearButton.layer.cornerRadius = CGFloat(6)
        vibrEnableBtn.layer.borderWidth = CGFloat(1.0)
        vibrEnableBtn.layer.borderColor = UIColor.blueColor().CGColor
        vibrEnableBtn.layer.cornerRadius = CGFloat(6)
        stickModeBtn.layer.borderWidth = CGFloat(1.0)
        stickModeBtn.layer.borderColor = UIColor.blueColor().CGColor
        stickModeBtn.layer.cornerRadius = CGFloat(6)
        settingsBtn.layer.borderWidth = CGFloat(1.0)
        settingsBtn.layer.borderColor = UIColor.blueColor().CGColor
        settingsBtn.layer.cornerRadius = CGFloat(6)
        ballModeBtn.layer.borderWidth = CGFloat(1.0)
        ballModeBtn.layer.borderColor = UIColor.blueColor().CGColor
        ballModeBtn.layer.cornerRadius = CGFloat(6)
        
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    func accelSession() {
        if(!startDrawing) {
            session.stopAccelerometerUpdates()
            return
        }
        
        session.accelerometerUpdateInterval = 1.0/60.0
        
        //        session.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) {
        //            (motion: CMDeviceMotion?, error: NSError?) -> Void in print (motion?.userAcceleration)}
        
        session.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue()) {
            (data: CMAccelerometerData?, error: NSError?) in
            print(data?.acceleration)
            
            let accel = CGPoint(
                x: data!.acceleration.x,
                y: data!.acceleration.y
            )
            
            let spd = self.speed
            
            var nextPoint = CGPointMake(
                self.currPoint.x + spd * accel.x,
                self.currPoint.y - spd * accel.y
            )
            
            nextPoint = self.stickMode ? self.stickToBounds(nextPoint) : self.bounceOnBounds(nextPoint)
            
            self.ballMode ? self.drawBall(atPoint: nextPoint) : self.drawLine(fromPoint: self.currPoint, toPoint: nextPoint)
            
            self.currPoint = nextPoint
            self.coorTextField.text = String(format: "x: %.0f y: %.0f", self.currPoint.x, self.currPoint.y)
        }
    }
    
    func drawBall(atPoint p: CGPoint) {
        
        
        UIGraphicsBeginImageContext(self.imageView.frame.size)
        
        let context = UIGraphicsGetCurrentContext()
        // clear context before drawing
        CGContextClearRect(context, self.imageView.frame)

        self.magic_ball = self.resizeImage(UIImage(named: "magic_ball")!, scale: brushSize/15.0)
        self.magic_ball?.drawAtPoint(p)

        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }
    
    func drawLine(fromPoint a: CGPoint, toPoint b: CGPoint) {
        
        
        UIGraphicsBeginImageContext(self.imageView.frame.size)
        
        let context = UIGraphicsGetCurrentContext()
        
        self.imageView.image?.drawInRect(
            CGRectMake(0, 0,
                self.imageView.frame.size.width,
                self.imageView.frame.size.height))
        
        
//        let ori = CGPointMake(
//            self.view.frame.origin.x +
//                self.imageView.frame.size.width/2.0,
//            self.view.frame.origin.y +
//                self.imageView.frame.size.height/2.0
//        )
        
        // Specify line end points
        CGContextMoveToPoint(context, a.x, a.y)
        CGContextAddLineToPoint(context, b.x, b.y)
        
        // Set line parameters
        CGContextSetLineWidth(context, brushSize)
        CGContextSetRGBStrokeColor(context, red, green, blue, 1.0)
        CGContextSetLineCap(context, .Round)
        // renders the line into pixels
        CGContextStrokePath(context)
        
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }
    
    // func that avoid line drawing out of bounds
    func stickToBounds(point: CGPoint) -> CGPoint{
        var nextPoint = point
        
        let leftBound = self.imageView.bounds.origin.x
        let rightBound = self.ballMode ? leftBound + self.imageView.bounds.size.width - (self.magic_ball?.size.width)! : leftBound + self.imageView.bounds.size.width
        let topBound = self.imageView.bounds.origin.y
        let botBound = self.ballMode ? topBound + self.imageView.bounds.size.height - (self.magic_ball?.size.height)! : topBound + self.imageView.bounds.size.height
        
        if(nextPoint.x < leftBound) {
            nextPoint.x = leftBound
        }
        if(nextPoint.x > rightBound) {
            nextPoint.x = rightBound
        }
        if(nextPoint.y < topBound) {
            nextPoint.y = topBound
        }
        if(nextPoint.y > botBound) {
            nextPoint.y = botBound
        }
        
        return nextPoint
    }
    
    // func that let line end point bounce on the bounds
    func bounceOnBounds(point: CGPoint) -> CGPoint{
        var nextPoint = point
        
        let leftBound = self.imageView.bounds.origin.x
        let rightBound = self.ballMode ? leftBound + self.imageView.bounds.size.width - (self.magic_ball?.size.width)! : leftBound + self.imageView.bounds.size.width
        let topBound = self.imageView.bounds.origin.y
        let botBound = self.ballMode ? topBound + self.imageView.bounds.size.height - (self.magic_ball?.size.height)! : topBound + self.imageView.bounds.size.height
        
        if(nextPoint.x < leftBound || nextPoint.x > rightBound || nextPoint.y < topBound || nextPoint.y > botBound) {
            if(isVibrEnable) {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
        }
        
        if(nextPoint.x < leftBound) {
            nextPoint.x = leftBound + (leftBound - nextPoint.x) * 10
        }
        if(nextPoint.x > rightBound) {
            nextPoint.x = rightBound - (nextPoint.x - rightBound) * 10
        }
        if(nextPoint.y < topBound) {
            nextPoint.y = topBound + (topBound - nextPoint.y) * 10
        }
        if(nextPoint.y > botBound) {
            nextPoint.y = botBound - (nextPoint.y - botBound) * 10
        }
        
        return nextPoint

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let settingsView = segue.destinationViewController as! SettingsViewController
        
        settingsView.red = red
        settingsView.green = green
        settingsView.blue = blue
        settingsView.brushSize = brushSize
        settingsView.speed = speed
        settingsView.delegate = self
    }
    
    @IBAction func clearButtonClicked(sender: UIButton) {
        imageView.image = nil
        touchCount = 0
        startDrawing = false
        self.accelSession()
        touchCountTextField.text = "\(touchCount) touches"
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(!self.view.userInteractionEnabled) {
            return
        }
        touchCount += 1
        touchCountTextField.text = "\(touchCount) touches"
        if(touchCount%2 == 1) {
            let touch = touches.first as UITouch!
            self.currPoint = touch.locationInView(self.imageView)
            coorTextField.text = String(format: "x: %.0f y: %.0f", self.currPoint.x, self.currPoint.y)
            startDrawing = true
        } else {
            startDrawing = false
        }
        
        self.accelSession()
    }
    @IBAction func bounceModeBtnClicked(sender: UIButton) {
        self.stickMode = !self.stickMode
        if(self.stickMode) {
            sender.setTitle("Stick Mode", forState: .Normal)
        }else {
            sender.setTitle("Bounce Mode", forState: .Normal)
        }
    }
    @IBAction func vibrOnBtnClicked(sender: UIButton) {
        self.isVibrEnable = !self.isVibrEnable
        if(self.isVibrEnable) {
            sender.setTitle("Vibr On", forState: .Normal)
        }else {
            sender.setTitle("Vibr Off", forState: .Normal)
        }
    }
    @IBAction func ballModeBtnClicked(sender: UIButton) {
        self.ballMode = !self.ballMode
        sender.setTitle(self.ballMode ? "Ball Mode" : "Line Mode", forState: .Normal)
        self.clearButtonClicked(clearButton)
    }
    
    func resizeImage(image: UIImage, scale: CGFloat) -> UIImage {
        
        //let scale = newWidth / image.size.width
        let newWidth = image.size.width * scale
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    override func viewWillAppear(animated: Bool) {
        self.view.userInteractionEnabled = true
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.view.userInteractionEnabled = false
    }
}

extension ViewController :SettingsViewControllerDelegate {
    func finalChosenSettings(red : CGFloat, green : CGFloat, blue : CGFloat, brushSize: CGFloat, speed: CGFloat) {
        self.red = red
        self.green = green
        self.blue = blue
        self.brushSize = brushSize
        self.speed = speed
    }
}

