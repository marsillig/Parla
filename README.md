# Parla

Parla is a macOS app for practicing Italian with short phrases.

## Features

- **Dettato** — listen to an Italian phrase and type what you hear
- **Pronuncia** — read the phrase out loud and compare your pronunciation
- Grammar breakdown with part-of-speech tagging
- Word-by-word accuracy feedback
- Progress tracking across sessions
- 500+ phrases across 15 topics at A1–B1 levels

## Requirements

- macOS 14+
- Xcode Command Line Tools / Swift 5.9+
- Microphone permission (Pronuncia mode)
- Internet connection on first use (downloads speech model)

## Quick start

```bash
./build-app.sh
open Parla.app
```

Or run directly:

```bash
swift run Parla
```

## How to use

1. Choose a difficulty (**A1**, **A2**, **B1**) and topic.
2. Pick **Dettato** or **Pronuncia**.
3. Complete each phrase, then advance with **Prossima**.
4. Review your session results and repeated errors.

### Dettato controls

| Button | Shortcut | Action |
|--------|----------|--------|
| Ascolta | ⌘A | Play the phrase |
| Lento | ⌘L | Play at slower speed |
| Risposta | ⌘R | Reveal the answer |
| Conferma | ↩ | Submit your answer |

### Pronuncia controls

| Button | Action |
|--------|--------|
| 🎤 (space) | Start / stop recording |
| Riprova | Try the phrase again |
| Ascolta | Hear the correct pronunciation |
| La mia voce | Play back your recording |
| Prossima | Move to the next phrase |

Parla saves completed phrases locally on your Mac.
