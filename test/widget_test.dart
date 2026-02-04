// Basic widget test for One Safe Tile game.
//
// These tests verify that the app launches correctly and basic UI interactions work.

import 'package:flutter_test/flutter_test.dart';

import 'package:one_safe_tile/main.dart';

void main() {
  testWidgets('App launches with menu screen', (WidgetTester tester) async {
    // Build the app and trigger a frame
    await tester.pumpWidget(const OneSafeTileApp());

    // Verify the app title is displayed
    expect(find.text('ONE SAFE'), findsOneWidget);
    expect(find.text('TILE'), findsOneWidget);
    
    // Verify the play button is shown
    expect(find.text('PLAY'), findsOneWidget);
  });
}
