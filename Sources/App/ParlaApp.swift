import AVFoundation
import SwiftUI

@main
struct ParlaApp: App {
    @State private var engine = SessionEngine()
    @State private var startupPlayer: AVAudioPlayer?

    var body: some Scene {
        Window("Parla", id: "main") {
            ContentView()
                .environment(engine)
                .frame(width: 860, height: 660)
                .fixedSize()
                .accentColor(Design.Color.accent)
                .task {
                    guard startupPlayer == nil else { return }
                    if let url = Bundle.main.url(forResource: "startup-sound", withExtension: "mp3")
                        ?? Bundle.module.url(forResource: "startup-sound", withExtension: "mp3")
                    {
                        startupPlayer = try? AVAudioPlayer(contentsOf: url)
                        startupPlayer?.volume = 0.6
                        startupPlayer?.play()
                    }
                }
        }
        .windowResizability(.contentSize)
    }
}
