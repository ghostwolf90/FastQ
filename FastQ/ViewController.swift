//
//  ViewController.swift
//  FastQ
//
//  Created by Laibit on 2015/7/11.
//  Copyright (c) 2015年 Laibit. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate{
    // 初始化
    var userDefult = NSUserDefaults.standardUserDefaults()
    var device : AVCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    var tempQrcode: String!
    var i:Int = 0
    
    //lazy 使用才會產生; input用鏡頭去做接收資料
    lazy var deviceInput : AVCaptureDeviceInput = {
        return AVCaptureDeviceInput(device: self.device, error: nil)
        }()
    //輸出，掃瞄到的文字
    var metadataOutput : AVCaptureMetadataOutput = AVCaptureMetadataOutput()
    //當做input & Output 橋樑，開關
    var session : AVCaptureSession = AVCaptureSession()
    
    lazy var previewLayer : AVCaptureVideoPreviewLayer = {
        return AVCaptureVideoPreviewLayer(session: self.session)
        }()
    
    var targetLayer = CALayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session.addOutput(metadataOutput)
        session.addInput(deviceInput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        
        metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, atIndex: 0)
        targetLayer.frame = view.bounds
        view.layer.addSublayer(targetLayer)
        
        //開始做掃描
        session.startRunning()
    }
    
    func clearTargetLayer(){
        if targetLayer.sublayers != nil{
            for sublayer in targetLayer.sublayers{
                sublayer.removeFromSuperlayer()
            }
        }
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        clearTargetLayer()
        
        for current in metadataObjects{
            if var readableCodeObject = current as? AVMetadataMachineReadableCodeObject{
                readableCodeObject = previewLayer.transformedMetadataObjectForMetadataObject(readableCodeObject)as! AVMetadataMachineReadableCodeObject
                showDetectedObjects(readableCodeObject)
                
                var scanCodeOutput = readableCodeObject.stringValue
                tempQrcode = readableCodeObject.stringValue
                
                if scanCodeOutput != nil {
                    var alert = UIAlertController(title: "是否前往...", message: scanCodeOutput, preferredStyle: UIAlertControllerStyle.ActionSheet)
                    alert.addAction(UIAlertAction(title:"確定",style:UIAlertActionStyle.Default, handler:{(UIAlertAction) -> Void in
                        println("你點擊了確定!")
                        self.showQrcodeToWeb()
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        previewLayer.removeFromSuperlayer()
        if (toInterfaceOrientation == UIInterfaceOrientation.Portrait){
            previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
        }else if(toInterfaceOrientation == UIInterfaceOrientation.LandscapeLeft){
            previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
        }else if (toInterfaceOrientation == UIInterfaceOrientation.LandscapeRight){
            previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
        }
        previewLayer.frame = CGRectMake(0, 0, view.frame.height, view.frame.width)
        view.layer.insertSublayer(previewLayer, atIndex: 0)
    }
    
    func showQrcodeToWeb(){
        session.stopRunning()
        var vc = self.storyboard?.instantiateViewControllerWithIdentifier("showWeb") as! showWebViewController
        var nc = self.storyboard?.instantiateViewControllerWithIdentifier("nc") as! UINavigationController
        nc.pushViewController(vc, animated: false)
        vc.htmlUrl = tempQrcode
        self.showDetailViewController(nc, sender: self)
    }
    
    func showDetectedObjects(codeObject:AVMetadataMachineReadableCodeObject){
        var shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.greenColor().CGColor
        shapeLayer.lineWidth = 2
        shapeLayer.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).CGColor
        var path = createPathForPoints(codeObject.corners)
        shapeLayer.path = path
        targetLayer.addSublayer(shapeLayer)
    }
    
    func createPathForPoints(points: NSArray) -> CGMutablePathRef{
        let path = CGPathCreateMutable()
        var point = CGPoint()
        
        if points.count > 0 {
            CGPointMakeWithDictionaryRepresentation(points.objectAtIndex(0) as! CFDictionaryRef, &point)
            CGPathMoveToPoint(path, nil, point.x, point.y)
            
            var i = 1
            while i < points.count {
                CGPointMakeWithDictionaryRepresentation(points.objectAtIndex(i) as! CFDictionaryRef, &point)
                CGPathAddLineToPoint(path, nil, point.x, point.y)
                i++
            }
            CGPathCloseSubpath(path)
            
        }
        return path
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

