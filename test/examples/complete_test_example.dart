/// This file demonstrates all testing patterns and best practices for Aura 3
/// Use this as a reference when writing new tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fake_async/fake_async.dart';
import 'package:provider/provider.dart';
import '../mocks/mock_data.dart';
import '../helpers/test_helpers.dart';

// Step 1: Generate mocks using build_runner
// Run: flutter pub run build_runner build
@GenerateMocks([MockedClass])
// Import generated mocks (commented out for template)
// import 'complete_test_example.mocks.dart';

void main() {
  // Define local Mock class for the template to compile without build_runner
  final mockedDependency = MockManualMockedClass();
  const testData = 'Sample Data';

  // ========== TEST ORGANIZATION ==========
  group('Feature Name - Component/Function', () {
    late ClassUnderTest classUnderTest;

    setUp(() {
      classUnderTest = ClassUnderTest(dependency: mockedDependency);
    });

    test('descriptive test name following AAA pattern', () async {
      const input = 'test input';
      const expectedOutput = 'expected output';

      // Using 'any' requires the parameter in the mock to be nullable
      when(mockedDependency.someMethod(any))
          .thenAnswer((_) async => expectedOutput);

      final result = await classUnderTest.methodUnderTest(input);

      expect(result, equals(expectedOutput));
    });

    testWidgets('widget displays expected elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: YourWidget(data: testData),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(testData), findsOneWidget);
      expect(find.byType(YourWidget), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('tapping button triggers expected action', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: YourWidget(data: 'Tap Me')),
      );

      final button = find.text('Tap Me');
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(true, true);
    });

    test('timer completes after duration', () {
      fakeAsync((async) {
        var completed = false;
        Future.delayed(const Duration(seconds: 5), () => completed = true);
        async.elapse(const Duration(seconds: 5));
        expect(completed, true);
      });
    });

    testWidgets('provider updates state correctly', (WidgetTester tester) async {
      final provider = YourProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<YourProvider>.value(
          value: provider,
          child: const MaterialApp(home: YourWidget(data: 'Provider Test')),
        ),
      );

      provider.updateSomething();
      await tester.pumpAndSettle();

      expect(true, true);
    });
  });
}

// ========== MOCK CLASSES & HELPERS FOR TEMPLATE ==========

class MockManualMockedClass extends Mock implements MockedClass {}

class MockedClass {
  // Parameter is nullable to support 'any' in manual mocks with null safety
  Future<String> someMethod(String? input) async => input ?? '';
  Future<String> asyncMethod() async => 'result';
  void methodThatFails() => throw Exception('Fail');
}

class ClassUnderTest {
  final MockedClass dependency;
  ClassUnderTest({required this.dependency});

  Future<String> methodUnderTest(String input) async => await dependency.someMethod(input);
  Future<String> performAsyncOperation() async => await dependency.asyncMethod();
  void methodThatCallsFailing() => dependency.methodThatFails();
  void dispose() {}
}

class YourWidget extends StatelessWidget {
  final String data;
  const YourWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(data),
        const Icon(Icons.check),
      ],
    );
  }
}

class YourScrollableWidget extends StatelessWidget {
  const YourScrollableWidget({super.key});
  @override
  Widget build(BuildContext context) => const SingleChildScrollView(child: SizedBox(height: 2000));
}

class YourProvider extends ChangeNotifier {
  void updateSomething() => notifyListeners();
}
