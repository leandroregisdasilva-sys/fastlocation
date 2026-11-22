import 'package:fastlocation/src/modules/home/controller/home_controller.dart';
import 'package:fastlocation/src/modules/home/service/home_service.dart';
import 'package:fastlocation/src/shared/exceptions/app_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart';

import '../../../helpers/fakes.dart';

void main() {
  late FakeHomeRepository repository;
  late FakeHomeLocalRepository localRepository;
  late FakeRouteService routeService;
  late HomeController controller;

  setUp(() {
    repository = FakeHomeRepository();
    localRepository = FakeHomeLocalRepository();
    routeService = FakeRouteService();
    controller = HomeController(
      service: HomeService(
        repository: repository,
        localRepository: localRepository,
      ),
      routeService: routeService,
    );
  });

  test('carrega o último endereço consultado do armazenamento local', () async {
    await localRepository.saveAddress(buildAddress());

    controller.loadLastAddress();

    expect(controller.hasLastAddress, isTrue);
    expect(controller.lastAddress?.cep, '01001-000');
  });

  test('consulta por CEP atualiza a lista e o último endereço', () async {
    repository.cepResult = buildAddress();
    final loadingStates = <bool>[];
    final dispose = reaction<bool>(
      (_) => controller.isLoading,
      loadingStates.add,
    );

    await controller.searchByCep('01001000');
    dispose();

    expect(loadingStates, <bool>[true, false]);
    expect(controller.hasSearched, isTrue);
    expect(controller.addresses, hasLength(1));
    expect(controller.lastAddress?.logradouro, 'Praça da Sé');
    expect(controller.errorMessage, isNull);
  });

  test('consulta sem resultado mantém a lista vazia', () async {
    await controller.searchByCep('99999999');

    expect(controller.hasSearched, isTrue);
    expect(controller.addresses, isEmpty);
    expect(controller.hasLastAddress, isFalse);
  });

  test('expõe mensagem de erro de validação', () async {
    await controller.searchByCep('123');

    expect(controller.errorMessage, 'Informe um CEP com 8 dígitos.');
    expect(controller.isLoading, isFalse);
  });

  test('expõe mensagem de erro vinda da API', () async {
    repository.error = const AppException('Sem conexão com a internet.');

    await controller.searchByCep('01001000');

    expect(controller.errorMessage, 'Sem conexão com a internet.');
    controller.clearError();
    expect(controller.errorMessage, isNull);
  });

  test('converte falha inesperada em mensagem padrão', () async {
    repository.error = StateError('falha');

    await controller.searchByCep('01001000');

    expect(controller.errorMessage, HomeControllerBase.unexpectedError);
  });

  test('consulta por endereço lista vários resultados para seleção', () async {
    repository.streetResult = [
      buildAddress(cep: '89010-000'),
      buildAddress(cep: '89010-001'),
    ];

    await controller.searchByAddress(
      uf: 'SC',
      city: 'Blumenau',
      street: 'Quinze',
    );

    expect(controller.addresses, hasLength(2));
    expect(controller.hasLastAddress, isFalse);

    await controller.selectAddress(controller.addresses.last);

    expect(controller.lastAddress?.cep, '89010-001');
    expect(localRepository.items, hasLength(1));
  });

  test('traça a rota para o último endereço consultado', () async {
    repository.cepResult = buildAddress();
    await controller.searchByCep('01001000');

    await controller.traceRoute();

    expect(routeService.openedAddress?.cep, '01001-000');
    expect(controller.errorMessage, isNull);
  });

  test('avisa quando não há endereço para traçar a rota', () async {
    await controller.traceRoute();

    expect(routeService.openedAddress, isNull);
    expect(
      controller.errorMessage,
      'Consulte um endereço antes de traçar a rota.',
    );
  });

  test('expõe erro quando o mapa não pode ser aberto', () async {
    repository.cepResult = buildAddress();
    await controller.searchByCep('01001000');
    routeService.error = const AppException('Nenhum aplicativo de mapas.');

    await controller.traceRoute();

    expect(controller.errorMessage, 'Nenhum aplicativo de mapas.');
    expect(controller.isLoading, isFalse);
  });
}
