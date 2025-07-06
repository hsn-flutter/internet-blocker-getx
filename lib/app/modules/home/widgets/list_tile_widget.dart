import 'package:blocker/app/data/models/app_info.dart';
import 'package:flutter/material.dart';

class ListTileWidget extends StatelessWidget {
  const ListTileWidget({super.key, required this.app, this.trailing});
  final AppInfo app;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: MemoryImage(app.icon)),
      title: Text(app.name),
      subtitle: Text(app.packageName),
      trailing: trailing,
    );
  }
}
