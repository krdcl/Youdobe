//
//  YoutubeDLWrapper.swift
//  IOSCode
//
//  Created by Yurii Samoienko on 29.04.2022.
//

import Foundation
import YoutubeDL
import PythonSupport
import PythonKit
import FoundationExtensions
import CrossPlatformCode



public protocol YoutubeDownloaderPl {
    
    func setup()
    func transcodeDownloadedVideo()
    func testMe(_ completion: @escaping ([TestOutput]) -> Void)
    
}

public struct TestOutput {
    let video: URLRequest
    let audio: URLRequest
    let duration: Int64
}

public class YoutubeDownloader: YoutubeDownloaderPl {
    
    // MARK: Private Properties
    
    private var youtubeDL: YoutubeDL?
    
    private var indeterminateProgressKey: String?
    
    private var isTranscodingEnabled = true
    
    private var isRemuxingEnabled = true
    
    private var showingFormats = false
    
//    private var formatsSheet: ActionSheet?

    private var progress: Progress?
    
    // MARK: Public Functions
    
    public init() {
        
    }
    
    // MARK: YoutubeDownloaderPl
    
    public func testMe(_ completion: @escaping ([TestOutput]) -> Void) {
        guard let url = URL(string:
//                                "https://www.youtube.com/watch?v=mPQqIogek6s" // short 23 sec
//                            "https://www.youtube.com/watch?v=BD_pjm7xvgg" // movie 4k
//                            "https://www.youtube.com/watch?v=LXb3EKWsInQ" // 4k
                            "https://www.youtube.com/watch?v=hXQxSi34GWY" // guitar play
        ) else {
            fatalError()
        }
        extractInfo(url: url) { data in
            switch data {
            case .success(let info):
                let info: Info = info
                do {
                    let videoFormats = info.formats.filter {
                        ($0.ext == "mp4" && $0.vcodec?.contains("avc1") == true ) // video track
                    }
                    let audioFormats = info.formats.filter {
                        ($0.vcodec == "none" && ($0.ext == "webm" || $0.ext == "m4a" )) // audiotrack
                    }
//                    var result: [TestOutput] = []
                    for (index, format) in audioFormats.enumerated() {
                        print("\(index) format: \(format.description), url: \(format.urlRequest?.url?.absoluteString ?? "")\n") // 18 or 24
                    }
                    for (index, format) in videoFormats.enumerated() {
                        print("\(index) format: \(format.description), url: \(format.urlRequest?.url?.absoluteString ?? "")\n") // 18 or 24
                    }
                    
//                    var chunksCount: Int64 = 1
                    if let videoFormat: Format = videoFormats.element(at: 7), //8 20 // (1080p) mp4 avc1 has sound
                       let audioFormat: Format = audioFormats.element(at: 4), //3
//                       let videoUrl = videoFormat.urlRequest,   // audio 3..7
//                       let audioUrl = audioFormat.urlRequest
                        
                        /*let videoUrls = try? self.download(format: videoFormat, start: false, faster: false), //, chunksCountOutput: { chunksCount = $0 }),
                       let audioUrls = try? self.download(format: audioFormat, start: false, faster: false) //, chunkCountInput: chunksCount)
                    {
                        
//                        for (index, videoUrl) in formats.enumerated() {
                        let output: [TestOutput] = zip(videoUrls, audioUrls).map { videoUrl, audioUrl in
                            let duration: Int64 = {
                                guard let (begin, end) = try? videoUrl.getRange(),
                                      let filesize = videoFormat.filesize
                                else {
                                    return nil
                                }
                                let chunkSize = end - begin
                                return filesize/chunkSize
                            }() ?? 1
                            return TestOutput(video: videoUrl, audio: audioUrl, duration: duration)
                        }
                        completion(output)
//                        download(format: format, start: <#T##Bool#>, faster: <#T##Bool#>) { value in
//                            switch value {
//                        }
                         */
                    let videoRequest = videoFormat.urlRequest,
                       let audioRequest = audioFormat.urlRequest
                    {
                        completion([TestOutput(video: videoRequest, audio: audioRequest, duration: 0)])
                        
                    }
//                    try self.check(info: info)
                } catch {
                    print("error: \(error.localizedDescription)")
                }
                
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    public func setup() {
        PythonSupport.initialize()
        
        _ = Downloader.shared // create URL session
    }
    
    public func transcodeDownloadedVideo() {
        Downloader.shared.transcode()
    }
    
    public func extractInfo(url: URL, completion: @escaping (Result<Info, Error>) -> Void) {
        guard let youtubeDL = youtubeDL else {
            loadPythonModule { data in
                switch data {
                case .success(_):
                    self.extractInfo(url: url, completion: completion)
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            return
        }
        
        indeterminateProgressKey = "Extracting info..."
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let (_, info) = try youtubeDL.extractInfo(url: url)
                //                DispatchQueue.main.async {
                self.indeterminateProgressKey = nil
                
                //                    self.check(info: info)
                guard let info = info else {
                    return completion(.failure(NSError(message: "\(#function) info is nil")))
                }
                return completion(.success(info))
                //                }
            }
            catch {
                self.indeterminateProgressKey = nil
                guard let pyError = error as? PythonError,
                        case let .exception(exception, traceback: _) = pyError
                else {
                    return completion(.failure(error))
                }
                let exceptionText = String(exception.args[0]) ?? ""
                if exceptionText.contains("Unsupported URL: ") {
                    return completion(.failure(NSError(message: "\(#function) \(Localization.UnsupportedURL)")))
                } else {
                    return completion(.failure(NSError(message: "\(#function) \(exceptionText)")))
                }
            }
        }
    }
    
    // MARK: Private Functions
    
    private func loadPythonModule(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard FileManager.default.fileExists(atPath: YoutubeDL.pythonModuleURL.path) else {
            downloadPythonModule(completion: completion)
            return
        }
        indeterminateProgressKey = "Loading Python module..."
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                self.youtubeDL = try YoutubeDL()
                self.indeterminateProgressKey = nil
                
//                url.map { extractInfo(url: $0) }
                completion(.success(true))
            }
            catch {
                print(#function, error)
                return completion(.failure(NSError(message: "\(#function) \(error.localizedDescription)")))
            }
        }
    }
    
    private func downloadPythonModule(completion: @escaping (Result<Bool, Error>) -> Void) {
        indeterminateProgressKey = "Downloading Python module..."
        YoutubeDL.downloadPythonModule { error in
            DispatchQueue.main.async {
                self.indeterminateProgressKey = nil
                if let error = error {
                    return completion(.failure(NSError(message: "\(#function) \(error.localizedDescription)")))
                }

                self.loadPythonModule(completion: completion)
            }
        }
    }
    
    /*private func check(info: Info?) throws {
        guard let formats: [Format] = info?.formats else {
            return
        }
        
        let _bestAudio = formats.filter { $0.isAudioOnly && $0.ext == "m4a" }.last
        let _bestVideo = formats.filter {
            $0.isVideoOnly && (isTranscodingEnabled || !$0.isTranscodingNeeded)
        }.last
        let _bestFormat: Format? = formats.filter { !$0.isRemuxingNeeded && !$0.isTranscodingNeeded }.last
        print(_bestFormat ?? "no best?", _bestVideo ?? "no bestvideo?", _bestAudio ?? "no bestaudio?")
        guard let bestFormat = _bestFormat,
              let bestVideo = _bestVideo,
              let bestAudio = _bestAudio,
              let bestHeight = bestFormat.height,
              let bestVideoHeight = bestVideo.height
        else {
            if let best = _bestFormat {
                notify(body: String(format: Localization.DownloadStartFormat, info?.title ?? Localization.NoTitleQuestion))
                try download(format: best, start: true, faster: false)
            } else if let bestVideo = _bestVideo, let bestAudio = _bestAudio {
                try download(format: bestVideo, start: true, faster: true)
                try download(format: bestAudio, start: false, faster: true)
            } else {
                throw NSError(message: Localization.NoSuitableFormat)
            }
            return
        }
        
        formatsSheet = ActionSheet(title: Text("ChooseFormat"), message: Text("SomeFormatsNeedTranscoding"), buttons: [
            .default(Text(String(format: NSLocalizedString("BestFormat", comment: "Alert action"), bestHeight)),
                     action: {
                        self.download(format: best, start: true, faster: false)
                     }),
            .default(Text(String(format: NSLocalizedString("RemuxingFormat", comment: "Alert action"),
                                 bestVideo.ext ?? NSLocalizedString("NoExt?", comment: "Nil"),
                                 bestAudio.ext ?? NSLocalizedString("NoExt?", comment: "Nil"),
                                 bestVideoHeight)),
                     action: {
                        self.download(format: bestVideo, start: true, faster: true)
                        self.download(format: bestAudio, start: false, faster: true)
                     }),
            .cancel()
        ])

        DispatchQueue.main.async {
            showingFormats = true
        }
    }*/
    
    // returns downloaderClosure. Run it in completion(..) when you need next chunk of video
    private func download(format: Format, start: Bool, faster: Bool //, completion: @escaping (Result<Data, Error>) -> Void) throws -> () -> Void
                          , chunkCountInput: Int64? = nil , chunksCountOutput: ((Int64) -> Void)? = nil) throws -> [URLRequest]
    {
//        let kind: Downloader.Kind
//        if format.isVideoOnly == true {
//            if format.isTranscodingNeeded == false {
//                kind = .videoOnly
//            } else {
//                kind = .otherVideo
//            }
//        } else {
//            if format.isAudioOnly == true {
//                kind = .audioOnly
//            } else {
//                kind = .complete
//            }
//        }

        var requests: [URLRequest] = []
        
        guard let size: Int64 = format.filesize else {
            throw NSError(message: "\(#function) no filesize")
        }
        
        let desiredChunkSize: Int64 = 40_000
        
        let chunkSize: Int64
        if let chunkCountInput = chunkCountInput {
            chunkSize = size/chunkCountInput
        }
        else {
            let chunkCount: Int64 = size/desiredChunkSize // Int64((Double(size)/Double(chunkSize)).rounded(.up))
            chunksCountOutput?(chunkCount)
            
            chunkSize = size/chunkCount
        }
//            if !FileManager.default.createFile(atPath: kind.url.part.path, contents: Data(), attributes: nil) {
//                throw NSError(message: "\(#function) FileManager couldn't create \(kind.url.part.lastPathComponent)")
//            }

            var end: Int64 = -1
            while end < size - 1 {
                guard var request = format.urlRequest else {
                    throw NSError(message: "\(#function) request is empty")
                }
                // https://github.com/ytdl-org/youtube-dl/issues/15271#issuecomment-362834889
//                end = request.setRange(start: end + 1, fullSize: size)
                end = request.setRange(start: end + 1,
//                                       chunkSize: chunkSize,
                                       fullSize: size)
                requests.append(request)
            }
//        } else {
//            guard let request = format.urlRequest else {
//                throw NSError(message: "\(#function) request is empty")
//            }
//            requests.append(request)
//        }

        return requests
        
        /*var dataRequests = requests //.map { Downloader.shared.download(request: $0, kind: kind) }
        
        let downloaderClosure = {
            guard let request = dataRequests.first else {
                return
            }
            dataRequests.removeFirst()
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                }
                else if let data = data {
                    completion(.success(data))
                } else {
                    fatalError()
                }
            }
        }
        downloaderClosure()
        return downloaderClosure*/
        
        /*let tasks = requests.map { Downloader.shared.download(request: $0, kind: kind) }

        if start {
            progress = Downloader.shared.progress
            progress?.kind = .file
            progress?.fileOperationKind = .downloading
            do {
                try "".write(to: kind.url, atomically: false, encoding: .utf8)
            }
            catch {
                print("\(#function) error: \(error.localizedDescription)")
            }
            progress?.fileURL = kind.url

            Downloader.shared.t0 = ProcessInfo.processInfo.systemUptime
            tasks.first?.resume()
        }*/
    }
}

let av1CodecPrefix = "av01."

extension Format {
    var isRemuxingNeeded: Bool {
        let result = isVideoOnly || isAudioOnly
        return result
    }
    
    var isTranscodingNeeded: Bool {
        let result: Bool
        if self.ext == "mp4" {
            result = self.vcodec?.hasPrefix(av1CodecPrefix) ?? false
        } else {
          result = self.ext != "m4a"
        }
        return result
    }
}

extension URL {
    var part: URL {
        appendingPathExtension("part")
    }
}


extension URLRequest {
    
    // returns start and end bytes
    public func getRange() throws -> (Int64, Int64) {
        guard let rangeString = value(forHTTPHeaderField: "Range") else {
            throw NSError(logMessage: "'Range' http header not found")
        }
        let rangeNumberStrings = try rangeString.substrings(byRegex: "[\\d]{1,}")
        guard rangeNumberStrings.count == 2 else {
            throw NSError(logMessage: "'Range' http header is invalid: \(rangeString)")
        }
        let rangeStart = try Int64(from: rangeNumberStrings[0])
        let rangeEnd = try Int64(from: rangeNumberStrings[1])
        return (rangeStart, rangeEnd)
    }
}

extension Int64 {
    
    // usage: Int64(from: "123")
    init(from text: String, file: String = #file, line: UInt = #line, function: String = #function) throws {
        guard let result = Int64(text)
        else {
            throw NSError(logMessage: "failed create Int from: \(text)", file: file, line: line, function: function)
        }
        self = result
    }
}

extension Int {
    
    // usage: Int(from: "123")
    init(from text: String, file: String = #file, line: UInt = #line, function: String = #function) throws {
        guard let result = Int(text)
        else {
            throw NSError(logMessage: "failed create Int from: \(text)", file: file, line: line, function: function)
        }
        self = result
    }
}

extension Format {
   
    var ext: String? {
        guard let obj = format["ext"]
        else {
            return nil
        }
        return "\(obj)"
    }
    
    var vcodec: String? {
        guard let obj = format["vcodec"]
        else {
            return nil
        }
        return "\(obj)"
    }
    
}
    
