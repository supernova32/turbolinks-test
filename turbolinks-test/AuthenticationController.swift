//
//  AuthenticationController.swift
//  turbolinks-test
//
//  Created by Patricio Cano on 2/22/17.
//  Copyright © 2017 EasyBroker. All rights reserved.
//

import UIKit
import WebKit

protocol AuthenticationControllerDelegate: class {
    func authenticationControllerDidAuthenticate(authenticationController: AuthenticationController)
}

class AuthenticationController: UIViewController {
    var url: URL?
    var webViewConfiguration: WKWebViewConfiguration?
    weak var delegate: AuthenticationControllerDelegate?
    
    lazy var webView: WKWebView = {
        let configuration = self.webViewConfiguration ?? WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webView)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: [ "view": webView ]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: [ "view": webView ]))
        
        if let local_url = self.url {
            webView.load(URLRequest(url: local_url))
        }
    }
}

extension AuthenticationController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let URL = navigationAction.request.url, URL != self.url {
            decisionHandler(.cancel)
            delegate?.authenticationControllerDidAuthenticate(authenticationController: self)
            return
        }
        
        decisionHandler(.allow)
    }
}
