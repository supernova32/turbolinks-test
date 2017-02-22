//
//  TurboViewController.swift
//  turbolinks-test
//
//  Created by Patricio Cano on 2/22/17.
//  Copyright © 2017 EasyBroker. All rights reserved.
//

import UIKit
import WebKit
import Turbolinks

class TurboViewController: UINavigationController  {
    let base_url = URL(string: "http://localhost:3000")!
    let webViewProcessPool = WKProcessPool()
    
    var application: UIApplication {
        return UIApplication.shared
    }
    
    lazy var webViewConfiguration: WKWebViewConfiguration = {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: "turbolinks-test")
        configuration.processPool = self.webViewProcessPool
        configuration.applicationNameForUserAgent = "TurbolinksDemo"
        return configuration
    }()
    
    lazy var session: Session = {
        let session = Session(webViewConfiguration: self.webViewConfiguration)
        session.delegate = self
        return session
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        presentVisitableForSession(session: session, url: base_url)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentVisitableForSession(session: Session, url: URL, action: Action = .Advance) {
        let visitable = PagesViewController(url: url)
        
        if action == .Advance {
            pushViewController(visitable, animated: true)
        } else if action == .Replace {
            popViewController(animated: false)
            pushViewController(visitable, animated: false)
        }
        
        session.visit(visitable)
    }
    
    func presentAuthenticationController() {
        let authenticationController = AuthenticationController()
        authenticationController.delegate = self
        authenticationController.webViewConfiguration = webViewConfiguration
        authenticationController.url = base_url.appendingPathComponent("/login")
        authenticationController.title = "Sign in"
        
        let authNavigationController = UINavigationController(rootViewController: authenticationController)
        present(authNavigationController, animated: true, completion: nil)
    }
    
    
}

extension TurboViewController: SessionDelegate {
    func session(_ session: Session, didProposeVisitToURL URL: URL, withAction action: Action) {
        if URL.path == "/login" {
            presentAuthenticationController()
        } else {
            presentVisitableForSession(session: session, url: URL, action: action)
        }
    }
    
    func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, withError error: NSError) {
        NSLog("ERROR: %@", error)
        guard let demoViewController = visitable as? PagesViewController, let errorCode = ErrorCode(rawValue: error.code) else { return }
        
        switch errorCode {
        case .httpFailure:
            let statusCode = error.userInfo["statusCode"] as! Int
            switch statusCode {
            case 401:
                presentAuthenticationController()
            case 404:
                demoViewController.presentError(error: .HTTPNotFoundError)
            default:
                demoViewController.presentError(error: Error(HTTPStatusCode: statusCode))
            }
        case .networkFailure:
            demoViewController.presentError(error: .NetworkError)
        }
    }
    
    func sessionDidStartRequest(session: Session) {
        application.isNetworkActivityIndicatorVisible = true
    }
    
    func sessionDidFinishRequest(session: Session) {
        application.isNetworkActivityIndicatorVisible = false
    }
}

extension TurboViewController: AuthenticationControllerDelegate {
    func authenticationControllerDidAuthenticate(authenticationController: AuthenticationController) {
        session.reload()
        dismiss(animated: true, completion: nil)
    }
}

extension TurboViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let message = message.body as? String {
            let alertController = UIAlertController(title: "Turbolinks", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
}

