import SwiftUI

struct LiquidGlassBackground: View {
    var isActive: Bool = false

    var body: some View {
        let imageName = isActive ? "backgroundparla_blur" : "backgroundparla"

        if let url = Bundle.main.url(forResource: imageName, withExtension: "png"),
           let image = NSImage(contentsOf: url) {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: isActive)
        } else {
            Color(nsColor: NSColor(red: 0.46, green: 0.46, blue: 0.48, alpha: 1))
                .ignoresSafeArea()
        }
    }
}
