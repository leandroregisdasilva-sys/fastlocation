import 'dart:io';

import 'package:fastlocation/src/modules/home/model/address_model.dart';
import 'package:fastlocation/src/modules/home/repositories/home_local_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import '../../../helpers/fakes.dart';

void main() {
  late Directory directory;
  late Box<AddressModel> box;
  late HomeLocalRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('fastlocation_test');
    Hive.init(directory.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AddressModelAdapter());
    }
    box = await Hive.openBox<AddressModel>('address_history_test');
    repository = HomeLocalRepository(box: box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('inicia sem histórico e sem último endereço', () {
    expect(repository.getHistory(), isEmpty);
    expect(repository.getLastAddress(), isNull);
  });

  test('salva endereços e devolve o histórico do mais recente ao mais antigo',
      () async {
    await repository.saveAddress(buildAddress());
    await repository.saveAddress(
      buildAddress(cep: '89010-000', logradouro: 'Rua XV de Novembro'),
    );

    final history = repository.getHistory();

    expect(history, hasLength(2));
    expect(history.first.cep, '89010-000');
    expect(repository.getLastAddress()?.cep, '89010-000');
  });

  test('não duplica o mesmo CEP e o move para o topo do histórico', () async {
    await repository.saveAddress(buildAddress());
    await repository.saveAddress(buildAddress(cep: '89010-000'));
    await repository.saveAddress(buildAddress());

    final history = repository.getHistory();

    expect(history, hasLength(2));
    expect(history.first.cep, '01001-000');
  });

  test('localiza endereço armazenado pelo CEP', () async {
    await repository.saveAddress(buildAddress());

    expect(repository.findByCep('01001000')?.logradouro, 'Praça da Sé');
    expect(repository.findByCep('00000000'), isNull);
  });

  test('mantém os dados após reabrir o armazenamento', () async {
    await repository.saveAddress(buildAddress());
    await box.close();

    box = await Hive.openBox<AddressModel>('address_history_test');
    repository = HomeLocalRepository(box: box);

    expect(repository.getLastAddress()?.cep, '01001-000');
    expect(repository.getLastAddress()?.complemento, 'lado ímpar');
  });
}
