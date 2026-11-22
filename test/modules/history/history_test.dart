import 'package:fastlocation/src/modules/history/controller/history_controller.dart';
import 'package:fastlocation/src/modules/history/page/history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeHomeLocalRepository localRepository;

  setUp(() {
    localRepository = FakeHomeLocalRepository();
  });

  test('carrega o histórico do armazenamento local', () async {
    await localRepository.saveAddress(buildAddress());
    await localRepository.saveAddress(buildAddress(cep: '89010-000'));
    final controller = HistoryController(localRepository: localRepository);

    expect(controller.isEmpty, isTrue);

    controller.loadHistory();

    expect(controller.isEmpty, isFalse);
    expect(controller.addresses, hasLength(2));
    expect(controller.addresses.first.cep, '89010-000');
    expect(controller.isLoading, isFalse);
  });

  testWidgets('carrega os dados automaticamente ao abrir a página',
      (tester) async {
    await localRepository.saveAddress(buildAddress());
    final controller = HistoryController(localRepository: localRepository);

    await tester.pumpWidget(
      MaterialApp(home: HistoryPage(controller: controller)),
    );

    expect(find.text('Praça da Sé (lado ímpar)'), findsOneWidget);
    expect(find.text('CEP 01001-000'), findsOneWidget);
  });

  testWidgets('exibe aviso quando o histórico está vazio', (tester) async {
    final controller = HistoryController(localRepository: localRepository);

    await tester.pumpWidget(
      MaterialApp(home: HistoryPage(controller: controller)),
    );

    expect(find.text('Histórico vazio'), findsOneWidget);
  });
}
