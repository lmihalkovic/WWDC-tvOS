//
//  DetailViewController.swift
//  WWDC
//
//  Created by Guilherme Rambo on 20/11/15.
//  Copyright © 2015 Guilherme Rambo. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

protocol DetailViewControllerDelegate:class {
    
}

class DetailViewController: UIViewController {

    var session: Session! {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var descriptionView: UILabel!
    @IBOutlet weak var watchButton: UIButton!
    @IBOutlet weak var favButton: UIButton!
  
    weak var delegate: DetailViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favButton.showSystemAppearance()
        favButton.hidden = true
        watchButton.hidden = true
        titleLabel.hidden = true
        subtitleLabel.hidden = true
        descriptionView.hidden = true
      
        updateUI()
        
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {

        if (context.nextFocusedView == self.favButton) {
            favButton.showFocusOn()
        } else if (context.previouslyFocusedView == self.favButton) {
            favButton.showFocusOff()
        }
    }
    
    private func updateUI() {
        guard session != nil else { return }
        guard titleLabel != nil else { return }
        
        titleLabel.text = session.title
        subtitleLabel.text = session.subtitle
        descriptionView.text = session.summary
        
        watchButton.hidden = false
        titleLabel.hidden = false
        subtitleLabel.hidden = false
        descriptionView.hidden = false
        
        favButton.hidden = true
//        if(session.favorite) {
//            let img = Star.imageOfStarFilled
//            favButton.setImage(img.imageWithRenderingMode(.AlwaysTemplate), forState:.Normal);
//            favButton.accessibilityLabel = NSLocalizedString("Remove from Favourites", comment:"");
//        } else {
//            let img = Star.imageOfStarStroked
//            favButton.setImage(img.imageWithRenderingMode(.AlwaysTemplate), forState:.Normal);
//            favButton.accessibilityLabel = NSLocalizedString("Add to Favourites", comment:"");
//        }

    }
    
    // MARK: Favourites
    @IBAction func toggleFavorite(sender: AnyObject?) {
        
        WWDCDatabase.sharedDatabase.doChanges({ [unowned self] in
            self.session.favorite = !self.session.favorite
            self.updateUI()
        })
        
    }


    // MARK: Playback
    
    var player: AVPlayer?
    var timeObserver: AnyObject?

// TODO: cleanup 
//    func dissmissVideoPlayer(sender: AnyObject?) {
//        player?.currentItem = nil;
//    }
    
    @IBAction func watch(sender: AnyObject?) {
        let (playerController, newPlayer) = PlayerBuilder.buildPlayerViewController(session.ATVURL.absoluteString, title: session.title, description: session.summary)
        player = newPlayer

//        let menuTouchRecognizer = UITapGestureRecognizer(target: self, action: "dissmissVideoPlayer:")
//        menuTouchRecognizer.allowedPressTypes = [UIPressType.Menu.rawValue]
//        playerController.view.addGestureRecognizer(menuTouchRecognizer)
        
        presentViewController(playerController, animated: true) { [unowned self] in
            self.timeObserver = self.player?.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(5, 1), queue: dispatch_get_main_queue()) { currentTime in
                let progress = Double(CMTimeGetSeconds(currentTime)/CMTimeGetSeconds(self.player!.currentItem!.duration))
                
                WWDCDatabase.sharedDatabase.doChanges {
                    self.session!.progress = progress
                    self.session!.currentPosition = CMTimeGetSeconds(currentTime)
                }
            }
            
            if self.session.currentPosition > 0 {
                self.player?.seekToTime(CMTimeMakeWithSeconds(self.session.currentPosition, 1))
            }
            
            playerController.player?.play()
        }
    }
    
    deinit {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
    }
}
