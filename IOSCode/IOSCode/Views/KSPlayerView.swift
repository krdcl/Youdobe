//
//  KSPlayerView.swift
//  IOSCode
//
//  Created by Yurii Samoienko on 08.05.2022.
//

import UIKit
import UIKitExtensions
import KSPlayer
import SwiftUI

public class UIPlayerKSView: UIViewBase, PlayerProtocol {
    public func forward(seconds: Int32) {
        
    }
    
    
    // MARK: Private Properties
    
    private let playerView = IOSVideoPlayerView()
//    private var audioPlayer: KSMEPlayer?
    
    private var videoUrl: URL?
    private var audioUrl: URL?
    
    private var videoResource: KSPlayerResource?
    private let queue = DispatchQueue.main
    
    // MARK: Public Functions
    
    public override func postInit() {
        super.postInit()
        
        KSPlayerManager.secondPlayerType = KSMEPlayer.self
        addSubview(playerView)
        playerView.fillSuperviewFrame()
    }

    // MARK: PlayerVLCProtocol
    
    public var isPlaying: Bool {
        playerView.playerLayer.state.isPlaying
    }
    
    public func play() {
        updateVideoAsset()
        
        queue.async {
            self.playerView.play()
//            self.audioPlayer?.play()
        }
      
//        playerView.backBlock = { [unowned self] in
//            if UIApplication.shared.statusBarOrientation.isLandscape {
//                self.playerView.updateUI(isLandscape: false)
//            } else {
//                self.navigationController?.popViewController(animated: true)
//            }
//        }
        
//        playerView.set(url:URL(string: "http://baobab.wdjcdn.com/14525705791193.mp4")!)
//        playerView.set(resource: KSPlayerResource(url: url, name: name!, cover: URL(string: "http://img.wdjimg.com/image/video/447f973848167ee5e44b67c8d4df9839_0_0.jpeg"), subtitleURL: URL(string: "http://example.ksplay.subtitle")))
    }
    
    public func pause() {
        playerView.pause()
    }
    
    public func set(videoUrl url: URL?) {
        self.videoUrl = url
        resetVideoResource()
    }
    
    public func set(audioUrl url: URL?) {
        self.audioUrl = url
        resetVideoResource()
    }
    
    // MARK: Private Functions
    
    private func resetVideoResource() {
        videoResource = nil
    }
    
    private func updateVideoAsset() {
        guard videoResource == nil
        else {
            return
        }
        var index = -1
        let definitions: [KSPlayerResourceDefinition] = [
//            audioUrl,
            videoUrl,
            audioUrl
        ].compactMap{ $0 }.map {
            index += 1
            return KSPlayerResourceDefinition(url: $0, definition: "definition \(index)")
        }
       
//        let res0 = KSPlayerResourceDefinition(url: URL(string: "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!,
//                                              definition: "高清")
//        let res1 = KSPlayerResourceDefinition(url: URL(string: "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!,
//                                              definition: "标清")
        
//        audioPlayer = KSMEPlayer(url: audioUrl!, options: KSOptions())
           
        let asset = KSPlayerResource(name: "Big Buck Bunny",
                                     definitions: definitions,
                                     cover: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Big_buck_bunny_poster_big.jpg/848px-Big_buck_bunny_poster_big.jpg"))
        queue.async {
            self.playerView.set(resource: asset)
        }
        videoResource = asset
    }
}

// SwiftUI support

public struct PlayerKSView: UIViewRepresentable, PlayerProtocol {
    public func forward(seconds: Int32) {
        
    }
    
//    @Binding var text: NSMutableAttributedString
    private let view = UIPlayerKSView()

    // MARK: UIViewRepresentable
    
    public func makeUIView(context: Context) -> UIPlayerKSView {
        return view
    }

    public func updateUIView(_ uiView: UIPlayerKSView, context: Context) {
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
