import 'package:flutter/material.dart';

import 'src/app_widget.dart';
import 'src/shared/storage/storage_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageConfig.initialize();
  runApp(const AppWidget());
}
