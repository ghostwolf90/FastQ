//
//  showWebViewController.swift
//  FastQ
//
//  Created by Laibit on 2015/7/11.
//  Copyright (c) 2015年 Laibit. All rights reserved.
//

import UIKit

class showWebViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var showWeb: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var htmlUrl : String!
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var urlPath:String = htmlUrl
        var url:NSURL = NSURL(string:urlPath)!
        var request:NSURLRequest = NSURLRequest(URL:url)
        
        //add refresh
        self.showWeb.delegate = self
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.showWeb.loadRequest(request)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicator.stopAnimating()
    }
    
    func refreshWebView(refresh:UIRefreshControl){
        self.showWeb.reload()
        refresh.endRefreshing()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var svc = segue.destinationViewController as! ViewController
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
