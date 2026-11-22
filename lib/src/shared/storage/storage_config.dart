import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../modules/home/model/address_model.dart';
import 'storage_keys.dart';

class StorageConfig {
  StorageConfig._();

  static Future<void> initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    final storagePath = path.join(directory.path, StorageKeys.directory);
    Hive.init(storagePath);
    registerAdapters();
    await openBoxes();
  }

  static void registerAdapters() {
    if (!Hive.isAdapterRegistered(StorageKeys.addressTypeId)) {
      Hive.registerAdapter(AddressModelAdapter());
    }
  }

  static Future<void> openBoxes() async {
    if (!Hive.isBoxOpen(StorageKeys.addressHistoryBox)) {
      await Hive.openBox<AddressModel>(StorageKeys.addressHistoryBox);
    }
  }

  static Box<AddressModel> get addressHistoryBox {
    return Hive.box<AddressModel>(StorageKeys.addressHistoryBox);
  }
}
