import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_media_delete/flutter_media_delete.dart';
import 'package:flutter_media_delete/flutter_media_delete_platform_interface.dart';
import 'package:flutter_media_delete/flutter_media_delete_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterMediaDeletePlatform
    with MockPlatformInterfaceMixin
    implements FlutterMediaDeletePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterMediaDeletePlatform initialPlatform = FlutterMediaDeletePlatform.instance;

  test('$MethodChannelFlutterMediaDelete is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterMediaDelete>());
  });

  test('getPlatformVersion', () async {
    FlutterMediaDelete flutterMediaDeletePlugin = FlutterMediaDelete();
    MockFlutterMediaDeletePlatform fakePlatform = MockFlutterMediaDeletePlatform();
    FlutterMediaDeletePlatform.instance = fakePlatform;

    expect(await flutterMediaDeletePlugin.getPlatformVersion(), '42');
  });
}
