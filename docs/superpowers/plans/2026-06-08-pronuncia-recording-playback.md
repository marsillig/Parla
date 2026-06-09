# Pronuncia Recording Playback Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a "La mia voce" button in PronunciationView that plays back the user's recording for comparison against correct TTS.

**Architecture:** Single-file change to `PronunciationView.swift`. Add an `AVAudioPlayer` state variable, a playback function, and a button in the feedback area HStack.

**Tech Stack:** SwiftUI, `AVAudioPlayer`

---

### Task 1: Add recording playback to PronunciationView

**Files:**
- Modify: `Sources/App/Views/PronunciationView.swift`

- [ ] **Step 1: Add audioPlayer state** — add `@State private var audioPlayer: AVAudioPlayer?` alongside existing state vars (line ~12).

- [ ] **Step 2: Add playRecording function** — add after `playCurrentPhrase` (after line ~320):

```swift
private func playRecording() {
    guard let url = recordingURL else { return }
    audioPlayer?.stop()
    audioPlayer = try? AVAudioPlayer(contentsOf: url)
    audioPlayer?.play()
}
```

- [ ] **Step 3: Add "La mia voce" button in feedback area** — insert between "Ascolta" and "Prossima" in the HStack (around line ~250-255):

```swift
Button(action: playRecording) {
    Label("La mia voce", systemImage: "waveform.path.mic")
}
.buttonStyle(SecondaryButtonStyle())
.disabled(recordingURL == nil)
```

- [ ] **Step 4: Clean up on retry and nextPhrase** — in `retry()` (line ~303-308), add before resets:

```swift
audioPlayer?.stop()
audioPlayer = nil
```

And in `nextPhrase()` (line ~310-315), add before resets:

```swift
audioPlayer?.stop()
audioPlayer = nil
```

- [ ] **Step 5: Build and verify**

Run: `bash build-app.sh`

- [ ] **Step 6: Commit**

```bash
git add Sources/App/Views/PronunciationView.swift
git commit -m "feat: add recording playback button to pronuncia view"
git push
```
