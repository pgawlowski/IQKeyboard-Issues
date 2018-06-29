//
//  ViewController.swift
//  IQKeyboardSample
//
//  Created by Piotr Gawlowski on 30/06/2018.
//  Copyright © 2018 Piotr Gawlowski. All rights reserved.
//

import IQKeyboardManagerSwift
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysShow
        IQKeyboardManager.shared.toolbarPreviousNextAllowedClasses = [UIStackView.self]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

