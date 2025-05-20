# DomiNotes

DomiNotes is a mobile-first, offline-ready, Progressive Web App inspired by Apple's Notes app — built with Flutter Web and Dart. It features secure PIN-based access, a folder/note system, dark mode, and full offline functionality using a local NoSQL database (Hive). The entire app is deployable on Netlify and functions independently of any cloud backend.

## Features

- **PIN Authentication**: Secure 4- or 6-digit PIN login system
- **Notes Management**: Create, edit, delete, and organize notes
- **Folder System**: Organize notes into folders with many-to-many relationships
- **Dark Mode**: Toggle between light and dark themes
- **Offline Support**: Works fully offline with local database
- **PWA Ready**: Installable on mobile and desktop devices
- **iOS-inspired Design**: Clean, minimalist UI inspired by Apple Notes

## Tech Stack

- **Frontend**: Flutter Web, Dart
- **UI Style**: Cupertino/iOS design with modern minimalist tweaks
- **Local Storage**: Hive NoSQL database
- **Deployment**: Netlify static hosting

## Getting Started

### Prerequisites

- Flutter SDK (2.10.0 or higher)
- Dart SDK (2.16.0 or higher)

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/yourusername/domini.git
   cd domini
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Generate Hive adapters
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. Run the app
   ```bash
   flutter run -d chrome
   ```

## Building for Production

1. Build the web app
   ```bash
   flutter build web
   ```

2. The build output will be in the `build/web` directory, which can be deployed to Netlify or any static hosting service.

## Deployment

### Netlify Deployment

1. Create a new site on Netlify
2. Connect to your GitHub repository or drag and drop the `build/web` folder
3. Set the publish directory to `build/web`
4. Deploy!

## Data Model

- **Notes**: Title, content, folder assignments, timestamps
- **Folders**: Name, timestamps
- **Settings**: PIN, theme preferences

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by Apple's Notes app
- Built with Flutter and Dart

A new Flutter project.
