# Sync-ED

**Sync-ED** is a Flutter-based peer-learning platform concept for students. It brings study resources and academic planning into one place, with modules for sharing notes, study planning, topic-based discussion, and AI-assisted resume feedback.

## Project areas
- **Peer learning and notes:** UI and flows for finding and sharing study resources.
- **Resume feedback:** an AI-related module/prototype for reviewing a resume and suggesting improvements.
- **Study planner and roadmaps:** plan work around study goals and deadlines.
- **Topic-based chat:** organize discussions around a subject or learning goal.
- **Profiles and authentication:** application flows backed by Supabase integration.

## Tech stack
- **App:** Flutter, Dart
- **Backend services:** Supabase authentication, database, and storage
- **Packages:** `supabase_flutter`, `file_picker`, and `url_launcher`

## Run locally

1. Install the Flutter SDK compatible with the Dart constraint in `pubspec.yaml`.
2. Clone the repository and switch to the `final` branch.
3. Configure a Supabase project and review the client setup in `lib/supabase.dart`. Use only a client/public key protected by appropriate database policies; never add a Supabase service-role key to a mobile app.
4. Fetch dependencies and run the app:

~~~bash
flutter pub get
flutter run
~~~

## Repository layout
- `lib/` — Flutter application screens, chat, academic features, study planner, and Supabase integration
- `ai-test/` — separate AI-related prototype files
- `assets/` — app assets

## Project status
This repository contains an evolving project. Review the current implementation and configuration before assuming every feature is production-ready. Do not commit private credentials or real student data.
