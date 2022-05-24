//
//  PlayerVLCView.swift
//  IOSCode
//
//  Created by Yurii Samoienko on 07.05.2022.
//

import UIKit
import MobileVLCKit
import UIKitExtensions
import SwiftUI
import FoundationExtensions
import VLCKitExtensions
import AVFoundation

public protocol PlayerProtocol {
    
    var isPlaying: Bool { get }
    
    func play()
    func pause()
    func set(videoUrl: URL?)
    func set(audioUrl url: URL?)
    func forward(seconds: Int32)
}

public class UIPlayerVLCView: UIViewBase, PlayerProtocol, VLCMediaPlayerDelegate {
    
    // MARK: Private Properties
    
    private var mediaPlayer: VLCMediaPlayer = VLCMediaPlayer()
    private var audioPlayer: VLCMediaPlayer = VLCMediaPlayer()
    private lazy var players = [
        self.mediaPlayer
        ,self.audioPlayer
    ]
    private let avAudioPlayer: AVPlayer? = AVPlayer()
    
    private let enableAudio = true
    private let reverseTracks = false
    private var lastPlayerTime: VLCTime?
    
    //Playing RTSP from internet
    private var url: URL? {
        didSet {
            didSetUrl()
        }
    }
    private var audioUrl: URL? {
        didSet {
            didSetAudioUrl()
        }
    }

    // MARK: Public Functions

    override public func postInit() {
        super.postInit()
        
        backgroundColor = UIColor.gray
        
        players.forEach{
            $0.delegate = self
//            $0.bu
        }
//        mediaPlayer.delegate = self
        mediaPlayer.drawable = self
        audioPlayer.audio?.volume = 0
//        addGestureRecognizer(UKTapGestureRecognizer(tapClosure: onPlayerTapped))
        
        muteAvAudioPlayer()
    }
    
    
    // MARK: VLCMediaPlayerDelegate
    
    public func mediaPlayerStateChanged(_ aNotification: Notification) {
        let player = aNotification.object as? VLCMediaPlayer
        let state: VLCMediaPlayerState
        let playerName: String
        if player === mediaPlayer {
            state = mediaPlayer.state
            playerName = "video"
        } else {
            state = audioPlayer.state
            playerName = "audio"
        }
//        print("UIPlayerVLCView player '\(playerName)' state: \(state.localizedDescription)")
    }
    private var audioIsPlaying = false
    private var videoIsPlaying = false
    private var skipVideoPlayerTimerChange = false
     private var startDone = false
    
