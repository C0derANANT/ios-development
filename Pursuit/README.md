# Pursuit

**Track your job hunt, from wishlist to offer.**

Pursuit is a native iOS app for students and job seekers who apply to dozens of
roles and lose track of where each one stands. Log every application, move it
through its stages, and see the whole pipeline at a glance.

> Status: in active development (started 17 Nov 2026). See the roadmap below.

## Features

- [x] Log an application: company, role, location, status, date, notes
- [x] Home screen with live stats: applications sent, interviews, reply rate
- [x] Filter chips by status, with counts and a sliding highlight
- [x] Cards with a stage progress bar and "last updated" dates
- [x] Swipe right to move an application to its next stage, swipe left to reject or delete
- [x] Long-press a card to jump it to any stage
- [x] Detail screen: tappable stage stepper, full status history, notes, offer celebration
- [x] Edit any application
- [x] Haptic feedback, animated numbers and a zoom transition from card to detail
- [x] Light and dark mode
- [x] Data saved on device with SwiftData (no account, works offline)
- [ ] Pipeline board: drag cards between stages
- [ ] Search
- [ ] Insights screen with charts (applications per week, reply rate)
- [ ] Follow-up nudges via local notifications
- [ ] Home-screen widget
- [ ] Unit tests

## Tech stack

| Area         | Choice                                   |
| ------------ | ---------------------------------------- |
| Language     | Swift 6 (strict concurrency)             |
| UI           | SwiftUI                                  |
| Persistence  | SwiftData                                |
| Minimum iOS  | 18.0                                     |
| Dependencies | None. Apple frameworks only              |

## Project structure

```
Pursuit/
├── PursuitApp.swift              App entry point, sets up the database
├── Models/
│   ├── JobApplication.swift      The SwiftData model, plus the move(to:) rule
│   ├── ApplicationStatus.swift   The stages an application moves through
│   └── StatusChange.swift        One entry in an application's history
├── Views/
│   ├── ApplicationListView.swift    Home screen: stats, filters, cards
│   ├── ApplicationDetailView.swift  Stepper, history and notes for one application
│   ├── ApplicationFormView.swift    Add and edit form
│   └── Components/                  Reusable pieces: card, badge, avatar,
│                                    stats header, filter bar, stepper
└── Support/
    ├── CardStyle.swift           Shared card look and press animation
    ├── Date+Relative.swift       "Today", "Yesterday", "3d ago"
    └── SampleData.swift          Fake data for Xcode previews
```

## Running it

1. Open `Pursuit.xcodeproj` in Xcode 26 or later.
2. Pick an iPhone simulator from the toolbar.
3. Press **Cmd + R**.

No API keys, packages, or setup steps needed.

## Author

Built by Anant Aggarwal as a first iOS project.
