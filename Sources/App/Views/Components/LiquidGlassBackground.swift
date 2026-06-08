import SwiftUI

struct LiquidGlassBackground: View {
    var body: some View {
        Image("backgroundparla", bundle: .module)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
    }
}
