Place the provided ALUCollab logo image at:

  assets/images/alu_logo.png

Then run the following to generate platform launcher icons (requires internet and Flutter tools):

```bash
flutter pub get
flutter pub run flutter_launcher_icons:main
```

Notes:
- The package will overwrite Android `mipmap-*/ic_launcher.png` and iOS AppIcon entries under `ios/Runner/Assets.xcassets/AppIcon.appiconset/`.
- For web, index.html now references `assets/images/alu_logo.png` so the image will be used as favicon when built.
- If you prefer manual replacement, copy the provided image into these platform locations:
  - Android: `android/app/src/main/res/mipmap-*/ic_launcher.png` (resize as needed)
  - iOS/macOS: replace images in `ios/Runner/Assets.xcassets/AppIcon.appiconset/` and `macos/Runner/Assets.xcassets/AppIcon.appiconset/`
  - Web: copy to `web/favicon.png` and `web/icons/*`

If you want, I can add a script to automate resizing and replacing icons locally.
