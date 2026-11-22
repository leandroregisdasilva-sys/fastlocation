import 'package:fastlocation/src/modules/home/controller/home_controller.dart';
import 'package:fastlocation/src/modules/home/page/home_page.dart';
import 'package:fastlocation/src/modules/home/service/home_service.dart';
import 'package:fastlocation/src/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  late FakeHomeRepository repository;
  late FakeHomeLocalRepository localRepository;
  late FakeRouteService routeService;

  Widget buildPage() {
    final controller = HomeController(
      service: HomeService(
        repository: repository,
        localRepository: localRepository,
      ),
      routeService: routeService,
    );
    return MaterialApp(
      routes: {
        AppRoutes.history: (_) => const Scaffold(body: Text('tela-historico')),
      },
      home: HomePage(controller: controller),
    );
  }

  setUp(() {
    repository = FakeHomeRepository();
    localRepository = FakeHomeLocalRepository();
    routeService = FakeRouteService();
  });

  testWidgets('exibe o estado inicial sem consultas', (tester) async {
    await tester.pumpWidget(buildPage());

    expect(find.text('Último endereço consultado'), findsOneWidget);
    expect(find.text('Nenhum endereço consultado ainda.'), findsOneWidget);
    expect(find.text('Nenhuma consulta realizada'), findsOneWidget);
    expect(find.text('Traçar rota'), findsNothing);
  });

  testWidgets('consulta um CEP e exibe o endereço retornado', (tester) async {
    repository.cepResult = buildAddress();
    await tester.pumpWidget(buildPage());

    await tester.tap(find.text('Nova consulta'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('cepField')), '01001000');
    await tester.tap(find.byKey(const Key('submitSearch')));
    await tester.pumpAndSettle();

    expect(find.text('Praça da Sé (lado ímpar)'), findsNWidgets(2));
    expect(find.text('CEP 01001-000'), findsNWidgets(2));
    expect(find.text('Traçar rota'), findsOneWidget);
  });

  testWidgets('exibe o componente de busca vazia quando não há resultado',
      (tester) async {
    await tester.pumpWidget(buildPage());

    await tester.tap(find.text('Nova consulta'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('cepField')), '99999999');
    await tester.tap(find.byKey(const Key('submitSearch')));
    await tester.pumpAndSettle();

    expect(find.text('Nenhum endereço encontrado'), findsOneWidget);
  });

  testWidgets('valida o CEP no formulário antes de consultar', (tester) async {
    await tester.pumpWidget(buildPage());

    await tester.tap(find.text('Nova consulta'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('cepField')), '123');
    await tester.tap(find.byKey(const Key('submitSearch')));
    await tester.pumpAndSettle();

    expect(find.text('Informe os 8 dígitos do CEP'), findsOneWidget);
    expect(repository.cepCalls, 0);
  });

  testWidgets('traça a rota com o último endereço consultado', (tester) async {
    await localRepository.saveAddress(buildAddress());
    await tester.pumpWidget(buildPage());

    await tester.tap(find.text('Traçar rota'));
    await tester.pumpAndSettle();

    expect(routeService.openedAddress?.cep, '01001-000');
  });

  testWidgets('abre a página de histórico', (tester) async {
    await tester.pumpWidget(buildPage());

    await tester.tap(find.text('Histórico'));
    await tester.pumpAndSettle();

    expect(find.text('tela-historico'), findsOneWidget);
  });
}
