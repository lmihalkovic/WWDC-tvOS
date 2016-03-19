//
//  ViewController.swift
//  WWDC
//
//  Created by Guilherme Rambo on 19/11/15.
//  Copyright © 2015 Guilherme Rambo. All rights reserved.
//

import UIKit
import RealmSwift

typealias SessionMapper = ((Session) -> String)

class VideosViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let owner = self.parentViewController?.parentViewController as? SessionsViewController {
            self.year = owner.year
            self.navigationItem.title = year
        }
        
        tableView.remembersLastFocusedIndexPath = true
      
        loadSessions()
    }

    // MARK: Data loading

    var year: String?
    var allSessions: Results<Session>? {
        didSet {
            // refresh table
            tableView.reloadData()
        }
    }
    var sessionId: String?

    private var _sessionGroupingMapper: SessionMapper? = { (session: Session) -> String in
        return session.track
    }
    private var _tableModel: TableModel<Session>? = nil
    var tableModel:TableModel<Session>! {
        get {
            if(_tableModel == nil) {
                if let sessions = allSessions {
                    _tableModel = TableModel(sessions, mapper:_sessionGroupingMapper)
                }
            }
            return _tableModel
        }
    }
    
    func loadSessions() {
        fetchLocalSessions()
    }
    
    func fetchLocalSessions() {
        if let year = self.year {
            allSessions = AppModel.sharedModel.sessionsMatchingYear(year)
        }
    }
  
    // MARK: Session filtering
    @IBAction func yearSelectionChanged(sender: UISegmentedControl) {
        _tableModel = nil
        // refresh table
        tableView.reloadData()
    }

    // MARK: Table View
    
    private struct Storyboard {
        static let videoCellIdentifier = "video"
        static let detailSegueIdentifier = "detail"
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard tableModel != nil else { return 0 }
        return tableModel.countGroups
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(tableModel.groupName(section)!)"
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard tableModel != nil else { return 0 }
        return tableModel.itemsInGroup(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.videoCellIdentifier)!
        
        let session = tableModel.item(indexPath.row, inGroup: indexPath.section)
        cell.textLabel?.text = session?.title
        
        return cell
    }
    
    // MARK: Session selection

    var initialSelectionPath: NSIndexPath?
    var selectedSession: Session? {
        didSet {
            guard selectedSession != nil else { return }
            performSegueWithIdentifier(Storyboard.detailSegueIdentifier, sender: nil)
        }
    }
    

    override func indexPathForPreferredFocusedViewInTableView(tableView: UITableView) -> NSIndexPath? {
        if let path = initialSelectionPath {
            return path
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        guard let indexPath = context.nextFocusedIndexPath else { return }
        
        selectSessionAtIndexPath(indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.detailSegueIdentifier {
            let detailController = segue.destinationViewController as! DetailViewController
            detailController.session = selectedSession
        }
    }
    
    private func selectSessionAtIndexPath(indexPath: NSIndexPath) {
        tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .Middle)
        
        selectedSession = tableModel.item(indexPath.row, inGroup: indexPath.section)
    }
    
    private func indexPathForSessionWithKey(key: String) -> NSIndexPath? {
        guard let sessions = allSessions else { return nil }
        
        for session in sessions where session.id == Int(key) {
            if let indexPath = self.tableModel.indexPathForElement(session) {
                return indexPath
            }
        }
        return nil
    }
    
    // MARK: Session displaying and playback from URLs
    
    private var detailViewController: DetailViewController? {
        guard let splitController = parentViewController?.parentViewController else { return nil }
        guard splitController.childViewControllers.count > 1 else { return nil }
        
        return splitController.childViewControllers[1] as? DetailViewController
    }
    
    func displaySession(key: String) {
        self.view = self.view  // force view loading when first showing
        guard let indexPath = indexPathForSessionWithKey(key) else { return }

        initialSelectionPath = indexPath        
    }

    func playSession(key: String) {
        displaySession(key)

        guard let detailVC = detailViewController else { return }

        delay(0.2) { () -> () in
            detailVC.watch(nil)
        }
        
    }

}

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}
