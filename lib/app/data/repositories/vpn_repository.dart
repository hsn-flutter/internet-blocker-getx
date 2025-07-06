import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class VPNRepository {
  static const _channel = MethodChannel('blocker.blocker/vpn');

  Future<void> startVPN(List<String> blockedApps) async {
    try {
      await _channel.invokeMethod('startVPN', {'blockedApps': blockedApps});
    } catch (e) {
      debugPrint('❌ Failed to start VPN: $e');
    }
  }

  Future<void> stopVPN() async {
    try {
      await _channel.invokeMethod('stopVPN');
    } catch (e) {
      debugPrint('❌ Failed to stop VPN: $e');
    }
  }

  Future<bool> isVPNRunning() async {
    try {
      final result = await _channel.invokeMethod<bool>('checkVPN');
      return result ?? false;
    } catch (e) {
      debugPrint('❌ Error checking VPN status: $e');
      return false;
    }
  }
}
