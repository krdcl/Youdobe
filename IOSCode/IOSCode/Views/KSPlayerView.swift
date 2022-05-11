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
    
    // MARK: Private Properties
    
    private let playerView = IOSVideoPlayerView()
    
    // MARK: Public Functions
    
    public override func postInit() {
        super.postInit()
        
        addSubview(playerView)
        playerView.fillSuperviewFrame()
    }

    // MARK: PlayerVLCProtocol
    
    public var isPlaying: Bool {
        false
    }
    
    public func play() {
        
    }
    
    public func pause() {
        
    }
    public func set(videoUrl: URL?) {
        
    }
    public func set(audioUrl url: URL?) {
        
    }
}

// SwiftUI support

public struct PlayerKSView: UIViewRepresentable, PlayerProtocol {
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
