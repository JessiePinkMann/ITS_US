import SwiftUI

struct MemesView: View {
    @StateObject private var audio = AudioManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            //------------------------------------------------ список треков
            List {
                ForEach(audio.tracks) { track in
                    HStack(spacing: 12) {
                        Image(systemName: icon(for: track))
                            .foregroundColor(track == audio.current ? .pink : .gray)
                            .font(.title3)
                        Text(track.name)
                            .fontWeight(track == audio.current ? .bold : .regular)
                    }
                    .contentShape(Rectangle())      // вся строка тапаемая
                    .onTapGesture { audio.play(track) }
                }
            }
            .listStyle(.insetGrouped)
            
            //------------------------------------------------ прогресс-бар
            if let _ = audio.current, audio.duration > 0 {
                VStack(spacing: 8) {
                    // BAR
                    ProgressView(value: audio.currentTime,
                                 total: audio.duration)
                        .progressViewStyle(.linear)
                        .tint(.pink)
                    
                    // цифры
                    HStack {
                        Text(timeString(audio.currentTime))
                        Spacer()
                        Text("-" + timeString(audio.duration - audio.currentTime))
                    }
                    .font(.caption2).monospacedDigit()
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .navigationTitle("Memes")
    }
    
    // MARK: – helpers
    private func icon(for t: Track) -> String {
        if t == audio.current { return audio.isPlaying ? "pause.circle.fill" : "play.circle" }
        return "play.circle"
    }
    private func timeString(_ sec: Double) -> String {
        let s = Int(sec.rounded())
        return String(format: "%d:%02d", s/60, s%60)
    }
}
