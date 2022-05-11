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

public protocol PlayerProtocol {
    
    var isPlaying: Bool { get }
    
    func play()
    func pause()
    func set(videoUrl: URL?)
    func set(audioUrl url: URL?)
    
}

public class UIPlayerVLCView: UIViewBase, PlayerProtocol, VLCMediaPlayerDelegate {
    
    // MARK: Private Properties
    
    private var mediaPlayer: VLCMediaPlayer = VLCMediaPlayer()
//    private var audioPlayer: VLCMediaPlayer = VLCMediaPlayer()
    
    private let enableAudio = true
    
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
        
        mediaPlayer.delegate = self
        mediaPlayer.drawable = self
        
//        addGestureRecognizer(UKTapGestureRecognizer(tapClosure: onPlayerTapped))
    }
    
    // MARK: VLCMediaPlayerDelegate
    
    public func mediaPlayerStateChanged(_ aNotification: Notification) {
        let state: VLCMediaPlayerState = mediaPlayer.state
        print("UIPlayerVLCView player state: \(state.localizedDescription)")
    }
    
    // MARK: PlayerVLCProtocol
    
    public var isPlaying: Bool {
        mediaPlayer.isPlaying
    }
    
    public func play() {
        mediaPlayer.play()
        if enableAudio == true {
//            audioPlayer.play()
        }
    }
    
    public func pause() {
        mediaPlayer.pause()
        if enableAudio == true {
//            audioPlayer.pause()
        }
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
    
    // MARK: Private Functions
    
    private func didSetUrl() {
        guard let url = url else {
            mediaPlayer.media = nil
            return
        }
        
        let media: VLCMedia =  VLCMedia(url: url)
        // Set media options
        // https://wiki.videolan.org/VLC_command-line_help
        //media.addOptions([
        //    "network-caching": 300
        //])
        mediaPlayer.media = media
    }
    
    private func didSetAudioUrl() {
        if enableAudio == false {
            return
        }
        
        guard let url = audioUrl else {
//            audioPlayer.media = nil
            return
        }
//        let media = VLCMedia(url: url)
//        audioPlayer.media = media
        mediaPlayer.addPlaybackSlave(url, type: .audio, enforce: true)
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
        case .ended:
            result = "VLCMediaPlayerState.ended"        // Stream has ended
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
}
