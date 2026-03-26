import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'fcm_service.dart';

class DeviceService {
  static Future<Map<String, dynamic>> getDeviceData() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    String deviceId = '';
    String deviceName = '';
    final String deviceType = Platform.isAndroid ? 'android' : 'ios';
    String osVersion = '';

    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;

      deviceId = android.id;
      deviceName = '${android.brand} ${android.model}';
      osVersion = 'Android ${android.version.release}';
    } else if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;

      deviceId = ios.identifierForVendor ?? '';
      deviceName = '${ios.name} ${ios.model}';
      osVersion = 'iOS ${ios.systemVersion}';
    }

    final fcmToken = await getToken();

    return {
      'device_id': deviceId,
      'device_name': deviceName,
      'device_type': deviceType,
      'fcm_token': fcmToken,
      'app_version': packageInfo.version,
      'os_version': osVersion,
    };
  }
}
