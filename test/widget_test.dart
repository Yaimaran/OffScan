import 'package:flutter_test/flutter_test.dart';
import 'package:offscan/main.dart';

void main() {
  testWidgets('OffScanApp renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const OffScanApp());
    expect(find.text('OffScan'), findsOneWidget);
  });
}
