//
//  SettingsViewController.swift
//  AccelDraw2
//
//  Created by Guo Xiaoyu on 2/6/16.
//  Copyright © 2016 Xiaoyu Guo. All rights reserved.
//

import UIKit
import QuartzCore

protocol SettingsViewControllerDelegate: class {
    func finalChosenSettings(red : CGFloat, green : CGFloat, blue : CGFloat, brushSize: CGFloat, speed: CGFloat)
}

class SettingsViewController: UIViewController {
    var delegate : SettingsViewControllerDelegate?
    
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var colorPreview: UIView!
    @IBOutlet weak var brushSizeSlider: UISlider!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var speedTextField: UITextField!

    
    var red = CGFloat(0)
    var green = CGFloat(0)
    var blue = CGFloat(0)
    var brushSize = CGFloat(0)
    var speed = CGFloat(0)
    let SPEED_STEP = Float(1)
    
    override func viewDidLoad() {
        redSlider.value = Float(red)
        greenSlider.value = Float(green)
        blueSlider.value = Float(blue)
        brushSizeSlider.value = Float(brushSize)
        speedSlider.value = Float(speed)
        
        doneButton.layer.borderWidth = CGFloat(2.0)
        doneButton.layer.borderColor = UIColor.blueColor().CGColor
        doneButton.layer.cornerRadius = CGFloat(8)
        speedTextField.layer.borderWidth = CGFloat(1.0)
        speedTextField.layer.borderColor = UIColor.clearColor().CGColor
        speedTextField.layer.cornerRadius = CGFloat(6)
        
        updateColorPreview()
    }
    
    @IBAction func redSliderChanged(sender: UISlider) {
        red = CGFloat(sender.value)
        updateColorPreview()
    }
    
    @IBAction func greenSliderChanged(sender: UISlider) {
        green = CGFloat(sender.value)
        updateColorPreview()
    }
    
    @IBAction func blueSliderChanged(sender: UISlider) {
        blue = CGFloat(sender.value)
        updateColorPreview()
    }
    
    @IBAction func brushSizeSliderChanged(sender: UISlider) {
        brushSize = CGFloat(sender.value)
        updateColorPreview()
    }
    
    @IBAction func speedSliderChanged(sender: UISlider) {
        let roundedValue = round(sender.value / self.SPEED_STEP) * self.SPEED_STEP
        sender.value = roundedValue
        speed = CGFloat(sender.value)
        updateColorPreview()
    }
    
    func updateColorPreview(){
        // clean colorPreview UIView
        colorPreview.layer.sublayers = nil
        // Show the speed
        speedTextField.text = String(format: "Speed : %.0f", self.speed)
        speedTextField.textColor = UIColor(colorLiteralRed: Float(red), green: Float(green), blue : Float(blue) , alpha: 1)
        // Draw the circle
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: colorPreview.frame.size.width/2 ,y: colorPreview.frame.size.height/2), radius: CGFloat(colorPreview.frame.size.width/2 * 0.8), startAngle: CGFloat(M_PI * -1/2), endAngle:CGFloat(M_PI * -1/2) + CGFloat(M_PI * 2) * speed/15, clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.CGPath
        
        //change the fill color
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        //you can change the stroke color
        shapeLayer.strokeColor = UIColor(colorLiteralRed: Float(red), green: Float(green), blue : Float(blue) , alpha: 1).CGColor
        //you can change the line width
        shapeLayer.lineWidth = brushSize
        
        colorPreview.layer.addSublayer(shapeLayer)
    }
    
    @IBAction func doneButtonClicked(sender: UIButton) {
        delegate?.finalChosenSettings(red, green: green, blue: blue, brushSize: brushSize, speed: speed)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
