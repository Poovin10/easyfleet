import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('light theme uses the depot instrument palette and Plex type', () {
    final theme = AppTheme.light();

    expect(theme.colorScheme.primary, AppColors.signal);
    expect(theme.colorScheme.secondary, AppColors.verified);
    expect(theme.scaffoldBackgroundColor, AppColors.paper);
    expect(theme.textTheme.bodyMedium?.fontFamily, 'IBMPlexSans');
    expect(theme.textTheme.bodyMedium?.fontFeatures, isNotEmpty);
    expect(
      theme.pageTransitionsTheme.builders[TargetPlatform.android],
      isA<AppPageTransition>(),
    );
    expect(theme.appBarTheme.titleTextStyle?.fontWeight, FontWeight.w600);
  });

  test('dark theme uses the petrol surface with readable containers', () {
    final theme = AppTheme.dark();

    expect(theme.colorScheme.surface, AppColors.ink);
    expect(theme.colorScheme.onSurface, AppColors.paper);
    expect(theme.colorScheme.primaryContainer, AppColors.signalPale);
    expect(theme.textTheme.titleLarge?.fontFamily, 'IBMPlexSans');
  });

  testWidgets('depot rail exposes the selected destination to a11y', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppNavigationBar(
            currentIndex: 1,
            onDestinationSelected: (_) {},
            items: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.work_outline),
                label: 'Jobs',
              ),
            ],
          ),
        ),
      ),
    );

    final selected = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.button == true &&
          widget.properties.selected == true,
    );
    expect(selected, findsOneWidget);
    expect(
      find.descendant(of: selected, matching: find.text('Jobs')),
      findsOneWidget,
    );
  });
}
