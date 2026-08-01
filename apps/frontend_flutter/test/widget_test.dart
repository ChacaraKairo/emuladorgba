import 'package:emuladorgba_frontend/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('exibe navegação e biblioteca vazia', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const EmulatorApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Biblioteca'), findsWidgets);
    expect(find.text('Saves'), findsWidgets);
    expect(find.text('Configurações'), findsWidgets);
    expect(find.text('Nenhum jogo importado'), findsOneWidget);
  });
}
