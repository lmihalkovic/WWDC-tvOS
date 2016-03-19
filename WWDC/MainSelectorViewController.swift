//
//  MainSelectorViewController.swift
//  WWDC
//
//  Created by Laurent Mihalkovic on 3/19/16.
//  Copyright © 2016 Laurent Mihalkovic. All rights reserved.
//

import UIKit
import RealmSwift

class RootMenuViewController: UITabBarController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureTabItems()
        
    }
    
    var sessionYears: [Int] = []
    var allSessions: Results<Session>? {
        didSet {
            // compute sorted list of years
            var years = Set<Int>()
            for session in allSessions! {
                years.insert(session.year)
            }
            sessionYears = years.sort { $0 > $1 }            
        }
    }
    
    func configureTabItems() {
        addChildViewController(createSearchViewController())
        for year in AppModel.sharedModel.sessionYears {
            viewControllers?.insert(createSessionsViewController("\(year)"), atIndex: (viewControllers!.count - 1))
        }
    }
  
    func createSearchViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let searchResultsController = storyboard.instantiateViewControllerWithIdentifier("SearchResultsViewController") as? SearchResultsViewController else {
            fatalError("Unable to instatiate a SearchResultsViewController from the storyboard.")
        }
        
        let searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = searchResultsController
        searchController.searchBar.placeholder = NSLocalizedString("Search for session", comment: "")
        
        let searchContainer = UISearchContainerViewController(searchController: searchController)
        searchContainer.title = NSLocalizedString("Search", comment: "")
        
        let searchNavigationController = UINavigationController(rootViewController: searchContainer)
        return searchNavigationController
    }
    
    func createSessionsViewController(year:String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let sessionsViewController = storyboard.instantiateViewControllerWithIdentifier("SessionsViewController") as? SessionsViewController else {
            fatalError("Unable to instatiate a SessionsViewController from the storyboard.")
        }

        sessionsViewController.year = year
        sessionsViewController.title = year
        
        return sessionsViewController
    }
    
    func displaySession(key: String) {
        guard case (let year, let id) = splitKeyComponents(key),
            let sessionYear = year,
            let sessionId = id else { return }
        
        if let (index ,childVC) = findViewController(forYear: sessionYear) {
            if self.selectedIndex != index {
                self.selectedIndex = index
            }
            childVC.sessionsListViewController.displaySession(sessionId)
            childVC.setNeedsFocusUpdate()
        }
    }
    
    func playSession(key: String) {
        guard case (let year, let id) = splitKeyComponents(key),
              let sessionYear = year,
              let sessionId = id else { return }
        
        if let (index ,childVC) = findViewController(forYear: sessionYear) {
            if self.selectedIndex != index {
                self.selectedIndex = index
            }
            childVC.sessionsListViewController.playSession(sessionId)
            childVC.setNeedsFocusUpdate()
        }
        
    }

    private func findViewController(forYear year:String) ->(Int, SessionsViewController)? {
        if let controllers = self.viewControllers {
            for index in 0..<controllers.count {
                if let childVC = controllers[index] as? SessionsViewController {
                    if childVC.year == year { return (index, childVC ) }
                }
            }
        }
        // CANNOT HAPPEN
        return nil
    }
    
    private func splitKeyComponents(key:String) -> (String?,String?) {
        let strSplit = key.characters.split("-")
        guard strSplit.count == 2 else { return (nil,nil) }

        return (String(strSplit[0]), String(strSplit[1]))
    }
    
}
