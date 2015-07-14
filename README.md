# FastQ紀錄手冊
這份手冊主要紀錄swift撰寫FastQ app 技術過程及重點。

## 使用技術部份
* [不使用segue畫面切換（Dot-use segue）](#dot-use-segue)
* [使用等待refresh (Use-refresh)](#use-refresh)

## 不使用segue畫面切換（Dot-use segue）

透過語法去載入指定的View Controller。

**譬如應該如下這樣寫：**  
```swift
  var vc = self.storyboard?.instantiateViewControllerWithIdentifier("showWeb") as! showWebViewController
  var nc = self.storyboard?.instantiateViewControllerWithIdentifier("nc") as! UINavigationController
  nc.pushViewController(vc, animated: false)
  vc.htmlUrl = tempQrcode
  self.showDetailViewController(nc, sender: self)
```
## 使用等待refresh (Use-refresh)

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

