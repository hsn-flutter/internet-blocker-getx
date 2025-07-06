import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:blocker/app/data/models/app_info.dart';
import 'package:blocker/app/data/repositories/vpn_repository.dart';

class VPNService extends GetxService {
  final VPNRepository _vpnRepo = VPNRepository();

  Future<List<AppInfo>> getInstalledApps() async {
    try {
      final apps = await InstalledApps.getInstalledApps(true, true);
      return await Future.wait(apps.map((app) async {
        return AppInfo(
          name: app.name,
          packageName: app.packageName,
          icon: app.icon ?? Uint8List(0),
        );
      }));
    } catch (e) {
      Get.snackbar('Error', 'Failed to get installed apps: $e');
      return [];
    }
  }

  Future<bool> isVPNEnabled() => _vpnRepo.isVPNRunning();

  Future<void> blockApp(AppInfo app, List<String> currentBlockedPackages) async {
    currentBlockedPackages.add(app.packageName);
    await _vpnRepo.startVPN(currentBlockedPackages);
  }

  Future<void> unblockApp(AppInfo app, List<String> currentBlockedPackages) async {
    currentBlockedPackages.remove(app.packageName);
    await _vpnRepo.startVPN(currentBlockedPackages);
  }

  Future<void> startVPN(List<String> blockedPackages) => _vpnRepo.startVPN(blockedPackages);

  Future<void> stopVPN() => _vpnRepo.stopVPN();
}
