//
//  showWebViewController.swift
//  FastQ
//
//  Created by Laibit on 2015/7/11.
//  Copyright (c) 2015年 Laibit. All rights reserved.
//

/*
簡單，方便，快速
沒有複雜的操作，
你要面對的就只有，
遇到Qrcode，立馬掃描，馬上瀏覽！
您值得擁有更好的Qrcode App！

*/

import UIKit
import Social
import iAd

class showWebViewController: UIViewController, UIWebViewDelegate, ADBannerViewDelegate {

    @IBOutlet weak var showWeb: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var adBannerView: ADBannerView!
    
    var htmlUrl : String!
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canDisplayBannerAds = true
        let urlPath:String = htmlUrl
        let url:NSURL = NSURL(string:urlPath)!
        let request:NSURLRequest = NSURLRequest(URL:url)
        
        //add refresh
        self.showWeb.delegate = self
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.showWeb.loadRequest(request)
        
        self.canDisplayBannerAds = true
        self.adBannerView?.delegate = self
        self.adBannerView?.hidden = true
    }
    
    @IBAction func backToView(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("scanView") as! ViewController
        self.showDetailViewController(vc, sender: self)
    }
    
    
    func bannerViewWillLoadAd(banner: ADBannerView!) {
        
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        self.adBannerView?.hidden = false
    }
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        
        return true
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
            self.adBannerView?.hidden = true
    }
    
    //分享按钮事件 至Safari
    @IBAction func shareUp(sender: AnyObject) {
        //Link to Safari
        if let requestUrl = NSURL(string: htmlUrl) {
            UIApplication.sharedApplication().openURL(requestUrl)
        }
        /*
        var controller:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeSinaWeibo)
        controller.setInitialText("一起来swift吧！")
        controller.addImage(UIImage(named: "app720_12801"))
        self.presentViewController(controller, animated: true, completion: nil)
        */
    }
    
    //隱藏導覽列
    override func viewWillAppear(animated: Bool) {
        //super.viewWillAppear(animated)
        //self.navigationController?.hidesBarsOnSwipe = true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicator.stopAnimating()
    }
    
    func refreshWebView(refresh:UIRefreshControl){
        self.showWeb.reload()
        refresh.endRefreshing()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        _ = segue.destinationViewController as! ViewController
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
