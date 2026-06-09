# Pronuncia — Recording Playback Design

## Goal
Allow the user to hear their own recording after speaking, so they can compare it against the correct TTS pronunciation and identify errors.

## Constraints
- Recording is not stored beyond the current exercise (discarded on `nextPhrase` / `retry`)
- No new files or services — changes only to `PronunciationView.swift`
- Follows existing patterns (AVAudioPlayer inline, `@State` lifecycle)

## Design

### State
Add to `PronunciationView`:
```swift
@State private var audioPlayer: AVAudioPlayer?
```

The existing `recordingURL: URL?` already holds the recording file path returned by `AudioCaptureService.stopRecording()`.

### Playback Logic
- `playRecording()` creates an `AVAudioPlayer` from `recordingURL`, calls `player.play()`
- If `audioPlayer` already exists (previous playback in same exercise), stop and replace
- On `retry()` and `nextPhrase()`: `audioPlayer?.stop()`, set to `nil`
- Error handling: if `AVAudioPlayer` init fails (corrupt file, etc.), silently ignore — no crash

### UI
Add a button in the feedback area HStack, between "Ascolta" and "Prossima":

```
[Riprova]  [Ascolta]  [La mia voce]  [Prossima]
```

- Label: `Label("La mia voce", systemImage: "waveform.path.mic")`
- Style: `SecondaryButtonStyle()` (same as Ascolta)
- Disabled when `recordingURL == nil`
- Tapping restarts playback from the beginning

### Lifecycle
| Event | Action |
|-------|--------|
| Recording stops, transcription completes | `recordingURL` is set → button becomes enabled |
| User taps "La mia voce" | Play audio from `recordingURL` |
| User taps "Riprova" | Stop playback, nil player, reset recording |
| User taps "Prossima" | Stop playback, nil player, reset recording |
| User taps "La mia voce" again while playing | Stop current, restart from beginning |

## Files Changed
- `Sources/App/Views/PronunciationView.swift` — add state, playback function, button

## Testing
- Recording plays back audibly
- Button disabled when no recording
- Playback stops cleanly on nextPhrase/retry
- Error in playback file doesn't crash
