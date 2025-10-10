

//function to call the initialization of the json data
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

import 'couchbase_services.dart';

Future<void> runOnceOnFirstInstall() async{
  final prefs = await SharedPreferences.getInstance();

  final isFirstRun = prefs.getBool('isFirstRun') ?? true;

  if (isFirstRun) {
    await CouchbaseServices().storePaginatedJsonData();

    await prefs.setBool('isFirstRun', false);
    log("First-run initialization done!",name: 'Initialization');
  } else {
    log("Initialization already done before.",name: 'Initialization');
  }
}