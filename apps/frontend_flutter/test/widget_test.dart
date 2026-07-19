import 'package:emuladorgba_frontend/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('exibe biblioteca vazia e acao de importar ROM', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const EmulatorApp());
    await tester.pumpAndSettle();

    expect(find.text('Minha Biblioteca'), findsOneWidget);
    expect(find.text('Nenhum jogo importado'), findsOneWidget);
    expect(find.text('Selecionar arquivo .gba'), findsOneWidget);
  });
}
