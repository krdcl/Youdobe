//
//  ContentView.swift
//  MacYoudobe
//
//  Created by Yurii Samoienko on 28.04.2022.
//

import SwiftUI
import AVKit
import FoundationExtensions
//import Bagel
import MobileVLCKit

public struct ContentView: View {
    
    private let youtubeDLWrapperPl: YoutubeDownloaderPl = YoutubeDownloader()
    private let urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default // .background(withIdentifier: "backgroundURLSessionIdentifier_239y2397y2")
        configuration.networkServiceType = .responsiveAV
        
        let urlSession = URLSession(configuration: configuration)
        return urlSession
    }()
//    private var audioPlayer: AVAudioPlayer?
    
    // MARK: Public Properties
    
//    mutating private func set(audioUrl: URL) {
//        self.audioPlayer = try? AVAudioPlayer(contentsOf: audioUrl)
//    }
    
    public var body: some View {
        ZStack {
            if false {
                let player = PlayerKSView()
                player
                    .onAppear {
                        youtubeDLWrapperPl.testMe { requestsAudioVideo in
                            guard let requests = requestsAudioVideo.first,
                                  let videoUrl = requests.video.url,
                                  let audioUrl = requests.audio.url
                            else {
                                return
                            }
                            print("video url: \(videoUrl.absoluteString)")
                            print("audio url: \(audioUrl.absoluteString)")
                            
                            player.set(videoUrl: videoUrl)
                            player.set(audioUrl: audioUrl)
                            player.play()
                        }
                    }
//                    .onTapGesture {
//                        if player.isPlaying == true {
//                            player.pause()
//                        } else {
//                            player.play()
//                        }
//                    }
            }
            else if false {
                let avPlayer = AVPlayer()
                let audioPlayer = AVPlayer()
//                var audioPlayer = AVAudioPlayer(contentsOfURL: url)
//                var audioPlayerObj: AVAudioPlayer?
                // This will represent a common clock using the host time
                let audioClock = CMClockGetHostTimeClock()
                
                
                VideoPlayer(player: avPlayer)
                    .onAppear { //[self] in
                        try? AVAudioSession.sharedInstance().setCategory(.playback)
                        
                        youtubeDLWrapperPl.testMe { requestsAudioVideo in
                            guard let requests = requestsAudioVideo.first,
                                  let videoUrl = requests.video.url,
                                  let audioUrl = requests.audio.url
                            else {
                                return
                            }
                            print("video url: \(videoUrl.absoluteString)")
                            print("audio url: \(audioUrl.absoluteString)")
                            
                            if true {
                            let videoPlayerItem = //YPlayerItem(videoUrl: videoUrl, audioUrl: audioUrl) //
//                                        AVPlayerItem(url: videoUrl)
//                                    AVPlayerItem(url: audioUrl)
//                                    AVPlayerItem(asset: AVAsset(url: audioUrl))
//                                      AVPlayerItem(asset: AVURLAsset(url: audioUrl))
                                          AVPlayerItem(asset: YAsset(videoUrl: videoUrl, audioUrl: audioUrl))
//                                        AVPlayerItem(url: audioUrl)
//                            videoPlayerItem.preferredForwardBufferDuration = 1
                            
                            
                            avPlayer.replaceCurrentItem(with: videoPlayerItem)
                            } else {
                                let videoAsset = AVURLAsset(url: videoUrl)
                                let videoAssetTracks = videoAsset.tracks(withMediaType:.video)
                                let videoAssetAllTracks = videoAsset.tracks
                                guard let videoAssetTrack = videoAssetTracks.first
                                else {
                                    fatalError("videoAssetTracks.count: \(videoAssetTracks.count)")
                                    return
                                }
                                
                                let duration: CMTime = videoAsset.duration
                                print("duration", CMTimeGetSeconds(duration)) // 46.17946666666667
                                let composition = AVMutableComposition()
                                let videoTrack = composition.addMutableTrack(
                                    withMediaType: AVMediaType.video,
                                    preferredTrackID:kCMPersistentTrackID_Invalid
                                )
                                try? videoTrack?.insertTimeRange(CMTimeRange(start:CMTime.zero, duration: duration), of: videoAssetTrack, at: CMTime.zero)
                                
                                if true {
                                    let audioAsset = AVURLAsset(url: audioUrl)
                                    let audioAssetTracks = audioAsset.tracks(withMediaType:.audio)
                                    
                                    guard let audioAssetTrack = audioAssetTracks.first
                                    else {
                                        fatalError("audioAssetTrack.count: \(audioAssetTracks.count)")
                                        return
                                    }
                                    let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
                                    try? audioTrack?.insertTimeRange(CMTimeRange(start:CMTime.zero, duration: duration), of: audioAssetTrack, at: CMTime.zero)
                                }
                                
                                let playerItem = AVPlayerItem(asset: composition)
                                
                                avPlayer.replaceCurrentItem(with: playerItem)
                            }
                            
//                            self.set(audioUrl: audioUrl)
                            
//                            audioPlayer.replaceCurrentItem(with: AVPlayerItem(url: audioUrl))
                            
                            
//                            func audioPlay(at time: TimeInterval = 0, hostTime: UInt64 = 0) {
//                                audioPlayer.play(when: time, hostTime: hostTime)
//                            }
//
//                            func schedulePlayback(videoTime: TimeInterval, audioTime: TimeInterval, hostTime: UInt64 ) {
//                                audioPlay( audioTime, hostTime: hostTime )
//                                videoPlay(at: 0, hostTime: hostTime)
//                            }
//
//                            func videoPlay(at time: TimeInterval = 0, hostTime: UInt64 = 0 ) {
//                                let cmHostTime = CMClockMakeHostTimeFromSystemUnits(hostTime)
//                                let cmVTime = CMTimeMakeWithSeconds(time, 1000000)
//                                let futureTime = CMTimeAdd(cmHostTime, cmVTime)
//                                videoPlayer.setRate(1, time: kCMTimeInvalid, atHostTime: futureTime)
//                            }
                            
                            
                            for player in [avPlayer
                                           , audioPlayer
                            ] {
                                player.masterClock = audioClock
//                                player.automaticallyWaitsToMinimizeStalling = false
                            }
                            avPlayer.play()
//                            audioPlayer.play()
//                            self.audioPlayer?.play()
                        }
                    }
                    .onTapGesture {
                        if avPlayer.timeControlStatus == .playing {
                            avPlayer.pause()
                            audioPlayer.pause()
                        } else {
                            avPlayer.play()
                            audioPlayer.play()
                        }
                    }
            }
        else if true {
            let player = PlayerVLCView()
            
            player
                .onAppear {
                    youtubeDLWrapperPl.testMe { requestsAudioVideo in
                        guard let requests = requestsAudioVideo.first
                        else {
                            return
                        }
                        var videoUrl = requests.video.url
                        var audioUrl = requests.audio.url
                        
                        if false {
                            videoUrl = URL(string: "https://multiplatform-f.akamaihd.net/i/multi/will/bunny/big_buck_bunny_,640x360_400,640x360_700,640x360_1000,950x540_1500,.f4v.csmil/master.m3u8")
                        }
                        
                        print("video url: \(videoUrl?.absoluteString ?? "")")
                        print("audio url: \(audioUrl?.absoluteString ?? "")")
                        player.set(videoUrl: videoUrl)
                        player.set(audioUrl: audioUrl)
                        player.play()
                    }
                }
//                .onTapGesture {
//                    
//                }
//                .onTapGesture(count: 2) {
//                    player.forward(seconds: 30)
//                }
                .onTapGesture {
                    if player.isPlaying == true {
                        player.pause()
                    } else {
                        player.play()
                    }
                }
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                    .onEnded({ value in
                                        if value.translation.width < 0 {
                                            // left
                                            player.forward(seconds: -30)
                                        }

                                        if value.translation.width > 0 {
                                            // right
                                            player.forward(seconds: 30)
                                        }
                                        if value.translation.height < 0 {
                                            // up
                                        }

                                        if value.translation.height > 0 {
                                            // down
                                        }
                                    }))
        } else {
//        let vlcPlayer = VLCMediaPlayer
        
        let avPlayer = AVQueuePlayer() //playerItem: AVPlayerItem(asset: AVAssetDownloadDelegate))
        
        VideoPlayer(player: avPlayer) //  (url:  URL(string: "https://bit.ly/swswift")!))
//            .frame(height: 400)
        .onAppear {
//            Bagel.start()
            
            // Display the currently supported audio and video formats
            print("po AVURLAsset.audiovisualTypes()")
            print("po AVURLAsset.audiovisualMIMETypes()")
            
            // Print the asset to get it.
//            asset type (
//                "audio/aacp"."video/3gpp2"."audio/mpeg3"."audio/mp3"."audio/x-caf"."audio/mpeg"."video/quicktime"."audio/x-mpeg3"."video/mp4"."audio/wav"."video/avi"."audio/scpls"."audio/mp4"."audio/x-mpg"."video/x-m4v"."audio/x-wav"."audio/x-aiff"."application/vnd.apple.mpegurl"."video/3gpp"."text/vtt"."audio/x-mpeg"."audio/wave"."audio/x-m4r"."audio/x-mp3"."audio/AMR"."audio/aiff"."audio/3gpp2"."audio/aac"."audio/mpg"."audio/mpegurl"."audio/x-m4b"."application/mp4"."audio/x-m4p"."audio/x-scpls"."audio/x-mpegurl"."audio/x-aac"."audio/3gpp"."audio/basic"."audio/x-m4a"."application/x-mpegurl"
//            )
//            Co
            
                youtubeDLWrapperPl.testMe { requestsAudioVideo in
                    print("youtubeDLWrapperPl.testMe)")
                    /*if false {
                        let urlSession = self.urlSession
                                             
//                        DispatchQueue.background.async {
                        
                        let queueGroup = DispatchGroup()
                        
                        for index in 0..<min(requestsAudioVideo.count, 2) {
                            queueGroup.enter()
                            
                            let group = DispatchGroup()
                            group.enter()
                        
                        let requestData = requestsAudioVideo[index]
                            let videoUrl = requestData.video // URLRequest(url: URL(string: "https://bit.ly/swswift")!)//
                            let audioUrl = requestData.audio
                            
                            var videoAsset: AVAsset!
                        urlSession.runDataTask(with: videoUrl) { data, response, error in
                            DispatchQueue.main.async {
                                if let asset = data?.getAVAsset() {
                                    videoAsset = asset
                                } else {
                                    fatalError()
                                }
                                group.leave()
                            }
                        }
//                            urlSession.runDownloadTask(with: videoUrl) { url, response, error in
//                                if let error = error {
//                                    printFuncLog(error: error)
//                                }
//                                else if let url = url {
//                                    videoAsset = AVURLAsset(url: url)
//                                }
//                                group.leave()
//                            }
                            
                            var audioAsset: AVAsset!
                            group.enter()
                        urlSession.runDataTask(with: audioUrl) { data, response, error in
                            DispatchQueue.main.async {
                                
                                if let asset = data?.getAVAsset() {
                                    audioAsset = asset
                                } else {
                                    fatalError()
                                }
                                group.leave()
                            }
                            }
//                            urlSession.runDownloadTask(with: audioUrl) { url, response, error in
//                                if let error = error {
//                                    printFuncLog(error: error)
//                                }
//                                else if let url = url {
//                                    audioAsset = AVURLAsset(url: url)
//                                }
//                                group.leave()
//                            }
//                            group.enter()
//                        urlSession.downloadTask(with: videoUrl) { url, response, error in
//                                if let url = url  {
//                                    videoAsset = AVAsset(url: url)
//                                }
//                                group.leave()
//                            }.priority = URLSessionTask.highPriority
//                            group.wait()
                        
                            
                            
                            group.notify(queue: .main) { [index] in
                                defer {
                                    queueGroup.leave()
                                }
                                let duration: CMTime = CMTimeMultiplyByRatio(videoAsset.duration, multiplier: 1, divisor: Int32(requestData.duration))
                                print("duration", CMTimeGetSeconds(duration)) // 46.17946666666667
                                
                                let composition = AVMutableComposition()
                                let videoTrack = composition.addMutableTrack(
                                    withMediaType: AVMediaType.video,
                                    preferredTrackID:kCMPersistentTrackID_Invalid
                                )
                                let audioTrack = composition.addMutableTrack(
                                    withMediaType: .audio,
                                    preferredTrackID: kCMPersistentTrackID_Invalid
                                )
                                
                                let videoAssetTracks = videoAsset.tracks(withMediaType:.video)
                                let audioAssetTracks = audioAsset.tracks(withMediaType:.audio)
                                
                                guard let videoAssetTrack = videoAssetTracks.first,
                                      let audioAssetTrack = audioAssetTracks.first
                                else {
                                    fatalError("index: \(index), videoAssetTracks.count: \(videoAssetTracks.count), audioAssetTrack.count: \(audioAssetTracks.count)")
                                    return
                                }

                                try? videoTrack?.insertTimeRange(
                                    CMTimeRange(start:CMTime.zero, duration: duration),
                                    of: videoAssetTrack, at: CMTime.zero
                                )
                                try? audioTrack?.insertTimeRange(CMTimeRange(start:CMTime.zero, duration: duration), of: audioAssetTrack, at: CMTime.zero)
                                let playerItem = AVPlayerItem(asset: composition)
                                
                                //                                avPlayer.replaceCurrentItem(with: playerItem)
                                avPlayer.insert(playerItem)
                        }
//                        }
                        }
                        queueGroup.notify(queue: .main) {
                            avPlayer.play()
                        }
                        
                        return
                    }*/
                    
                    let data = requestsAudioVideo[0]
                    
                    let video = data.video
                    let audio = data.audio
                    
                    var videoUrl = video.url
                    if false  {
                        videoUrl = URL(string:
//                                        "https://multiplatform-f.akamaihd.net/i/multi/will/bunny/big_buck_bunny_,640x360_400,640x360_700,640x360_1000,950x540_1500,.f4v.csmil/master.m3u8"
                                       "https://lpa3da-ch3301.files.1drv.com/y4mlAVKqlK43YeGSdHaixFN11_Gd2riYDJoTUmeRooiMCygoikTLQ_3YVVSkzr9OKJ_LDZ1-z7Pv1KSDUWdFVpE9b2pTVvFE41jwMS19cwkdbdT0msa9b73DASk8Ox7slz8EDQeN24ufgPOaebLY9xunzTJk9-chfbE6YobXfDb7tf9SqISbQqOXUK6gYtFgOTj7voT9PR_Z8CZBkvLf8Wuyg/LG-Daylight-4K-(www.demolandia.net).ts?download&psid=1"
                        )
                    }
                    
                    print("video url: \(videoUrl?.absoluteString ?? "")")
//                    avPlayer.replaceCurrentItem(with: AVPlayerItem(url: videoUrl!))
                    
//                    let headers: [String: String] = [
//                        "custome_header": "custome value"
//                     ]
//                     let asset = AVURLAsset(url: URL, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
//                     let playerItem = AVPlayerItem(asset: asset)
//                     player = AVPlayer(playerItem: item)
                    
                    let videoAsset = AVURLAsset(url: videoUrl!, options: video.allHTTPHeaderFields! )//AVURLAsset(url: videoURL)
                    print("let videoAsset = AVURLAsset(url: videoUrl!)")
                    /*
                     po videoAsset.tracks
                     po audioAsset.tracks
                     */
                    
                    let videoAssetTracks = videoAsset.tracks(withMediaType:.video)
                    
                    guard let videoAssetTrack = videoAssetTracks.first
                    else {
                        fatalError("videoAssetTracks.count: \(videoAssetTracks.count)")
                        return
                    }
                    
                    let duration: CMTime = videoAsset.duration
                    print("duration", CMTimeGetSeconds(duration)) // 46.17946666666667
                    let composition = AVMutableComposition()
                    let videoTrack = composition.addMutableTrack(
                        withMediaType: AVMediaType.video,
                        preferredTrackID:kCMPersistentTrackID_Invalid
                    )
                    try? videoTrack?.insertTimeRange(CMTimeRange(start:CMTime.zero, duration: duration), of: videoAssetTrack, at: CMTime.zero)
                    
                    if true {
                        let audioAsset = AVURLAsset(url: video.url!, options: video.allHTTPHeaderFields!)
//                        let audioAsset = AVURLAsset(url: audio.url!, options: audio.allHTTPHeaderFields!)
                        
                        
                        print("let audioAsset = AVURLAsset(url: audio.url")
                        let audioAssetTracks = audioAsset.tracks(withMediaType:.audio)
                        
                        guard let audioAssetTrack = audioAssetTracks.first
                        else {
                            fatalError("audioAssetTrack.count: \(audioAssetTracks.count)")
                            return
                        }
                        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
                        try? audioTrack?.insertTimeRange(CMTimeRange(start:CMTime.zero, duration: duration), of: audioAssetTrack, at: CMTime.zero)
                    }
                    
                    let playerItem = AVPlayerItem(asset: composition)
                    
                    avPlayer.replaceCurrentItem(with: playerItem)
                    avPlayer.play()
                }
            }
    }
        }
        .onAppear {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
    }
    
    // MARK: Public Functions
    
    public init() {
        youtubeDLWrapperPl.setup()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Data {
    func getAVAsset() -> AVAsset {
        let directory = NSTemporaryDirectory()
        let fileName = "\(NSUUID().uuidString).mov"
        let fullURL = NSURL.fileURL(withPathComponents: [directory, fileName])
        try! self.write(to: fullURL!)
        let asset = AVAsset(url: fullURL!)
        return asset
    }
}

extension AVURLAsset {
    
    var fileSize: Int64 {
//        let keys: Set<URLResourceKey> = [.totalFileSizeKey, .fileSizeKey]
//        let resourceValues = try? url.resourceValues(forKeys: keys)
//
//        return resourceValues?.fileSize ?? resourceValues?.totalFileSize ?? 0
        
//        let assetSizeBytes =  tracks(withMediaType: .video)  tracksWithMediaType(AVMediaTypeVideo).first?.totalSampleDataLength
        // File
        let fileOnDiskSizeBytes =  (try? FileManager.default.attributesOfItem(atPath: url.absoluteString)[FileAttributeKey.size] as? NSNumber)?.int64Value ?? 0//   try! NSFileManager.defaultManager().attributesOfItemAtPath("...")[NSFileSize] as! NSNumber
        return fileOnDiskSizeBytes
    }
    
}

extension AVQueuePlayer {
    
    func insert(_ item: AVPlayerItem) {
        insert(item, after: items().last)
    }
}

public extension URLSession {
    
    // MARK: Public Functions
    
    @discardableResult
    func runDownloadTask(with request: URLRequest, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask {
        let task = downloadTask(with: request, completionHandler: completionHandler)
        task.resume()
        return task
    }
    
    @discardableResult
    func runDownloadTask(with url: URL, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask {
        let task = downloadTask(with: url, completionHandler: completionHandler)
        task.resume()
        return task
    }
    
}

fileprivate class YPlayerItem: AVPlayerItem {
    
    private var audioItem: AVPlayerItem?
    
    public convenience init(videoUrl: URL, audioUrl: URL) {
        self.init(url: videoUrl)
        audioItem = AVPlayerItem(url: audioUrl)
    }
    
    override var tracks: [AVPlayerItemTrack] {
        get {
            let videoTracks = super.tracks.filter { $0.assetTrack?.mediaType == .video}
            let audioTracks: [AVPlayerItemTrack] = audioItem?.tracks.filter { $0.assetTrack?.mediaType == .audio} ?? []
            return videoTracks + audioTracks
        }
    }
}

open class YAsset: AVURLAsset {
    
//    private var audioAsset: AVAsset?
//    private var awefewfwe: Int?
    
    public convenience init(videoUrl: URL, audioUrl: URL) {
        self.init(url: videoUrl)
//        awefewfwe = 23
        let audioAsset = AVURLAsset(url: audioUrl)
//        self.audioAsset = test
//        audioAsset = AVAsset(url: audioUrl)
        
        referencesMapAVAssettoYAsset.setObject(audioAsset, forKey: self)
        _ = 0
    }
    
    //called
    override open var tracks: [AVAssetTrack] {
        return []
        let videoTracks = super.tracks.filter { $0.mediaType == .video}
        let audioAsset = referencesMapAVAssettoYAsset.object(forKey: self)
        let audioTracks: [AVAssetTrack] = audioAsset?.tracks.filter { $0.mediaType == .audio} ?? []
        
//        return audioTracks // test
        
        return videoTracks + audioTracks
    }
    //not called
    override open var trackGroups: [AVAssetTrackGroup] {
     return []
    }
    
    // called
    override open var availableMediaCharacteristicsWithMediaSelectionOptions: [AVMediaCharacteristic] {
        []
    }
    
    // not called
    override open var allMediaSelections: [AVMediaSelection] {
        []
    }
    
    // called
    override open func track(withTrackID trackID: CMPersistentTrackID) -> AVAssetTrack? {
        return nil
        let audioAsset = referencesMapAVAssettoYAsset.object(forKey: self)
        return audioAsset?.track(withTrackID: trackID) ?? super.track(withTrackID: trackID)
    }
    //called
    override open func tracks(withMediaType mediaType: AVMediaType) -> [AVAssetTrack] {
        return []
        print("mediaType: \(mediaType.rawValue)")
        let audioAsset = referencesMapAVAssettoYAsset.object(forKey: self)
        let audioTracks = audioAsset?.tracks(withMediaType: mediaType) ?? []
        let videoTracks = super.tracks(withMediaType: mediaType)
        
//        return audioTracks // test
        
//        if audioTracks.isNotEmpty {
//            return audioTracks
//        }
        return videoTracks
    }
    //called
    override open func mediaSelectionGroup(forMediaCharacteristic mediaCharacteristic: AVMediaCharacteristic) -> AVMediaSelectionGroup? {
        return nil
    }
    
    // not called
    override open func compatibleTrack(for compositionTrack: AVCompositionTrack) -> AVAssetTrack? {
        return nil
    }
    
    override open func tracks(withMediaCharacteristic mediaCharacteristic: AVMediaCharacteristic) -> [AVAssetTrack] {
        let audioAsset = referencesMapAVAssettoYAsset.object(forKey: self)
        return audioAsset?.tracks(withMediaCharacteristic: mediaCharacteristic) ?? super.tracks(withMediaCharacteristic: mediaCharacteristic)
    }
    
    // not called
    @available(iOS 15.0, *)
    override open func loadTrack(withTrackID trackID: CMPersistentTrackID, completionHandler: @escaping (AVAssetTrack?, Error?) -> Void) {
        let audioAsset = referencesMapAVAssettoYAsset.object(forKey: self)
        return audioAsset?.loadTrack(withTrackID: trackID, completionHandler: completionHandler) ?? super.loadTrack(withTrackID: trackID, completionHandler: completionHandler)
    }
    
    // not called
    @available(iOS 15.0, *)
    override open func loadTracks(withMediaType mediaType: AVMediaType, completionHandler: @escaping ([AVAssetTrack]?, Error?) -> Void) {
        let audioAsset = referencesMapAVAssettoYAsset.object(forKey: self)
        return audioAsset?.loadTracks(withMediaType: mediaType, completionHandler: completionHandler) ?? super.loadTracks(withMediaType: mediaType, completionHandler: completionHandler)
    }
    
    // not called
    @available(iOS 15.0, *)
    override open func loadTracks(withMediaCharacteristic mediaCharacteristic: AVMediaCharacteristic, completionHandler: @escaping ([AVAssetTrack]?, Error?) -> Void) {
        let audioAsset = referencesMapAVAssettoYAsset.object(forKey: self)
        return audioAsset?.loadTracks(withMediaCharacteristic: mediaCharacteristic, completionHandler: completionHandler) ?? super.loadTracks(withMediaCharacteristic: mediaCharacteristic, completionHandler: completionHandler)
    }
}

fileprivate let referencesMapAVAssettoYAsset = NSMapTable<NSObject, AVURLAsset>(keyOptions: .weakMemory, valueOptions: .strongMemory)
