---

# Flutter Media Delete Plugin

A Flutter plugin designed for deleting media files using scoped storage on Android versions Q (API 29) and above. This plugin helps manage media file deletion where Dart alone cannot handle permissions for these operations.

## Features

- **Scoped Storage**: Uses Android's scoped storage API to delete media files on Android Q (API 29) and above, ensuring compliance with modern Android storage policies.
- **Delete Single Media Files**: Allows you to delete a specific media file (video, audio, or image) by providing its file path. This method works with both scoped and traditional storage models, depending on the Android version.
- **Delete All Media Files in a Specified Folder**: Enables you to delete all media files within a given folder, including videos, audio files, and images. This operation works with scoped storage for Android Q and above, as well as traditional storage for older versions.
- **Error Handling**: Provides detailed error messages and feedback, including cases where files are not found or deletion is denied by the user. This ensures you receive clear information about any issues encountered during file deletion.
- **Compatibility**: Designed to handle file deletion operations across different Android versions, adapting to scoped storage requirements where necessary.

## Installation

To use this package in your Flutter project, follow these steps:

1. **Add the Dependency**

   Add `flutter_media_delete` as a dependency in your `pubspec.yaml` file:

   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     flutter_media_delete: ^1.0.0
   ```

   Replace `^1.0.0` with the latest version of the package if needed.

2. **Install the Dependency**

   Run `flutter pub get` in your terminal to install the package.

## Usage

### Import the Plugin

```dart
import 'package:flutter_media_delete/flutter_media_delete.dart';
```

### Delete a Media File

To delete a single media file, use the `deleteMediaFile` method:

```dart
try {
  final result = await FlutterMediaDelete.deleteMediaFile('/path/to/media/file.mp4');
  print('Delete result: $result');
} catch (e) {
  print('Error: $e');
}
```

### Delete All Media Files in a Folder

To delete all media files within a specific folder, use the `deleteMediaFolder` method:

```dart
try {
  final result = await FlutterMediaDelete.deleteMediaFolder('/path/to/media/folder');
  print('Delete result: $result');
} catch (e) {
  print('Error: $e');
}
```

## Platform Support

- **Android**: Supports Android versions Q (API 29) and above.
    - Uses scoped storage for media deletion.
    - Handles permission requests and user interactions.
- **iOS**: Currently not implemented. Support for iOS may be added in future versions.

## Notes

- **Scoped Storage**: For Android Q (API 29) and above, scoped storage API is used for deleting media files, as Dart alone cannot handle these operations due to permission constraints.
- **Permissions**: Ensure that the app has the necessary permissions to access and delete media files on the device.

## Troubleshooting

- **Permissions**: Verify that the app has the required permissions for scoped storage operations.
- **Error Messages**: Check error logs for detailed messages if file deletion fails.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request to contribute to the project.

## License

This project is licensed under the Apache License 2.0 License - see the [LICENSE](LICENSE) file for details.

---