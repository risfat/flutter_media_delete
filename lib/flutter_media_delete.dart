import 'package:flutter/services.dart';

class FlutterMediaDelete {
  static const MethodChannel _channel = MethodChannel('flutter_media_delete');

  /// Deletes a media file located at [filePath].
  ///
  /// Returns a [String] message indicating success or failure.
  /// Throws a [PlatformException] if an error occurs.
  static Future<String> deleteMediaFile(String filePath) async {
    try {
      final String result = await _channel
          .invokeMethod('deleteMediaFile', {'filePath': filePath});
      return result;
    } on PlatformException catch (e) {
      // Handle specific exceptions or errors here
      print("Error deleting media file: ${e.message}");
      // Provide a user-friendly message or rethrow the exception
      throw Exception('Failed to delete media file: ${e.message}');
    } catch (e) {
      // Handle other types of exceptions
      print("Unexpected error: $e");
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Deletes all media files in the folder located at [folderPath].
  ///
  /// Returns a [String] message indicating success or failure.
  /// Throws a [PlatformException] if an error occurs.
  static Future<String> deleteMediaFolder(String folderPath) async {
    try {
      final String result = await _channel
          .invokeMethod('deleteMediaFolder', {'folderPath': folderPath});
      return result;
    } on PlatformException catch (e) {
      // Handle specific exceptions or errors here
      print("Error deleting media folder: ${e.message}");
      // Provide a user-friendly message or rethrow the exception
      throw Exception('Failed to delete media folder: ${e.message}');
    } catch (e) {
      // Handle other types of exceptions
      print("Unexpected error: $e");
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
