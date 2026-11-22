import 'package:hive/hive.dart';

import '../../../shared/storage/storage_config.dart';
import '../model/address_model.dart';

class HomeLocalRepository {
  HomeLocalRepository({Box<AddressModel>? box})
      : _box = box ?? StorageConfig.addressHistoryBox;

  final Box<AddressModel> _box;

  AddressModel? findByCep(String cepDigits) {
    for (final address in _box.values) {
      if (address.cepDigits == cepDigits) {
        return address;
      }
    }
    return null;
  }

  Future<void> saveAddress(AddressModel address) async {
    final repeatedKeys = _box.keys
        .where((key) => _box.get(key)?.cepDigits == address.cepDigits)
        .toList();
    await _box.deleteAll(repeatedKeys);
    await _box.add(address);
  }

  List<AddressModel> getHistory() {
    return _box.values.toList().reversed.toList();
  }

  AddressModel? getLastAddress() {
    if (_box.isEmpty) {
      return null;
    }
    return _box.values.last;
  }
}
