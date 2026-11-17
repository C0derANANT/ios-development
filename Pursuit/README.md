# Pursuit

**Track your job hunt, from wishlist to offer.**

Pursuit is a native iOS app for students and job seekers who apply to dozens of
roles and lose track of where each one stands. Log every application, move it
through its stages, and see the whole pipeline at a glance.

> Status: in active development (started 17 Nov 2026). See the roadmap below.

## Features

- [x] Log an application: company, role, location, status, date, notes
- [x] Applications list, newest first, with color-coded status badges
- [x] Swipe to delete
- [x] Data saved on device with SwiftData (no account, works offline)
- [ ] Detail screen with editing and a status timeline
- [ ] Search, filter by status, and sorting
- [ ] Dashboard with charts (applications per week, pipeline funnel, response rate)
- [ ] Follow-up reminders via local notifications
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
├── PursuitApp.swift          App entry point, sets up the database
├── Models/
│   ├── JobApplication.swift  The SwiftData model (one row per application)
│   └── ApplicationStatus.swift  The stages an application moves through
├── Views/
│   ├── ApplicationListView.swift  Home screen
│   ├── AddApplicationView.swift   "New application" form
│   └── Components/                Small reusable views (row, badge, avatar)
└── Support/
    └── SampleData.swift      Fake data for Xcode previews
```

## Running it

1. Open `Pursuit.xcodeproj` in Xcode 26 or later.
2. Pick an iPhone simulator from the toolbar.
3. Press **Cmd + R**.

No API keys, packages, or setup steps needed.

## Author

Built by Anant Aggarwal as a first iOS project.
