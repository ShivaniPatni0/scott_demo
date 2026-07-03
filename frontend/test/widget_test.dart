import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ebook_library/models/ebook.dart';
import 'package:ebook_library/services/library_provider.dart';
import 'package:ebook_library/widgets/bookshelf.dart';
import 'package:ebook_library/widgets/state_views.dart';

Ebook _sampleEbook({int id = 1, String title = 'Sample Book'}) {
  return Ebook(
    id: id,
    title: title,
    author: 'Author Name',
    fileType: 'application/pdf',
    fileSize: 102400,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('EmptyShelfView', () {
    testWidgets('shows the empty message and action button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EmptyShelfView(
            message: 'Your shelf is empty',
            actionLabel: 'Add Ebook',
            onAction: () {},
          ),
        ),
      );

      expect(find.text('Your shelf is empty'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Add Ebook'), findsOneWidget);
    });
  });

  group('Bookshelf', () {
    testWidgets('renders a cover tile for every ebook', (tester) async {
      final ebooks = [
        _sampleEbook(id: 1, title: 'Book One'),
        _sampleEbook(id: 2, title: 'Book Two'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Bookshelf(
              ebooks: ebooks,
              onOpen: (_) {},
              onDeleteRequest: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Book One'), findsOneWidget);
      expect(find.text('Book Two'), findsOneWidget);
    });

    testWidgets('tapping a cover triggers onOpen', (tester) async {
      var openedId = -1;
      final ebooks = [_sampleEbook(id: 42, title: 'Tap Me')];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Bookshelf(
              ebooks: ebooks,
              onOpen: (ebook) => openedId = ebook.id,
              onDeleteRequest: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();

      expect(openedId, 42);
    });
  });

  group('LibraryProvider', () {
    test('starts in idle state with an empty list', () {
      final provider = LibraryProvider();
      expect(provider.state, LoadState.idle);
      expect(provider.ebooks, isEmpty);
    });
  });
}
