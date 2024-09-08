import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerService {
  static Future<bool> requestPermissions() async {
    print("Requesting storage and media library permissions...");

    // Check Android version
    final DeviceInfoPlugin info = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await info.androidInfo;
    final int androidVersion = int.parse(androidInfo.version.release);

    Map<Permission, PermissionStatus> statuses;

    // Request permissions based on Android version
    if (androidVersion >= 13) {
      // Android 13 and above
      statuses = await [
        Permission.videos,
        Permission.audio,
      ].request();
    } else {
      // Below Android 13
      statuses = await [
        Permission.storage,
      ].request();
    }

    // Determine if all required permissions are granted
    bool allPermissionsGranted;

    if (androidVersion >= 13) {
      allPermissionsGranted = statuses[Permission.videos]!.isGranted &&
          statuses[Permission.audio]!.isGranted;
    } else {
      allPermissionsGranted = statuses[Permission.storage]!.isGranted;
    }

    // Handle denied or permanently denied permissions
    if (!allPermissionsGranted) {
      if (androidVersion >= 13) {
        if (statuses[Permission.videos]!.isDenied ||
            statuses[Permission.videos]!.isPermanentlyDenied) {
          print("Video permission denied or permanently denied");
        }

        if (statuses[Permission.audio]!.isDenied ||
            statuses[Permission.audio]!.isPermanentlyDenied) {
          print("Audio permission denied or permanently denied");
        }
      } else {
        if (statuses[Permission.storage]!.isDenied ||
            statuses[Permission.storage]!.isPermanentlyDenied) {
          print("Storage permission denied or permanently denied");
        }
      }

      // If any permission is permanently denied, open app settings
      if (statuses.values.any((status) => status.isPermanentlyDenied)) {
        await openAppSettings();
      }
    }

    return allPermissionsGranted;
  }
}
