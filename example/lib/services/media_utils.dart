import 'dart:io';

class MediaUtils {
  static Future<List<File>> getMediaFiles({int limit = 10}) async {
    final rootDirectory = Directory('/storage/emulated/0');
    List<File> mediaFiles = [];

    // Define common media file extensions for audio and video
    final mediaExtensions = [
      '.mp3', '.aac', '.flac', '.ogg', '.wav', '.wma', // Audio formats
      '.mp4', '.mkv', '.avi', '.mov', '.wmv', '.flv', '.mpeg' // Video formats
    ];

    try {
      // List all entities in the root directory non-recursively first
      List<FileSystemEntity> entities = rootDirectory.listSync();

      // Use a queue to handle directories for traversal
      List<Directory> directoriesToCheck = entities
          .whereType<Directory>()
          .where((dir) => !_isRestrictedDirectory(dir))
          .toList();

      while (directoriesToCheck.isNotEmpty) {
        final currentDirectory = directoriesToCheck.removeLast();

        try {
          // List all files and subdirectories within the current directory
          final children = currentDirectory.listSync();

          for (var child in children) {
            if (child is File && _isMediaFile(child.path, mediaExtensions)) {
              mediaFiles.add(child);
              if (mediaFiles.length == limit) {
                return mediaFiles; // Stop after finding the first 10 media files
              }
            } else if (child is Directory && !_isRestrictedDirectory(child)) {
              // If it's a directory and not restricted, add it to the queue
              directoriesToCheck.add(child);
            }
          }
        } catch (e) {
          print('Error accessing directory: $e');
        }
      }
    } catch (e) {
      print('Error fetching media files: $e');
    }

    return mediaFiles;
  }

  // static Future<List<File>> getMediaFiles() async {
  //   final directory = await getExternalStorageDirectory();
  //   if (directory == null) return [];
  //
  //   List<File> mediaFiles = [];
  //   final mediaExtensions = [
  //     '.mp3', '.aac', '.flac', '.ogg', '.wav', '.wma', // Audio formats
  //     '.mp4', '.mkv', '.avi', '.mov', '.wmv', '.flv', '.mpeg', // Video formats
  //     '.jpg', '.jpeg', '.png', '.gif' // Image formats for completeness
  //   ];
  //
  //   try {
  //     // Get all entities in the directory recursively
  //     final entities = directory.listSync(recursive: true);
  //
  //     // Filter out only media files based on the extensions
  //     mediaFiles = entities
  //         .where((entity) =>
  //             entity is File && _isMediaFile(entity.path, mediaExtensions))
  //         .cast<File>()
  //         .toList();
  //   } catch (e) {
  //     print('Error fetching media files: $e');
  //   }
  //
  //   return mediaFiles;
  // }

  // Updated to include audio and video formats
  static bool _isMediaFile(String path, List<String> mediaExtensions) {
    return mediaExtensions.any((ext) => path.toLowerCase().endsWith(ext));
  }

  static Future<List<Directory>> getMediaFolders({int limit = 10}) async {
    final rootDirectory = Directory('/storage/emulated/0');
    List<Directory> mediaFolders = [];

    final mediaExtensions = [
      'mp3', 'aac', 'flac', 'ogg', 'wav', 'wma', // Audio formats
      'mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'mpeg', // Video formats
      'jpg', 'jpeg', 'png', 'gif' // Image formats
    ];

    try {
      // List all entities in the root directory non-recursively first
      List<FileSystemEntity> entities = rootDirectory.listSync();

      // We will manually handle the recursion to avoid restricted directories
      for (final entity in entities) {
        if (entity is Directory && !_isRestrictedDirectory(entity)) {
          List<Directory> directoriesToCheck = [entity];

          while (directoriesToCheck.isNotEmpty) {
            final currentDirectory = directoriesToCheck.removeLast();

            try {
              final children = currentDirectory.listSync();
              bool hasMediaFiles = false;

              for (final child in children) {
                if (child is File) {
                  final extension = child.path.split('.').last.toLowerCase();
                  if (mediaExtensions.contains(extension)) {
                    hasMediaFiles = true;
                    break;
                  }
                } else if (child is Directory &&
                    !_isRestrictedDirectory(child)) {
                  directoriesToCheck.add(child);
                }
              }

              if (hasMediaFiles) {
                mediaFolders.add(currentDirectory);
                if (mediaFolders.length == limit) {
                  return mediaFolders; // Stop after finding the first N media folders
                }
              }
            } catch (e) {
              print('Error accessing directory: $e');
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching media folders: $e');
    }

    return mediaFolders;
  }

  static bool _isRestrictedDirectory(Directory dir) {
    final path = dir.path;
    return path.startsWith('/storage/emulated/0/Android') ||
        path.contains('/.') || // Hidden directories
        path.startsWith('/storage/emulated/0/obb');
  }
}