    public func mediaPlayerTimeChanged(_ aNotification: Notification) {
        let time = mediaPlayer.time
//        print("UIPlayerVLCView time: \(time.intValue)")
        lastPlayerTime = time
        
        let player = aNotification.object as? VLCMediaPlayer
        
        let avAudioPlayer = self.avAudioPlayer
            let audioPlayer = self.audioPlayer
            let mediaPlayer = self.mediaPlayer
        
        if startDone == false {
            avAudioPlayer?.pause()
            if videoIsPlaying == false,
               player === mediaPlayer {
                videoIsPlaying = true
                mediaPlayer.pause()
            }
            
            if audioIsPlaying == false,
               player === audioPlayer {
                audioIsPlaying = true
                audioPlayer.pause()
            }
            
            if audioIsPlaying && videoIsPlaying {
                startDone = true
                skipVideoPlayerTimerChange = true
                if false {
                    mediaPlayer.time = .zero
                    audioPlayer.time = .zero
                }
                
                if true {
                    audioPlayer.time = mediaPlayer.time
                }
                
                audioPlayer.play()
                debounse(delay: 0.5) {
                mediaPlayer.play()
                }
                if let avAudioPlayer = self.avAudioPlayer {
                    avAudioPlayer.play()
                   unmuteAvAudioPlayer()
//                    debounse(delay: 0.5) {
//                        avAudioPlayer.play()
//                    }
                }
                else  {
                    self.audioPlayer.audio?.volume = 100
                }
            }
            return;
        }
        
        if player === mediaPlayer {
//            print("UIPlayerVLCView time: \(time.intValue)  \(mediaPlayer.state.localizedDescription)")
            
            if skipVideoPlayerTimerChange == false {
                let maxDiff: Int32 = 500 // msec
                
                if true {
                if abs(audioPlayer.time.intValue - time.intValue) > maxDiff {
//                    skipVideoPlayerTimerChange = true
//                    mediaPlayer.time = time
                    audioPlayer.time = time
//                    audioPlayer.time = time.byAdding(msec: 25)
                }
                }
                
                if true, //testInt == 0,
                   let avAudioPlayer = avAudioPlayer {
                    let avAudioMiliseconds = avAudioPlayer.currentTime().miliseconds()
                    let videoMiliseconds = time.intValue
                    if abs(avAudioMiliseconds - Int64(videoMiliseconds)) > 200 {
                        if testInt > 1 {
                            _ = 0
                        }
                        let newCmTime = CMTimeMake(value:
                                                    Int64(videoMiliseconds), timescale: 1000
//                            905, timescale: 1000
                        )
                        if false {
                            let group = DispatchGroup()
                            group.enter()
                            avAudioPlayer.seek(to: newCmTime, completionHandler: { _ in
                                group.leave()
                            })
                            group.wait()
                        }
                        unmuteAvAudioPlayer()
//                        avAudioPlayer.seek(to: newCmTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { _ in
//                            let player = mediaPlayer
//                            if avAudioPlayer.timeControlStatus == .paused
//                            {
//                                avAudioPlayer.play()
//                            }
//                        }
                        setAvSoundPlayerTime(msec: Int64(videoMiliseconds)) {
                            if avAudioPlayer.timeControlStatus == .paused
                            {
                                avAudioPlayer.play()
                            }
                        }
                        print("CORRECTED TIME!!!!!!!!! \(testInt)")
                        testInt += 1
                        //                    abs(avAudioPlayer.seek(to: CMTime(value: CMTimeValue(, timescale: <#T##CMTimeScale#>))
                    }
                }
                
            } else {
                skipVideoPlayerTimerChange = false
            }
            /*if mediaPlayer.isPlaying == true,
               audioPlayer.isPlaying == false,
               audioIsPlaying == false {
//                skipVideoPlayerTimerChange = true
//                mediaPlayer.pause()
//                mediaPlayer.time = time
//                mediaPlayer.play()
                assert(!audioIsPlaying)
                audioIsPlaying = true
                audioPlayer.time = time
                audioPlayer.play()
//                audioPlayer.time = time
                if false {
                debounse(delay: 0.001) {
                    let newTIme = VLCTime(int: 0)!
                    mediaPlayer.time = newTIme
//                    audioPlayer.time = newTIme
                }
                }
            }*/
        }
    }
    private var lastMediaPlayerTimeInt: Int?
    
    // MARK: PlayerVLCProtocol
    
    public var isPlaying: Bool {
        mediaPlayer.isPlaying
    }
    
    private var timer: Timer?
    public func play() {
        if mediaPlayer.state == .paused {
            if false {
            let time = mediaPlayer.time
            mediaPlayer.stop()
            self.mediaPlayer.play()
            mediaPlayer.time = time
//            DispatchQueue.main.async {
//                self.mediaPlayer.play()
//            }
//            return
            }
            if false {
                didSetAudioUrl()
            }
            
            if true {
                audioPlayer.time = mediaPlayer.time
            }
        }
        
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
            return
        }
        
        if false {
            mediaPlayer.position = mediaPlayer.position
        }
        
//        mediaPlayer.play()
        if enableAudio == true {
//            audioPlayer.play()
        }
        
        if let timeBackup = timeBackup {
            mediaPlayer.time = timeBackup
            
//            mediaPlayer.gotoNextFrame()
            self.timeBackup = nil
            didSetAudioUrl()
        }
        
