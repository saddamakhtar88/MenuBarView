//
//  ViewController.swift
//  MenuBarViewSample
//
//  Created by Saddam Akhtar on 6/22/20.
//  Copyright © 2020 personal. All rights reserved.
//

import UIKit
import MenuBarView

class ViewController: UIViewController {

    @IBOutlet weak var menuBar1: MenuBarView!
    @IBOutlet weak var menuBar2: MenuBarView!
    @IBOutlet weak var lblText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuBar1.menuSpacing = 24
        menuBar1.activeMenuHighlightHeight = 4.0
        menuBar1.bottomBorderColor = UIColor.brown
        
        let labels: [String] = ["Menu 1", "Menu 2", "Menu Menu 1", "Menu", "Last Menu may scroll"]
        menuBar1.setMenu(labels: labels, defaultActive: 2)
        
        menuBar1.contentEdgeInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        menuBar1.activeMenuIndex = 2
        
        menuBar2.delegate = self
        menuBar2.menuSpacing = 24
        menuBar2.activeMenuHighlightHeight = 6.0
        menuBar2.activeMenuHighlightColor = UIColor.black
        menuBar2.contentEdgeInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        menuBar2.setMenu(labels: ["Underline", "Segment"])
        menuBar2.style = .Segment
        menuBar2.activeMenuHighlightColor = UIColor.brown
    }
}

extension ViewController: MenuBarProtocol {
    func onActiveMenuChange(index: Int) {
        if index == 0 {
            menuBar1.style = .Underline
        } else {
            menuBar1.style = .Segment
        }
    }
    
    func decorateMenu(button: UIButton, forIndex: Int) {
        print("Index: \(forIndex)")
        print("Selected Index: \(menuBar1.activeMenuIndex)")
        
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
    }
}
