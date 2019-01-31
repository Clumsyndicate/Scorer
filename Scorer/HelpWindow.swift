//
//  HelpWindow.swift
//  Scorer
//
//  Created by Johnson Zhou on 17/09/2018.
//  Copyright © 2018 Johnson Zhou. All rights reserved.
//

import Cocoa
import WebKit

class HelpWindow: NSViewController {

    @IBOutlet weak var webView: WKWebView!
    
    var helpMenu: NSHelpManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        let myURL = URL(string:"https://www.apple.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        
        
    }

}
