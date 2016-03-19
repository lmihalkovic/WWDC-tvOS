//
//  SessionsViewController.swift
//  WWDC
//
//  Created by Laurent Mihalkovic on 3/19/16.
//  Copyright © 2016 Laurent Mihalkovic. All rights reserved.
//

import UIKit


class SessionsViewController : UISplitViewController {
  
    var year:String?

    var sessionsListViewController: VideosViewController {
        get {
            return self.viewControllers[0].childViewControllers[0] as! VideosViewController
        }
    }
    
}