        if let avAudioPlayer = self.avAudioPlayer {
            if true || mediaPlayer.state == .paused {
                avAudioPlayer.play()
//                unmuteAvAudioPlayer()
//                debounse(delay: 0.2) {
//                unmuteAvAudioPlayer()
//                }
            } else {
               
            }
        }
        players.forEach{
            $0.play()
        }
    }
    private var timeBackup: VLCTime?
    public func pause() {
        let mediaPlayer = self.mediaPlayer
        
        if false {
            mediaPlayer.time = VLCTime()
            return;
        }
        if mediaPlayer.isPlaying == true {
            if false {
                if false {
                    self.mediaPlayer.jumpBackward(1)
                    return
                }
                
                let timeInt = mediaPlayer.time.intValue
                let time = VLCTime(int: timeInt)!
                
                let jumpTime: Double = 1
                let doJump = {
                    //                self.mediaPlayer.jumpBackward(1)
                    self.mediaPlayer.time = time
                }
                doJump()
                //            return;
                timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in
                    //
                    //                let testtime = time.intValue
                    //                self.mediaPlayer.time = time
                    doJump()
                })
            }
            
            if false {
//                mediaPlayer.time = mediaPlayer.time
                let timeOld = mediaPlayer.time.intValue
                let timeOld64 = Int64(timeOld)
                let timeNew = mediaPlayer.getTimeMsec()
                print("timeOld: \(timeOld), timeNew: \(timeNew), isNewBigger: \(timeNew > timeOld64)")
                let maxTime = max(timeNew, timeOld64)
                mediaPlayer.pause()
//                mediaPlayer.time = VLCTime(int: Int32(maxTime))
//                mediaPlayer.setTimeMsec(maxTime + 1000)
//                mediaPlayer.nextChapter()
//                mediaPlayer.position = mediaPlayer.position
//            timeBackup = mediaPlayer.time
//                for _ in 0...1 {
//                    mediaPlayer.gotoNextFrame()
//                }
                return
            }
//            mediaPlayer.stop()
//            return
            if false {
//            mediaPlayer.pause()
                mediaPlayer.clearPlaybackSlaves()
                return;
            }
            
            if false {
                timeBackup = mediaPlayer.time
            }
            
            if false {
                timeBackup = mediaPlayer.time
                mediaPlayer.clearPlaybackSlaves()
                debounse(delay: 2) {
                    self.didSetAudioUrl()
//                    self.mediaPlayer.time = self.timeBackup!
                }
                return;
            }
            
            if false {
                mediaPlayer.pause()
//                mediaPlayer.audio?.passthrough = true
                let time = mediaPlayer.time
                print("time: \(time.intValue) lastPlayerTime: \(lastPlayerTime?.intValue ?? 0)")
                let position = mediaPlayer.position
//                mediaPlayer.time = time
                debounse(delay: 0.1) {
                    mediaPlayer.play()
                    self.debounse(delay: 0.1) {
//                        mediaPlayer.position = 0.013663879
//                        mediaPlayer.position = 0.025
//                        mediaPlayer.time = time
//                        mediaPlayer.position = position
                    }
                }
            }
        }
        
        players.forEach{
            $0.pause()
        }
        avAudioPlayer?.pause()
muteAvAudioPlayer()
//        mediaPlayer.time = mediaPlayer.time
//        mediaPlayer.pause()
        if enableAudio == true {
//            audioPlayer.pause()
        }
//        mediaPlayer.gotoNextFrame()
    }
    
    public func set(videoUrl url: URL?) {
        self.url = url
    }
    
    public func set(audioUrl url: URL?) {
        if enableAudio == false {
            return
        }
        
        self.audioUrl = url
    }
    
    public func forward(seconds: Int32) {
        let isPlaying = self.isPlaying
        muteAvAudioPlayer()
        if isPlaying == true {
            avAudioPlayer?.pause()
            mediaPlayer.pause()
        }
        mediaPlayer.time = mediaPlayer.time.byAdding(seconds: seconds)
        if isPlaying == true {
            mediaPlayer.play()
        } else {
            if false,let avAudioPlayer = self.avAudioPlayer {
                //to avoid sound glitch
                muteAvAudioPlayer()
                avAudioPlayer.play()
                setAvSoundPlayerTime(msec: Int64(mediaPlayer.time.intValue)) {
                    avAudioPlayer.pause()
                    self.unmuteAvAudioPlayer()
                }
            }
        }
//        debounse(delay: 0.1) {
//            self.mediaPlayer.play()
//        }
    }
    
    // MARK: Private Functions
    
    private func setAvSoundPlayerTime(msec: Int64, completion: @escaping () -> Void = {}) {
        let newCmTime = CMTimeMake(value: Int64(msec), timescale: 1000)
        avAudioPlayer?.seek(to: newCmTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { _ in
            completion()
        }
    }
    
    private func muteAvAudioPlayer() {
//        avAudioPlayer?.volume = 0
        avAudioPlayer?.isMuted = true
    }
    
    private func unmuteAvAudioPlayer() {
        guard let avAudioPlayer = self.avAudioPlayer
        else {
            return
        }
//        if avAudioPlayer.volume != 100 {
//            avAudioPlayer.volume = 100
//        }
        if avAudioPlayer.isMuted == true {
            avAudioPlayer.isMuted = false
        }
    }
    
    private func didSetUrl() {
        guard let url = url else {
            mediaPlayer.media = nil
            return
        }
        if reverseTracks == false {
            let media: VLCMedia =  VLCMedia(url: url)
            // Set media options
            // https://wiki.videolan.org/VLC_command-line_help
            //media.addOptions([
            //    "network-caching": 300
            //])
            mediaPlayer.media = media
        } else {
            mediaPlayer.addPlaybackSlave(url, type: .audio, enforce: true)
        }
    }
    
    private func didSetAudioUrl() {
        let mediaPlayer = self.audioPlayer
        if enableAudio == false {
            return
        }
        
        guard let url = audioUrl else {
//            audioPlayer.media = nil
            return
        }
        if let avAudioPlayer = self.avAudioPlayer {
            avAudioPlayer.replaceCurrentItem(with: AVPlayerItem(url: url))
        }
//        else
        if true || reverseTracks == true {
            let media = VLCMedia(url: url)
            mediaPlayer.media = media
        } else {
            mediaPlayer.addPlaybackSlave(url, type: .audio, enforce: false)
        }
    }

    private func onPlayerTapped(_ gestureRecognizer: UKTapGestureRecognizer) {
        let mediaPlayer = self.mediaPlayer
        if mediaPlayer.isPlaying {
            pause()

            let remaining = mediaPlayer.remainingTime
            let time = mediaPlayer.time

            print("Paused at \(time.stringValue ) with \(remaining?.stringValue ?? "nil") time remaining")
        }
        else {
            play()
            print("Playing")
        }
    }
}

