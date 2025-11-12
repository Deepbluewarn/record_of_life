# Record of Life (ROL)

Record of Life is a film photography management app that helps you track rolls, shots, and camera equipment.

This project is in early development stage.

## Tech Stack

- Flutter (Dart)
- Riverpod (state management)
- Isar (local database - planned)
- Pretendard (font)

## Demo

Try the app online: [Record of Life Demo](https://deepbluewarn.github.io/record_of_life/)

## Getting Started

### Prerequisites

- Flutter 3.9.2 or higher
- Dart 3.0+

### Installation

Clone the repository and install dependencies:

```bash
flutter pub get
```

### Running the App

Run the app on your connected device or emulator:

```bash
flutter run
```

To build for release:

```bash
flutter build apk      # Android
flutter build ios      # iOS
```

## Project Structure

The app follows a clean architecture pattern with feature-first organization:

- `lib/domain/` - Business logic and use cases
- `lib/infra/` - Data access and repository implementations
- `lib/features/` - Feature-specific UI and state management
- `lib/core/` - Shared utilities, constants, and errors
- `lib/shared/` - Reusable widgets and themes

## License

See LICENSE.txt in the Pretendard font directory.

