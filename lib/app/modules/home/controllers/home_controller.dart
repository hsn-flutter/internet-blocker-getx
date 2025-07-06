import 'package:flutter/material.dart';
import 'package:blocker/app/services/vpn_service.dart';
import 'package:blocker/main.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:blocker/app/data/models/app_info.dart';

class HomeController extends GetxController {
  final VPNService vpnService = Get.find<VPNService>();

  var apps = <AppInfo>[].obs;
  var filteredApps = <AppInfo>[].obs;
  var isLoading = true.obs;
  var isVPNEnabled = false.obs;

  var searchQuery = ''.obs;
  final _blockedKey = 'blocked_apps';
  var isVPNLoading = false.obs;
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _initialize();
    debounce(searchQuery, (_) => _filterApps(), time: Duration(milliseconds: 300));
  }

  Future<void> _initialize() async {
    await requestPermissions();
    await loadInstalledApps();
    await checkVPNStatus();
  }

  Future<void> requestPermissions() async {
    await Permission.ignoreBatteryOptimizations.request();
    await Permission.accessNotificationPolicy.request();
  }

  Future<void> loadInstalledApps() async {
    try {
      isLoading(true);
      apps.value = await vpnService.getInstalledApps();
      apps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      filteredApps.assignAll(apps);
      _loadBlockedApps();
    } finally {
      isLoading(false);
    }
  }

  void _filterApps() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      filteredApps.assignAll(apps);
    } else {
      filteredApps.assignAll(
        apps.where((app) => app.name.toLowerCase().contains(query) || app.packageName.toLowerCase().contains(query)),
      );
    }
  }

  Future<void> checkVPNStatus() async {
    isVPNLoading.value = true;
    isVPNEnabled.value = await vpnService.isVPNEnabled();
    isVPNLoading.value = false;
  }

  

  Future<void> toggleVPN(bool enable) async {
    isVPNLoading.value = true;
    if (enable) {
      final blockedPackages = apps
          .where((app) => app.isBlocked.value)
          .map((app) => app.packageName)
          .toList();
      debugPrint("Starting VPN with blocked apps: \$blockedPackages");
      await vpnService.startVPN(blockedPackages);
      debugPrint("VPN start command sent to native layer.");
    } else {
      debugPrint("Stopping VPN...");
      await vpnService.stopVPN();
      debugPrint("VPN stop command sent to native layer.");
    }

    isVPNEnabled.value = enable;
    isVPNLoading.value = false;
  }
 Future<void> toggleAppBlocking(AppInfo app, bool shouldBlock) async {
  final blockedPackages = apps
      .where((a) => a.isBlocked.value)
      .map((a) => a.packageName)
      .toList();

  // Update local block state first
  app.isBlocked.value = shouldBlock;

  // Save changes to storage
  _saveBlockedApps();

  // Only update the VPN if it’s currently running
  if (isVPNEnabled.value) {
    if (shouldBlock) {
      await vpnService.blockApp(app, blockedPackages..add(app.packageName));
    } else {
      await vpnService.unblockApp(app, blockedPackages..remove(app.packageName));
    }
  } else {
    debugPrint("VPN is not enabled — skipping VPN restart.");
  }
}


  void _saveBlockedApps() {
    final blocked = apps.where((app) => app.isBlocked.value).map((a) => a.packageName).toList();
    box.write(_blockedKey, blocked);
  }

  void _loadBlockedApps() {
    final blocked = box.read<List>(_blockedKey)?.cast<String>() ?? [];
    for (final app in apps) {
      app.isBlocked.value = blocked.contains(app.packageName);
    }
  }
}
