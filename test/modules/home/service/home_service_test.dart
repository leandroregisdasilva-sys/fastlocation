import 'package:fastlocation/src/modules/home/service/home_service.dart';
import 'package:fastlocation/src/shared/exceptions/app_exception.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  late FakeHomeRepository repository;
  late FakeHomeLocalRepository localRepository;
  late HomeService service;

  setUp(() {
    repository = FakeHomeRepository();
    localRepository = FakeHomeLocalRepository();
    service = HomeService(
      repository: repository,
      localRepository: localRepository,
    );
  });

  group('consulta por CEP', () {
    test('rejeita CEP com menos de 8 dígitos sem chamar a API', () async {
      await expectLater(
        service.searchByCep('1234'),
        throwsA(isA<AppException>()),
      );
      expect(repository.cepCalls, 0);
    });

    test('remove a máscara, consulta a API e salva no histórico', () async {
      repository.cepResult = buildAddress();

      final address = await service.searchByCep('01001-000');

      expect(repository.lastCep, '01001000');
      expect(address?.logradouro, 'Praça da Sé');
      expect(localRepository.items, hasLength(1));
    });

    test('usa o armazenamento local em consultas recorrentes', () async {
      repository.cepResult = buildAddress();
      await service.searchByCep('01001000');

      final address = await service.searchByCep('01001-000');

      expect(repository.cepCalls, 1);
      expect(address?.cep, '01001-000');
      expect(localRepository.items, hasLength(1));
    });

    test('retorna nulo e não salva quando o CEP não existe', () async {
      final address = await service.searchByCep('99999999');

      expect(address, isNull);
      expect(localRepository.items, isEmpty);
    });
  });

  group('consulta por endereço', () {
    test('valida UF, cidade e logradouro antes de chamar a API', () async {
      await expectLater(
        service.searchByAddress(uf: '', city: 'Blumenau', street: 'Quinze'),
        throwsA(isA<AppException>()),
      );
      await expectLater(
        service.searchByAddress(uf: 'SC', city: 'Bl', street: 'Quinze'),
        throwsA(isA<AppException>()),
      );
      await expectLater(
        service.searchByAddress(uf: 'SC', city: 'Blumenau', street: 'XV'),
        throwsA(isA<AppException>()),
      );
      expect(repository.streetCalls, 0);
    });

    test('normaliza os dados e devolve os endereços encontrados', () async {
      repository.streetResult = [
        buildAddress(cep: '89010-000'),
        buildAddress(cep: '89010-001'),
      ];

      final addresses = await service.searchByAddress(
        uf: 'sc',
        city: ' Blumenau ',
        street: ' Quinze ',
      );

      expect(repository.lastUf, 'SC');
      expect(repository.lastCity, 'Blumenau');
      expect(repository.lastStreet, 'Quinze');
      expect(addresses, hasLength(2));
      expect(localRepository.items, isEmpty);
    });

    test('salva automaticamente quando há um único resultado', () async {
      repository.streetResult = [buildAddress(cep: '89010-000')];

      await service.searchByAddress(
        uf: 'SC',
        city: 'Blumenau',
        street: 'Quinze',
      );

      expect(localRepository.items, hasLength(1));
    });
  });

  test('registra a consulta do endereço selecionado', () async {
    await service.registerConsultation(buildAddress());

    expect(service.getLastAddress()?.cep, '01001-000');
    expect(service.getHistory(), hasLength(1));
  });
}
