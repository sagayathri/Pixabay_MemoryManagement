//
//  ImageViewController.swift
//  Pixabay
//

import UIKit
import WebKit

class DetailsViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    var pageURL: String?
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: pageURL!)!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
}
