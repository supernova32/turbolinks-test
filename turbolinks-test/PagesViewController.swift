//
//  PagesViewController.swift
//  turbolinks-test
//
//  Created by Patricio Cano on 2/22/17.
//  Copyright © 2017 EasyBroker. All rights reserved.
//

import Turbolinks
import UIKit

class PagesViewController: Turbolinks.VisitableViewController {
    lazy var errorView: ErrorView = {
        let view = Bundle.main.loadNibNamed("ErrorView", owner: self, options: nil)!.first as! ErrorView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.retryButton.addTarget(self, action: #selector(retry(sender:)), for: .touchUpInside)
        return view
    }()
    
    func presentError(error: Error) {
        errorView.error = error
        view.addSubview(errorView)
        installErrorViewConstraints()
    }
    
    func installErrorViewConstraints() {
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: [ "view": errorView ]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: [ "view": errorView ]))
    }
    
    func retry(sender: AnyObject) {
        errorView.removeFromSuperview()
        reloadVisitable()
    }
}
