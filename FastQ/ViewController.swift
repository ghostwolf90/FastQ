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
    var userDefult = UserDefaults.standard
    var device : AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    var tempQrcode: String!
    var i:Int = 0
    // Added to support different barcodes
    let supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]
    /*
    //lazy 使用才會產生; input用鏡頭去做接收資料
    lazy var deviceInput : AVCaptureDeviceInput = {
        return AVCaptureDeviceInput(device: self.device, error: nil)
        }()
    */
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
        do {
            let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            let input = try AVCaptureDeviceInput(device: captureDevice)
            // Do the rest of your work...
            session.addInput(input as AVCaptureInput)
        } catch let error as NSError {
            // Handle any errors
            print(error)
        }

        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        //metadataOutput.metadataObjectTypes = supportedBarCodes
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
        targetLayer.frame = view.bounds
        view.layer.addSublayer(targetLayer)
        //開始做掃描
        session.startRunning()
        
        showTargetObjects()
    }
    
    func clearTargetLayer(){
        if targetLayer.sublayers != nil{
            for sublayer in targetLayer.sublayers!{
                sublayer.removeFromSuperlayer()
            }
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        clearTargetLayer()
        
        for current in metadataObjects{
            
            if var readableCodeObject = current as? AVMetadataMachineReadableCodeObject{
                
                readableCodeObject = previewLayer.transformedMetadataObject(for: readableCodeObject)as! AVMetadataMachineReadableCodeObject
                showDetectedObjects(readableCodeObject)
                
                let scanCodeOutput = readableCodeObject.stringValue
                tempQrcode = readableCodeObject.stringValue
                
                if scanCodeOutput != nil {
                    let alert = UIAlertController(title: "GO!", message: scanCodeOutput, preferredStyle: UIAlertControllerStyle.actionSheet)
                    alert.addAction(UIAlertAction(title:"Enter",style:UIAlertActionStyle.default, handler:{(UIAlertAction) -> Void in
                        print("你點擊了確定!")
                        self.showQrcodeToWeb()
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    //to make interface-based adjustments
    //每次你旋转屏幕时都会调用这个方法
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        previewLayer.removeFromSuperlayer()
        if (toInterfaceOrientation == UIInterfaceOrientation.portrait){
            previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.portrait
        }else if(toInterfaceOrientation == UIInterfaceOrientation.landscapeLeft){
            previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
        }else if (toInterfaceOrientation == UIInterfaceOrientation.landscapeRight){
            previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.landscapeRight
        }
        previewLayer.frame = CGRect(x: 0, y: 0, width: view.frame.height, height: view.frame.width)
        view.layer.insertSublayer(previewLayer, at: 0)
    }
    
    func showQrcodeToWeb(){
        session.stopRunning()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "showWeb") as! showWebViewController
        let nc = self.storyboard?.instantiateViewController(withIdentifier: "nc") as! UINavigationController
        nc.pushViewController(vc, animated: false)
        vc.htmlUrl = tempQrcode
        self.showDetailViewController(nc, sender: self)
    }
    
   //畫綠框
    func showDetectedObjects(_ codeObject:AVMetadataMachineReadableCodeObject){
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.green.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        let path = createPathForPoints(codeObject.corners as NSArray)
        shapeLayer.path = path
        targetLayer.addSublayer(shapeLayer)
    }
    
    func showTargetObjects() {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: CGRect(x:110, y: 250, width: 150, height: 150), cornerRadius: 50).cgPath
        //layer.fillColor = UIColor.redColor().CGColor
        layer.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        view.layer.addSublayer(layer)
    }
    
    func createPathForPoints(_ points: NSArray) -> CGMutablePath{
        let path = CGMutablePath()
        var point = CGPoint()
        
        if points.count > 0 {
            let point = CGPoint(dictionaryRepresentation:points[0] as! CFDictionary)
            let path = CGMutablePath()
            path.move(to: CGPoint(x: (point?.x)!, y: (point?.y)!))
            path.addLine(to: CGPoint(x: (point?.x)!, y: (point?.y)!))
            
            var i = 1
            while i < points.count {
                let point = CGPoint(dictionaryRepresentation:points[0] as! CFDictionary)
                let path = CGMutablePath()
                path.move(to: CGPoint(x: (point?.x)!, y: (point?.y)!))
                path.addLine(to: CGPoint(x: (point?.x)!, y: (point?.y)!))
                i = i + 1
            }
            path.closeSubpath()
            
        }
        return path
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

