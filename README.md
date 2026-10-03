# Blind Genius - Accessible Android Music & Media App

An accessible Android mobile application built with Flutter, designed from the ground up for high accessibility, TalkBack, and Screen Reader support.

---

## 🌟 Key Features

### 1. Welcome Screen (First Launch Experience)
- Plays an introductory orientation video detailing the vision and sound philosophy of Blind Genius.
- Includes **Audio Description (AD)** toggle and a full **Transcript Reader** modal for non-visual or low-vision exploration.
- Prominently features a **TalkBack-labeled Skip Button** (`"Skip intro video and enter Blind Genius app"`), allowing users to immediately proceed to the dashboard.
- Uses `SharedPreferences` to remember first launch status (with a replay option available anytime from the AppBar).

### 2. Four Accessible Bottom Navigation Tabs
- **Music**:
  - Filterable tracks categorized by tags (*Piano Solo*, *Inspirational*, *Orchestral*, *Jazz & Soul*, *Live Concert*).
  - High-contrast play/pause controls, duration readouts, tempo, musical key, and acoustic composition notes.
  - Persistent **Now Playing Bar** and expand-to-modal full player with accessible progress slider (`increasedValue` / `decreasedValue` support for TalkBack gestures).
- **Clips**:
  - Video library featuring mini-documentaries, masterclasses, and concert clips.
  - Video cards with *AD Included* badges, spoken duration labels, scene descriptions, and transcripts.
- **Challenges & Events**:
  - *Creative Challenges*: Rhythmic tests and ear-training jams with spoken instructions and participation tracking.
  - *Live Events*: Binaural 3D audio streams, panels, and masterclasses with one-tap RSVP registration and TalkBack confirmation.
- **About Blind Genius**:
  - In-depth biography of the virtuoso pianist.
  - Honors & achievements timeline (Carnegie Hall debut, UN UNESCO Ambassador, 50M streams).
  - Accessibility commitment manifesto & community contact options.

### 3. Screen Reader & Accessibility Architecture
- **Semantics Annotations**: Every interactive widget has an explicit `Semantics` wrapper with clear `label`, `hint`, `selected`, `button`, or `header` attributes.
- **Spoken Time Formatting**: `AccessibilityService.formatDurationSpoken` converts durations into natural spoken words (e.g., *"3 minutes and 25 seconds"*) to avoid awkward punctuation reading.
- **Live Announcements**: `SemanticsService.announce` alerts screen reader users whenever filters change, tabs switch, tracks play/pause, or events are registered.
- **Haptic Feedback**: Medium and heavy tactile haptic pulses provide immediate physical confirmation of user actions.
- **WCAG AAA Compliance**: Deep black OLED contrast (`#0C0D11`) paired with vibrant Amber Gold (`#FFD54F`) and Electric Cyan (`#00E5FF`). Minimum 48x48dp touch targets across all interactive elements.

---

## 🚀 Building the Release APK in the Cloud (No Android Studio Needed!)

This project includes a complete GitHub Actions CI/CD workflow located at:
`.github/workflows/build_apk.yml`

You do not need to install Android Studio or the Android SDK on your computer to build the APK!

### How to Build Your Release APK:
1. **Initialize Git & Push to GitHub**:
   ```bash
   cd "C:\Users\Soleiman's PC\.gemini\antigravity\scratch\blind_genius"
   git init
   git add .
   git commit -m "Initial commit of Blind Genius App"
   git branch -M main
   git remote add origin https://github.com/<YOUR-USERNAME>/blind-genius.git
   git push -u origin main
   ```

2. **Watch the GitHub Actions Cloud Build**:
   - Go to your repository on GitHub.
   - Click on the **Actions** tab.
   - You will see the **"Build Blind Genius Android APK"** workflow running automatically.
   - It will install Java 17, Flutter 3.24, download all dependencies, and compile `BlindGenius-v1.0.0-release.apk`.

3. **Download Your APK**:
   - Once the build succeeds (usually ~2-3 minutes), click on the completed workflow run.
   - Under the **Artifacts** section at the bottom, click on **`BlindGenius-Release-APK`** to download your ready-to-install Android APK directly to your phone or computer!

---

## 📁 Project Architecture

```
blind_genius/
├── .github/
│   └── workflows/
│       └── build_apk.yml          # GitHub Actions workflow for automatic cloud APK compilation
├── android/                       # Native Android configuration (Manifest, Gradle, Kotlin)
│   ├── app/
│   │   ├── src/main/AndroidManifest.xml
│   │   └── build.gradle
│   ├── build.gradle
│   ├── settings.gradle
│   └── gradle.properties
├── lib/
│   ├── models/                    # Domain data models
│   │   ├── achievement.dart       # Career honors and milestone model
│   │   ├── challenge.dart         # Community rhythm challenges & live events
│   │   ├── clip.dart              # Accessible video clip model with transcripts
│   │   └── track.dart             # Audio track model with spoken duration
│   ├── services/
│   │   ├── accessibility_service.dart # TalkBack announcements, haptics, spoken time
│   │   ├── audio_service.dart     # Audio playback engine, seek, timer & state
│   │   └── mock_data_service.dart # Rich music tracks, clips, events & biography data
│   ├── theme/
│   │   └── app_theme.dart         # WCAG AAA high contrast dark theme & touch targets
│   ├── widgets/
│   │   ├── accessible_button.dart # High-contrast accessible button with haptics
│   │   ├── accessible_card.dart   # Outlined accessible card with semantic labels
│   │   ├── now_playing_bar.dart   # Floating mini-player & full player bottom sheet
│   │   └── transcript_dialog.dart # Accessible transcript & scene description viewer
│   ├── screens/
│   │   ├── welcome_screen.dart    # Intro video on 1st launch with TalkBack skip button
│   │   ├── main_navigation_screen.dart # 4-tab bottom navigation with live announcements
│   │   ├── music_screen.dart      # Tag-categorized track library with search & player
│   │   ├── clips_screen.dart      # Video clips with Audio Description & transcripts
│   │   ├── challenges_events_screen.dart # Interactive rhythm challenges & live RSVP
│   │   └── about_screen.dart      # Biography, achievement timeline & accessibility pledge
│   └── main.dart                  # App bootstrap, launch detection, accessibility setup
├── test/
│   └── widget_test.dart           # Widget and service accessibility tests
├── pubspec.yaml                   # Flutter dependencies & metadata
└── README.md
```

---

## ♿ TalkBack Verification Checklist

To test with Google TalkBack on an Android device:
1. Go to **Settings** > **Accessibility** > **TalkBack** and toggle it **On**.
2. **First Launch**: TalkBack announces: *"Welcome to Blind Genius. Introductory video is playing... Double tap skip button to continue."*
3. **Explore by Touch**: Move your finger across the screen. Every control announces its label and role (e.g., *"Skip intro video, Button. Double tap to activate"*).
4. **Music Playback**: Focus on any track card and double tap to play. TalkBack announces: *"Now playing [Track Name] by [Artist]"*.
5. **Progress Slider**: Focus on the slider in the player; use volume keys or swipe up/down to seek forward or backward in 10-second intervals.
