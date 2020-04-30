//
//  ViewController.swift
//  Example
//
//  Created by Chi Hoang on 30/4/20.
//  Copyright © 2020 Hoang Nguyen Chi. All rights reserved.
//

import UIKit
import NCHControl


struct TabItem {
    let title: String
    let image: UIImage
}

class ViewController: UIViewController {
    
    
    let items = {
        return [TabItem(title: "File", image: UIImage(named: "file")!),
                TabItem(title: "Love", image: UIImage(named: "love")!),
                TabItem(title: "Tool", image: UIImage(named: "tool")!),
                TabItem(title: "More", image: UIImage(named: "more")!)]
    }()
    
    var control: NCHControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.test()
    }
    
    func test() {
        control = NCHControl(frame: CGRect(x: 20,
                                           y: 200,
                                           width: self.view.frame.width - 40,
                                           height: 54))
        control.dataSource = self
        control.layer.cornerRadius = 4.0
        control.layer.borderWidth = 1.0
        control.layer.borderColor = UIColor.green.cgColor
        self.view.addSubview(control)
        control.reloadData()
    }
}

//MARK: NCHControlDelegate
extension ViewController: NCHControlDelegate {
    func numberOfItems(inTab tabSwitcher: NCHControl) -> Int {
        return self.items.count
        
    }
    
    func tab(_ tabSwitcher: NCHControl, titleAt index: Int) -> String {
        items[index].title
    }
    
    func tab(_ tabSwitcher: NCHControl, iconAt index: Int) -> UIImage {
        items[index].image
    }
}


