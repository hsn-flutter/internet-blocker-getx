import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/routes/app_pages.dart';


final box = GetStorage();
void main() async{
  await GetStorage.init();
  runApp(
    GetMaterialApp(
      title: "Internet Blocker",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
