//
//  rowView.swift
//  Scorer
//
//  Created by Johnson Zhou on 07/10/2018.
//  Copyright © 2018 Johnson Zhou. All rights reserved.
//

import Cocoa

class schoolRowView: NSTableRowView {
        
    @IBOutlet var logo: NSImageView?
    @IBOutlet var tf: NSTextField?
        

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
