import 'package:blocker/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBarWidget extends GetView<HomeController>  implements PreferredSizeWidget {
  const AppBarWidget({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    return AppBar(
      forceMaterialTransparency: true,
      title: const Text('VPN Blocker'),
      centerTitle: true,
      actions: [
        Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Switch(
                value: controller.isVPNEnabled.value,
                onChanged: controller.toggleVPN,
              ),
        )),
      ],
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
