import 'package:blocker/app/modules/home/controllers/home_controller.dart';
import 'package:blocker/app/modules/home/widgets/list_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ListViewWidget extends GetView<HomeController> {
  const ListViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: controller.filteredApps.length,
                    itemBuilder: (context, index) {
                      final app = controller.filteredApps[index];
                      return ListTileWidget(
                        app: app,
                        trailing: Obx(() => Switch(
                              value: app.isBlocked.value,
                              onChanged: (value) => controller.toggleAppBlocking(app, value),
                            )),
                      );
                    },
                  )),
            );
  }
}
