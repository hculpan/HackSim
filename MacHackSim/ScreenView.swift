//
//  GraphView.swift
//  hacksim
//
//  Created by Harry Culpan on 6/14/17.
//  Copyright © 2017 Harry Culpan. All rights reserved.
//

import Cocoa

class ScreenView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        NSColor.white.setFill()
        NSRectFill(bounds)
    }
    
}
