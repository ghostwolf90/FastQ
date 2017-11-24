# FastQ紀錄手冊
這份手冊主要紀錄swift撰寫FastQ app 技術過程及重點。

[![](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)](https://github.com/sindresorhus/awesome)

## 使用技術部份
* [不使用segue畫面切換（Dot-use segue）](#dot-use-segue)
* [使用等待refresh (Use-refresh)](#use-refresh)
* [讓螢幕跟著旋轉 (tran-screen)](#tran-screen)
* [使用iAd (use-iad)](#use-iad)

### 不使用segue畫面切換（Dot-use segue）

透過語法去載入指定的View Controller。

**譬如應該如下這樣寫：**  
```swift
  var vc = self.storyboard?.instantiateViewControllerWithIdentifier("showWeb") as! showWebViewController
  var nc = self.storyboard?.instantiateViewControllerWithIdentifier("nc") as! UINavigationController
  nc.pushViewController(vc, animated: false)
  vc.htmlUrl = tempQrcode
  self.showDetailViewController(nc, sender: self)
```
### 使用等待refresh (Use-refresh)

透過元件Activity Indicator View加進View Controller。
```swift
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  //add refresh
  self.showWeb.delegate = self
  activityIndicator.hidesWhenStopped = true
  activityIndicator.startAnimating()
  self.showWeb.loadRequest(request)
```
當web載入完畢後，使用webViewDidFinishLoad停止動畫。
```swift
func webViewDidFinishLoad(webView: UIWebView) {
  activityIndicator.stopAnimating()
}
```

### 讓螢幕跟著旋轉 (tran-screen)

還不了解方法，晚點補上
```swift
  //to make interface-based adjustments
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
```

### 使用iAd (use-iad)
```swift
  @IBOutlet var adBannerView: ADBannerView!
  override func viewDidLoad() {
     //省略其他段落   
      self.canDisplayBannerAds = true
      self.adBannerView?.delegate = self
      self.adBannerView?.hidden = true
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
```



