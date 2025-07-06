import 'dart:typed_data';
import 'package:get/get.dart';

class AppInfo {
  final String name;
  final String packageName;
  final Uint8List icon;
  final RxBool isBlocked;

  AppInfo({
    required this.name,
    required this.packageName,
    required this.icon,
    bool isBlocked = false,
  }) : isBlocked = RxBool(isBlocked);
}
