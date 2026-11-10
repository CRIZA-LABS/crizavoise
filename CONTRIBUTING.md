# Contributing to CrizaVoise

Thanks for helping! CrizaVoise is free, open-source invoicing by [Criza Labs](https://criza.dev).

## Getting started
1. Install Flutter (stable, 3.47+). On Windows, also install Visual Studio 2022 Build Tools (C++) and turn on Developer Mode.
2. `flutter pub get`, then `flutter run -d windows` (or `linux` / `macos`).
3. Before opening a pull request, run `flutter analyze` and `flutter test`.

## Guidelines
- Keep changes focused: one fix or feature per pull request.
- Put new UI text in `lib/l10n/app_en.arb` and run `flutter gen-l10n`. Hindi and Gujarati translations are welcome.
- Use the design tokens in `lib/theme/tokens.dart` rather than hard-coded colours.
- Data access goes through `lib/repositories/` and the Riverpod providers, not straight to SQLite from widgets.
- Don't change invoice maths, tax or numbering without tests.
- No new network calls, analytics or tracking. The app is offline by design.

## Licence of contributions
By sending a contribution, you agree it is licensed under the [Apache License 2.0](LICENSE), like the rest of the project (section 5 of the licence).

## Reporting bugs
Open a GitHub issue with steps to reproduce, your OS and the app version (Settings → About). Report security problems privately to contact@criza.dev, not in a public issue.
