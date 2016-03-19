//
//  Search.swift
//  WWDC
//
//  Created by Laurent Mihalkovic on 3/19/16.
//  Copyright © 2016 Laurent Mihalkovic. All rights reserved.
//

import UIKit
import RealmSwift

class SearchResultsViewController : UICollectionViewController, UISearchResultsUpdating, SearchResultCellDelegate {
  
    private var filteredDataItems: Results<Session>? = AppModel.sharedModel.allSessions
    
    private let cellDecorator = SearchResultCellDecorator()
    
    var searchString = "" {
        didSet {
            guard searchString != oldValue else { return }
            
            if searchString.isEmpty {
                filteredDataItems = AppModel.sharedModel.allSessions
            } else {
                AppModel.sharedModel.sessionsMatchingSearchString(searchString, onComplete: { [weak self] data in
                    self?.filteredDataItems = data
                    self?.collectionView?.reloadData()
                })
            }
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        searchString = ""
    }
  
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        searchString = searchController.searchBar.text ?? ""
    }
    
    // MARK: Collection data source

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (filteredDataItems?.count)!
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Dequeue a cell from the collection view.
        return collectionView.dequeueReusableCellWithReuseIdentifier("SearchResultCell", forIndexPath: indexPath)
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? SearchResultCell else { fatalError("Expected to display a `SearchResultCell`.") }
        let item = filteredDataItems?[indexPath.row]
        
        // Configure the cell.
        cellDecorator.configureCell(cell, usingCellActionDelegate:self, withDataItem: item!)
    }
    
    override func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true;
    }

    func cellPressEnded(cell:SearchResultCell, withButton button:UIPressType) {
        if let session = cell.data as? Session {
            let key = "\(session.year)-\(session.id)"
            switch button {
            case UIPressType.PlayPause:
                // TODO: fix this
                if let url = NSURL(string: "wwdc://show/\(key)") {
//                if let url = NSURL(string: "wwdc://play/\(key)") {
                    UIApplication.sharedApplication().openURL(url)
                }
                
            case UIPressType.Select:
                if let url = NSURL(string: "wwdc://show/\(key)") {
                    UIApplication.sharedApplication().openURL(url)
                }

            default:
                break
            }
        }
    }
    
}

protocol SearchResultCellDelegate:class {
    func cellPressEnded(cell:SearchResultCell, withButton:UIPressType)
}

class SearchResultCell : UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var btn: UIButton!
    
    var data:AnyObject?
    weak var delegate: SearchResultCellDelegate?
    
    func prepareCellForUse() {
        delegate = nil
        data = nil
    }
    
    override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        animateSelection(true)
        super.pressesBegan(presses, withEvent: event)
    }
    
    override func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        animateSelection(false)
        for press in presses {
            if(press.type == UIPressType.Select || press.type == UIPressType.PlayPause) {
                delegate?.cellPressEnded(self, withButton: press.type)
            } else {
                super.pressesEnded(presses, withEvent: event)
            }
        }
    }
    
    override func pressesCancelled(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        animateSelection(false)
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)
        if let prevFocusedView = context.previouslyFocusedView as? SearchResultCell {
            prevFocusedView.showFocusOff()
        }
        
        if let nextFocusedView = context.nextFocusedView as? SearchResultCell {
            nextFocusedView.showFocusOn()
        }
        
    }
    
}

extension UICollectionViewCell {
    func animateSelection(selected: Bool) {
        do {
            let from = !selected ? CGSizeMake(0,3) : CGSizeMake(-2,15)
            let to = selected ? CGSizeMake(0,3) : CGSizeMake(-2,15)
            layer.shadowOffset = to
            let anim = CABasicAnimation(keyPath: "shadowOffset")
            anim.duration = 0.2
            anim.fromValue = NSValue(CGSize: from)
            layer.addAnimation(anim, forKey: "shadowOffset")
        }
        
        do {
            let from: CGFloat = !selected ? 6.0 : 15.0
            let to: CGFloat = selected ? 6.0 : 15.0
            layer.shadowRadius = to
            let anim = CABasicAnimation(keyPath: "shadowRadius")
            anim.duration = 0.2
            anim.fromValue = from
            layer.addAnimation(anim, forKey: "shadowRadius")
        }
    }
    
    func showFocusOn() {
        UIView.animateWithDuration(0.2, animations: {
            self.transform = CGAffineTransformMakeScale(1.1, 1.1)
        })
        
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 10.0).CGPath
        
        self.contentView.backgroundColor = UIColor.whiteColor()
        self.contentView.layer.mask = mask
    
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 20.0).CGPath
        self.layer.shadowOffset = CGSizeMake(0, 15)
        self.layer.shadowOpacity = 1//0.6
        self.layer.shadowRadius = 15.0
        self.layer.shadowColor = UIColor.lightGrayColor().CGColor
    }
    
    func showFocusOff() {
        UIView.animateWithDuration(0.2, animations: {
            self.transform = CGAffineTransformIdentity
        })
        self.contentView.backgroundColor = nil
        self.contentView.layer.mask = nil
        
        self.layer.shadowPath = nil
        self.layer.shadowOffset = CGSizeMake(0, 0)
        self.layer.shadowOpacity = 0
        self.layer.shadowRadius = 0
        self.layer.shadowColor = nil
    }
    
}

class SearchResultCellDecorator {

    func configureCell(cell:SearchResultCell, usingCellActionDelegate delegate: SearchResultCellDelegate?, withDataItem session:Session) {
        cell.title.text = session.title
        cell.subTitle.text = session.subtitle
        
        cell.data = session
        cell.delegate = delegate
    }
    
}
