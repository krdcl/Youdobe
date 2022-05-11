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
    
    // MARK: Public Properties
    
    public var body: some View {
        ZStack {
            if true {
                let avPlayer = AVPlayer()
                
                VideoPlayer(player: avPlayer)
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
                            
                            let videoPlayerItem = AVPlayerItem(url: videoUrl)
                            videoPlayerItem.preferredForwardBufferDuration = 1
                            
                            avPlayer.replaceCurrentItem(with: videoPlayerItem)
                            avPlayer.play()
                        }
                    }
            }
        else if false {
            let player = PlayerVLCView()
            player.onAppear {
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
            .onTapGesture {
                if player.isPlaying == true {
                    player.pause()
                } else {
                    player.play()
                }
            }
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
                    if false {
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
                    }
                    
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
