import SwiftUI

struct ModeToggle: View {
    @Binding var mode: ExerciseMode

    var body: some View {
        Picker("Modalità", selection: $mode) {
            Label("Dettato", systemImage: "ear").tag(ExerciseMode.dictation)
            Label("Pronuncia", systemImage: "mic").tag(ExerciseMode.pronunciation)
        }
        .pickerStyle(.segmented)
        .labelsHidden()
    }
}
