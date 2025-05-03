import AVFoundation
import SwiftUI

@MainActor
final class AudioManager: NSObject, ObservableObject {
    static let shared = AudioManager()

    // Published
    @Published private(set) var tracks : [Track] = []
    @Published private(set) var current: Track?  = nil
    @Published var isPlaying = false
    @Published var currentTime = 0.0
    @Published var duration    = 0.0
    
    private var player : AVPlayer?
    private var timeObs: Any?
    
    private override init() {
        super.init()
        configureSession()
        loadTracks()
        observeInterruptions()
    }
    
    // MARK: public
    func play(_ t: Track) {
        guard current?.url != t.url else { toggle(); return }
        stop()
        current = t
        player  = AVPlayer(url:t.url)
        duration = CMTimeGetSeconds(player?.currentItem?.asset.duration ?? .zero)
        addTimeObserver()
        player?.play(); isPlaying = true
    }
    func toggle() {
        guard let p = player else { return }
        if isPlaying { p.pause() } else { p.play() }
        isPlaying.toggle()
    }
    func stop() {
        removeTimeObserver()
        player?.pause(); player = nil
        isPlaying = false
        currentTime = 0; duration = 0
    }
    
    // MARK: private helpers --------------------------------------------------
    private func configureSession() {
        let s = AVAudioSession.sharedInstance()
        try? s.setCategory(.playback, mode:.default, options:[])
        try? s.setActive(true)
    }
    private func loadTracks() {
        let exts = ["mp3","m4a","aac","wav"]
        let urls = exts.flatMap {
            Bundle.main.urls(forResourcesWithExtension:$0, subdirectory:nil) ?? [] }
        tracks = urls.sorted { $0.lastPathComponent < $1.lastPathComponent }
                     .map { Track(url:$0) }
    }
    private func addTimeObserver() {
        guard let p = player else { return }
        timeObs = p.addPeriodicTimeObserver(
            forInterval: CMTime(seconds:0.5, preferredTimescale:600),
            queue: .main
        ){ [weak self] t in self?.currentTime = t.seconds }
    }
    private func removeTimeObserver() {
        if let o = timeObs { player?.removeTimeObserver(o) }
        timeObs = nil
    }
    private func observeInterruptions() {
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil, queue: .main)
        { [weak self] n in
            guard let user = n.userInfo,
                  let type = user[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
            if type == AVAudioSession.InterruptionType.began.rawValue {
                self?.isPlaying = false
            } else if type == AVAudioSession.InterruptionType.ended.rawValue {
                if let opt = user[AVAudioSessionInterruptionOptionKey] as? UInt,
                   opt & AVAudioSession.InterruptionOptions.shouldResume.rawValue != 0 {
                    self?.player?.play(); self?.isPlaying = true
                }
            }
        }
    }
}

// MARK: – Track
struct Track: Identifiable, Equatable {
    let id = UUID(); let url: URL
    var name: String {
        url.deletingPathExtension().lastPathComponent
            .replacingOccurrences(of:"_", with:" ")
    }
}
