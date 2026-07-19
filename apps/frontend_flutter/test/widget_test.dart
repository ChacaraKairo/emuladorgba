import 'package:emuladorgba_frontend/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('exibe biblioteca vazia e acao de importar ROM', (tester) async {
    await tester.pumpWidget(const EmulatorApp());

    expect(find.text('Minha Biblioteca'), findsOneWidget);
    expect(find.text('Nenhum jogo importado'), findsOneWidget);
    expect(find.text('Selecionar arquivo .gba'), findsOneWidget);
  });
}
