//
//  ViewController.swift
//  FastQ
//
//  Created by Laibit on 2015/7/11.
//  Copyright (c) 2015年 Laibit. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController{
    @IBOutlet weak var scanView: UIView!
    
    // 初始化
    var userDefult = UserDefaults.standard
    var tempQrcode: String!
    var i:Int = 0
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    let supportedCodeTypes = [AVMetadataObject.ObjectType.qr]
    // Added to support different barcodes
    
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
        
        #if !((arch(i386) || arch(x86_64)) && os(iOS))
        starScanner()
        #endif
        addMaskRect()
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
//    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
//        previewLayer.removeFromSuperlayer()
//        if (toInterfaceOrientation == UIInterfaceOrientation.portrait){
//            previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
//        }else if(toInterfaceOrientation == UIInterfaceOrientation.landscapeLeft){
//            previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
//        }else if (toInterfaceOrientation == UIInterfaceOrientation.landscapeRight){
//            previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
//        }
//        previewLayer.frame = CGRect(x: 0, y: 0, width: view.frame.height, height: view.frame.width)
//        view.layer.insertSublayer(previewLayer, at: 0)
//    }
    
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
    
    func starScanner() {
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        //CrashReport.log("掃描載具啟動")
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = .resizeAspectFill
            videoPreviewLayer?.frame = CGRect(x: 0, y: 0, width: scanView.frame.size.width, height:scanView.frame.size.height)
            scanView.layer.addSublayer(videoPreviewLayer!)
            
            //檢查目前方向並轉向正確方位
            videoPreviewLayer?.connection?.videoOrientation = .portrait
//            if UIApplication.shared.statusBarOrientation == .landscapeLeft{
//                videoPreviewLayer?.connection?.videoOrientation = .landscapeLeft
//            }else{
//                videoPreviewLayer?.connection?.videoOrientation = .landscapeRight
//            }
            
            // Start video capture.
            self.switchScanner(isOpen: true)
        } catch {
            print(error)
            return
        }
    }
    
    func switchScanner(isOpen:Bool){
        if isOpen{
            captureSession?.startRunning()
        }else{
            captureSession?.stopRunning()
        }
    }
    
    func addMaskRect(){
        // 中間簍空範圍
        let rect = CGRect(x: 25, y: 70, width: 326, height: 479)
        let rectCornerRadius = 4.0
        
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: scanView.frame.width, height: scanView.frame.height))
        let roundRectPath = UIBezierPath(roundedRect: rect, cornerRadius: CGFloat(rectCornerRadius))
        
        path.append(roundRectPath)
        path.usesEvenOddFillRule = true
        
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = kCAFillRuleEvenOdd
        fillLayer.fillColor = UIColor.black.cgColor
        fillLayer.opacity = 0.3
        scanView.layer.addSublayer(fillLayer)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ViewController: AVCaptureMetadataOutputObjectsDelegate{
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.isEmpty == true || metadataObjects.count == 0 {
            print("掃描沒有成功，對準鏡頭再掃描看看!")
            return
        }
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            
            if metadataObj.stringValue != nil {
                self.switchScanner(isOpen: false)
            }
        }
    }
}

