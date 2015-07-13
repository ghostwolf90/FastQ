//
//  showWebViewController.swift
//  FastQ
//
//  Created by Laibit on 2015/7/11.
//  Copyright (c) 2015年 Laibit. All rights reserved.
//

import UIKit

class showWebViewController: UIViewController {

    @IBOutlet weak var showWeb: UIWebView!
    var dvc : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        let urlPath:String = "www.eyeem.com"
        var url:NSURL = NSURL(string:urlPath)!
        var request:NSURLRequest = NSURLRequest(URL:url)
        self.showWeb.loadRequest(request)
        */
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        //let urlPath:String = "www.eyeem.com"
        var urlPath:String = dvc
        var url:NSURL = NSURL(string:urlPath)!
        var request:NSURLRequest = NSURLRequest(URL:url)
        self.showWeb.loadRequest(request)
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
