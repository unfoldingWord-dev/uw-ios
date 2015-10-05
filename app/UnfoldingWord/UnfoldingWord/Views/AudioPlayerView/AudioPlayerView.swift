//
//  AudioPlayerView.swift
//  UnfoldingWord
//
//  Created by David Solberg on 8/31/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class AudioPlayerView : UIView, AVAudioPlayerDelegate {
    
    var player : AVAudioPlayer?
    var timer : NSTimer?
    var url : NSURL?
    
    var chapterInfo : AudioFileInfo?
    
    var downloader : FileDownloader?
    
    var audioData : NSData?
    
    @IBOutlet weak var sliderTime: UISlider! {
        didSet {
            sliderTime.setThumbImage(UIImage(named: "thumb-audio"), forState: UIControlState.Normal)
            sliderTime.minimumTrackTintColor = UIColor(red: 0.0, green: 0.769, blue: 0.980, alpha: 1.0)
        }
    }
    
    @IBOutlet weak var labelTimeLeading: UILabel!
    @IBOutlet weak var labelTimeTrailing: UILabel!
    @IBOutlet weak var buttonPlayPause: UIButton!
    @IBOutlet weak var labelDownloading: UILabel!

    
    var currentTime : NSTimeInterval {
        get {
            if let player = self.player {
                return player.currentTime
            }
            else {
                return 0.0
            }
        }
    }
    
    var duration : NSTimeInterval {
        get {
            if let player = self.player {
                return player.duration
            }
            else {
                return 0.0
            }
        }
    }
    
    var isReady : Bool {
        get {
            if let _ = self.player, _ = self.audioData {
                return true
            }
            else {
                return false
            }
        }
    }
    
    var chapter : Int = 1 {
        didSet {
            delay(0.2) { [weak self] () -> Void in
                self?.updateChapter(chapter)
            }
        }
    }

    @objc class func playerWithUrl(url : NSURL) -> AudioPlayerView? {
        
        let nibViews = NSBundle.mainBundle().loadNibNamed("AudioPlayerView", owner: nil, options: nil)
        let playerView = nibViews[0] as! AudioPlayerView
        playerView.url = url
        playerView.retrieveData()
        playerView.updateTimeUI()
        playerView.translatesAutoresizingMaskIntoConstraints = false
        NSNotificationCenter.defaultCenter().addObserver(playerView, selector: "userScrolledToChapterNotification:", name: nil, object: nil)
        return playerView
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.player = nil
        super.init(coder: aDecoder)
    }
    
    deinit {
        self.player?.stop()
        unscheduleCurrentTimer()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func userScrolledToChapterNotification(notification : NSNotification)  {
        if let userDictionary = notification.userInfo as? [NSString : NSNumber],
            let segment = userDictionary[NotificationKeyAudioSegment] as? Int {
            updateChapter(segment)
        }
    }

    private func retrieveData() {
        
        if let url = self.url where self.player == nil {
            
            if url.fileURL {
                AuditionFileReader.parseFileUrl(url, completion: { [weak self] (audioFileInfo) -> Void in
                    guard let strongself = self else { return }
                    strongself.chapterInfo = audioFileInfo
                })
                createPlayerWithFileUrl(url)
                showPlayerUI()
                return;
            }
            
            self.downloader = FileDownloader(url: url, progress: {[weak self] (percentDone) -> () in
                if let strongself = self {
                    strongself.updateDownloadPercentDownloaded(percentDone)
                }
                }, completion: {[weak self] (success, data) -> () in
                    if let strongself = self, audioData = data where success {
                        AuditionFileReader.parseFileData(audioData, completion: { (audioFileInfo) -> Void in
                            guard let strongself = self else { return }
                            strongself.chapterInfo = audioFileInfo
                        })
                        strongself.createPlayerWithData(audioData)
                        strongself.showPlayerUI()
                    }
                })
            self.downloader?.download()
            showDownloadingUI()
        }
    }
    
    // Outside Methods
    
    func showDownloadingUI() {
        updateDownloadingUI(isDownloading: true)
    }
    
    func showPlayerUI() {
        updateDownloadingUI(isDownloading: false)
    }
    
    func updateDownloadingUI(isDownloading isDownloading : Bool) {
        
        let playOpacity : Float = isDownloading ? 0.0 : 1.0
        let downOpacity : Float = isDownloading ? 1.0 : 0.0
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.sliderTime.hidden = isDownloading
            self.labelTimeLeading.layer.opacity = playOpacity
            self.labelTimeTrailing.layer.opacity = playOpacity
            self.buttonPlayPause.layer.opacity = playOpacity
            self.labelDownloading.layer.opacity = downOpacity
            }) { (didComplete) -> Void in
                
        }
    }
    
    private func updateDownloadPercentDownloaded(percent : Float) {
        let percentWhole = percent * 100.0
        let percentString = String(format: "%.0f%%", arguments: [percentWhole])
        self.labelDownloading.text = "\(percentString) downloaded"
    }
    
    func createPlayerWithData(data : NSData) {
        
        do {
            let createdPlayer = try AVAudioPlayer(data: data)
            createdPlayer.prepareToPlay()
            self.player = createdPlayer
        } catch let error as NSError {
            print("Error creating url \(url): \(error.userInfo)")
            self.player = nil
        }
    }
    
    func createPlayerWithFileUrl(url : NSURL) {
        
        do {
            let createdPlayer = try AVAudioPlayer(contentsOfURL: url)
            createdPlayer.prepareToPlay()
            self.player = createdPlayer
        } catch let error as NSError {
            print("Error creating url \(url): \(error.userInfo)")
            self.player = nil
        }
    }
    
    func playAtTime(time : NSTimeInterval) {

        updateChapterIfNecessary()
        setSliderValuesForChapter(chapter)
        if let player = self.player where time <= player.duration && time >= 0 {
            player.currentTime = time
            player.play()
            scheduleTimer()
        }
        else {
            assertionFailure("Something wrong with playAtTime method")
        }
    }
    
    func pause() {
        if let player = self.player where player.playing == true {
            player.pause()
            updatePlayPauseButton()
            unscheduleCurrentTimer()
        }
    }
    
    func isPlaying() -> Bool {
        if let player = player {
            return player.playing
        }
        else {
            return false
        }
    }
    
    // User Methods from View
    
    @IBAction func userPressedPlayPauseButton(sender: UIButton) {
        if let player = self.player {
            if player.playing {
                pause()
            }
            else {
                playAtTime(Double(sliderTime.value) )
            }
        }
        updateTimeUI()
    }
    
    @IBAction func userChangedSliderValue(slider: UISlider) {
        if let player = self.player {
            
            let time = Double(slider.value)

            if player.playing {
                playAtTime(time)
            }
            else {
                player.currentTime = time
            }
        }
        else {
            self.sliderTime.setValue(0.0, animated: false)
        }
        updateTimeUI()
    }
    
    // Internal Methods
    
    private func updateChapter(aChapter : Int)
    {
        if let player = player, let chapterInfo = self.chapterInfo where chapterInfo.numberOfChapters >= aChapter {
            setSliderValuesForChapter(aChapter)
            let startTime = NSTimeInterval( chapterInfo.startTimeForChapter(aChapter) )
            player.currentTime = startTime
            updateTimeUI()
        }
    }
    
    private func startTimeForChapter(aChapter : Int) -> Float
    {
        if let chapterInfo = chapterInfo where aChapter <= chapterInfo.numberOfChapters {
            return chapterInfo.startTimeForChapter(aChapter)
        }
        return 0.0
    }
    
    private func endTimeForChapter(aChapter : Int) -> Float
    {
        if let chapterInfo = chapterInfo where aChapter < chapterInfo.numberOfChapters {
            return chapterInfo.startTimeForChapter(aChapter + 1)
        }
        else if let player = player {
            return Float(player.duration)
        }
        else {
            return 0.0
        }
    }
    
    private func notifyChangedChapter()
    {
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationAudioSegmentDidChange, object: nil, userInfo: [NotificationKeyAudioSegment : Int(chapter)])
    }
    
    private func setSliderValuesForChapter(aChapter : Int)
    {
        sliderTime.minimumValue = startTimeForChapter(aChapter)
        sliderTime.maximumValue = endTimeForChapter(aChapter)
    }
    
    private func updateTimeUI() {
        updateSliderLabels()
        updateSliderLocation()
        updatePlayPauseButton()
    }
    
    private func updateSliderLabels() {
        if let _ = self.player {
            let adjustedTime = self.currentTime - NSTimeInterval( startTimeForChapter(chapter) )
            labelTimeLeading.text = formattedTime(adjustedTime)
            
            let timeRemaining = NSTimeInterval(endTimeForChapter(chapter)) - self.currentTime
            labelTimeTrailing.text = formattedTime(timeRemaining * -1.0)
        }
        else {
            labelTimeTrailing.text = "-:--"
            labelTimeLeading.text = "-:--"
        }
    }
    
    private func updateSliderLocation() {
        sliderTime.value = Float( currentTime )
    }
    
    func timerFired() {
        updateChapterIfNecessary()
        updateTimeUI()
        if (currentTime + 0.01) >= duration { // play time is over
            unscheduleCurrentTimer()
        }
    }
    
    func updateChapterIfNecessary() -> Bool {
        guard let audioChapterInfo = chapterInfo else { return false }
        
        let time = Float(self.currentTime)
        
        var changedChapter : Int? = nil
        for (_, chapInt) in (1...(audioChapterInfo.numberOfChapters)).enumerate() {
            let chapterEndTime = endTimeForChapter(chapInt)
            if ( time < chapterEndTime) {
                if self.chapter != chapInt {
                    changedChapter = chapInt
                }
                break;
            }
        }
        
        if let changedChapter = changedChapter {
            self.chapter = changedChapter
            notifyChangedChapter()
            return true
        }
        else {
            return false
        }
    }
    
    func updatePlayPauseButton() {
        if let player = self.player {
            let buttonImage = (player.playing) ? "pause" : "play"
            self.buttonPlayPause.setBackgroundImage(UIImage(named: buttonImage), forState: UIControlState.Normal)
        }
    }
    
    /// Returns the formatted time string used on the slider
    private func formattedTime(time : NSTimeInterval) -> String {
        
        let signMultiplier = time < 0 ? -1.0 : 1.0
        let positiveTime = time * signMultiplier
        
        let minutes = Int( floor(positiveTime / 60) * signMultiplier )
        let seconds = Int( floor(positiveTime % 60) )
        
        if seconds < 10 { // add a zero
            return "\(minutes):0\(seconds)"
        }
        else {
            return "\(minutes):\(seconds)"
        }
    }
    
    private func scheduleTimer() {
        unscheduleCurrentTimer()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "timerFired", userInfo: nil, repeats: true)
    }
    
    private func unscheduleCurrentTimer() {
        if let existingTimer = self.timer {
            existingTimer.invalidate()
            self.timer = nil
        }
    }
    
    // AVAudioPlayerDelegate Methods
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        if let error = error {
            assertionFailure("\(error.userInfo)")
        }
    }
    
}
