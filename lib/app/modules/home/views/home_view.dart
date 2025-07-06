import 'package:blocker/app/modules/home/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:blocker/app/modules/home/widgets/list_view_widget.dart';
import 'package:blocker/app/modules/home/widgets/text_field_widget.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            TextFieldWidget(
              controller: controller.searchController,
              onChanged: (value) => controller.searchQuery.value = value,
            ),
            ListViewWidget(),
          ],
        );
      }),
    );
  }
}
