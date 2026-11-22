import 'package:fastlocation/src/modules/initial/page/initial_page.dart';
import 'package:fastlocation/src/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('anima a abertura e redireciona para a home', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          AppRoutes.home: (_) => const Scaffold(body: Text('tela-home')),
        },
        home: const InitialPage(),
      ),
    );

    expect(find.text('FastLocation'), findsOneWidget);
    expect(find.byType(FadeTransition), findsWidgets);
    expect(find.text('tela-home'), findsNothing);

    await tester.pump(InitialPage.redirectDelay);
    await tester.pumpAndSettle();

    expect(find.text('tela-home'), findsOneWidget);
    expect(find.text('FastLocation'), findsNothing);
  });
}
