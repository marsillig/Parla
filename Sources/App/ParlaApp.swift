import SwiftUI

@main
struct ParlaApp: App {
    @State private var engine = SessionEngine()

    var body: some Scene {
        Window("Parla", id: "main") {
            ContentView()
                .environment(engine)
                .frame(minWidth: 720, minHeight: 600, maxHeight: .infinity)
                .accentColor(Design.Color.accent)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 860, height: 660)
    }
}
