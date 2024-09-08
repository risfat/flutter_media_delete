---

# Flutter Media Delete Plugin

A Flutter plugin designed for deleting media files using scoped storage on Android versions Q (API 29) and above. This plugin helps manage media file deletion where Dart alone cannot handle permissions for these operations.

## Features

- **Scoped Storage**: Uses Android's scoped storage API to delete media files on Android Q (API 29) and above.
- **Cross-Platform Support**: Designed to handle media deletion with appropriate permissions.
- **Error Handling**: Provides detailed error messages and feedback.

## Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_media_delete:
    git:
      url: https://github.com/risfat/flutter_media_delete.git
```

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