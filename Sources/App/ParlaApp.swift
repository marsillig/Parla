import SwiftUI

@main
struct ParlaApp: App {
    @State private var engine = SessionEngine()

    var body: some Scene {
        Window("Parla", id: "main") {
            ContentView()
                .environment(engine)
                .frame(minWidth: 640, idealWidth: 860, minHeight: 500, idealHeight: 660)
                .accentColor(Design.Color.accent)
        }
        .defaultSize(width: 860, height: 660)
        .windowResizability(.contentMinSize)
    }
}