extension VLCMediaPlayerState: Describable {
    
    public var localizedDescription: String {
        let result: String
        switch self {
        case .stopped:
            result = "VLCMediaPlayerState.stopped"      // Player has stopped
        case .opening:
            result = "VLCMediaPlayerState.opening"      // Stream is opening
        case .buffering:
            result = "VLCMediaPlayerState.buffering"    // Stream is buffering
//        case .ended:
//            result = "VLCMediaPlayerState.ended"        // Stream has ended
        case .error:
            result = "VLCMediaPlayerState.error"        // Player has generated an error
        case .playing:
            result = "VLCMediaPlayerState.playing"      // Stream is playing
        case .paused: 
            result = "VLCMediaPlayerState.paused"       // Stream is paused
        case .esAdded:
            result = "VLCMediaPlayerState.esAdded"      // Elementary Stream added
            
//        case .stopping:
//            result = "VLCMediaPlayerState.stopping"     // Player is stopping
//        case .esDeleted:
//            result = "VLCMediaPlayerState.esDeleted"    //  Elementary Stream deleted
//        case .lengthChanged:
//            result = "VLCMediaPlayerState.lengthChanged"
        @unknown default:
            result = "unknown"
        }
        return result
    }
    
}

// SwiftUI support

public struct PlayerVLCView: UIViewRepresentable, PlayerProtocol {
//    @Binding var text: NSMutableAttributedString
    private let view = UIPlayerVLCView()

    // MARK: UIViewRepresentable
    
    public func makeUIView(context: Context) -> UIPlayerVLCView {
        return view
    }

    public func updateUIView(_ uiView: UIPlayerVLCView, context: Context) {
//        uiView.attributedText = text
    }
    
    // MARK: PlayerVLCProtocol
    
    public var isPlaying: Bool {
        view.isPlaying
    }
    
    public func play() {
        view.play()
    }
    
    public func pause() {
        view.pause()
    }
    
    public func set(videoUrl url: URL?) {
        view.set(videoUrl: url)
    }
    
    public func set(audioUrl url: URL?) {
        view.set(audioUrl: url)
    }
    
    public func forward(seconds: Int32) {
        view.forward(seconds: seconds)
    }
}


extension VLCTime {
    static var zero: VLCTime {
        get {
            return VLCTime(int: 0)!
        }
    }
    
    func byAdding(msec: Int32) -> Self {
        return .init(int: self.intValue + msec)
    }
    
    func byAdding(seconds: Int32) -> Self {
        return self.byAdding(msec: seconds * 1000)
    }
}

extension CMTime {
    func miliseconds() -> Int64 {
        let value = self.value
        let timescale: CMTimeScale = self.timescale
        let miliseconds : Double = Float64(value)/Float64(timescale)*1000
        if testInt > 0 {
            _ = 0
        }
        return Int64(miliseconds)
    }
}


fileprivate var testInt = 0
