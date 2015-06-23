//
//  PlayerViewController.swift
//  vk-music
//
//  Created by Danylo Kostyshyn on 9/20/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

import UIKit
import MediaPlayer

private var _sharedPlayerViewController: PlayerViewController!

protocol PlayerViewControllerDelegate: class {
    func playerViewControllerPlayPauseButtonPressed(playerViewController: PlayerViewController!)
    func playerViewControllerPauseButtonPressed(playerViewController: PlayerViewController!)
    func playerViewControllerPreviousTackButtonPressed(playerViewController: PlayerViewController!)
    func playerViewControllerNextTackButtonPressed(playerViewController: PlayerViewController!)
    func playerViewController(playerViewController: PlayerViewController!, progressSliderValueChanged value: Float)
}

class PlayerViewController: UIViewController {
    
    static let sharedInstance = PlayerViewController.instantiateFromStoryBoard()
    
    @IBOutlet weak var albumArtImageView: UIImageView!
    @IBOutlet weak var trackNumberLabel: UILabel!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var fastRewindButton: UIButton!
    @IBOutlet weak var volumeView: MPVolumeView!

    private var navigationBarView = NSBundle.mainBundle().loadNibNamed("PlayerNavigationBarView", owner: nil, options: nil)[0] as! UIView
    weak var delegate: PlayerViewControllerDelegate?
    
    // MARK: - Private Methods
    
    private class func instantiateFromStoryBoard() -> PlayerViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        return storyboard.instantiateViewControllerWithIdentifier("playerViewController") as! PlayerViewController
    }
    
    // MARK: - Public Methods
    
    func clearTrackInfo() {
        (self.navigationBarView.viewWithTag(1) as! UILabel).text = nil
        (self.navigationBarView.viewWithTag(2) as! UILabel).text = nil
        (self.navigationBarView.viewWithTag(3) as! UILabel).text = nil
        
        self.albumArtImageView?.image = UIImage(named: "AlbumCoverPlaceHolder")
        self.trackNumberLabel?.text = "1 of 1"
    }
    
    func updateTackInfo () {
        self.clearTrackInfo()
        
        if let track = AudioPlayer.sharedAudioPlayer.currentTrack {
            (self.navigationBarView.viewWithTag(1) as! UILabel).text = track.title
            (self.navigationBarView.viewWithTag(2) as! UILabel).text = track.artist
            
            if track.title == nil && track.artist == nil {
                (self.navigationBarView.viewWithTag(3) as! UILabel).text = track.fileName
            }
            
//            if let image = track.albumArt {
//                self.albumArtImageView.image = image
//            }
            
            let index = AudioPlayer.sharedAudioPlayer.playlist?.indexOfTrack(track)
            let count = AudioPlayer.sharedAudioPlayer.playlist?.count()
            if let index = index { self.trackNumberLabel?.text = "\(index+1) of \(Int(count!))" }
        }
    }

    func updateProgress() {
        self.progressSlider.value = Float(AudioPlayer.sharedAudioPlayer._stk_audioPlayer.progress / AudioPlayer.sharedAudioPlayer._stk_audioPlayer.duration)
        
        let elapsed = AudioPlayer.sharedAudioPlayer._stk_audioPlayer.progress as NSTimeInterval
        self.elapsedTimeLabel.text = Utilities.prettifyTime(elapsed)

        let remaining = (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.duration - AudioPlayer.sharedAudioPlayer._stk_audioPlayer.progress) as NSTimeInterval
        self.remainingTimeLabel.text = "-\(Utilities.prettifyTime(remaining))"
    }
    
    func configureControlButtons() {
        switch (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) {
            case .Ready, .Paused, .Stopped, .Error, .Disposed:
                self.playButton.setImage(UIImage(named: "UIButtonBarPlay"), forState: .Normal)
            case .Playing, .Buffering:
                self.playButton.setImage(UIImage(named: "UIButtonBarPause"), forState: .Normal)
            default: break
        }
    }
    
    func configure() {
        self.updateProgress()
        self.configureControlButtons()
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = .None
        self.navigationItem.titleView = navigationBarView
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateProgress", userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.hidden = true

        self.updateTackInfo()
        self.configure()
        self.updateProgress()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func playButtonPressed(sender: AnyObject) {
        self.delegate?.playerViewControllerPlayPauseButtonPressed(self)
        self.updateTackInfo()
        self.configureControlButtons()
    }

    @IBAction func rewindButtonPressed(sender: AnyObject) {
        self.delegate?.playerViewControllerPreviousTackButtonPressed(self)
        self.updateTackInfo()
        self.configure()
    }
    
    @IBAction func fastRewindButtonPressed(sender: AnyObject) {
        self.delegate?.playerViewControllerNextTackButtonPressed(self)
        self.updateTackInfo()
        self.configure()        
    }
    
    @IBAction func progressSliderValueChanged(sender: UISlider) {
        self.delegate?.playerViewController(self, progressSliderValueChanged: sender.value)
    }

}
