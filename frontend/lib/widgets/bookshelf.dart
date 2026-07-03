import 'package:flutter/material.dart';
import '../models/ebook.dart';
import 'ebook_cover.dart';

/// Lays ebooks out in rows of a fixed size, each row rendered on top of a
/// wooden shelf-plank, mimicking the classic iOS "Books"-style shelf.
class Bookshelf extends StatelessWidget {
  final List<Ebook> ebooks;
  final void Function(Ebook) onOpen;
  final void Function(Ebook) onDeleteRequest;
  final int booksPerRow;

  const Bookshelf({
    super.key,
    required this.ebooks,
    required this.onOpen,
    required this.onDeleteRequest,
    this.booksPerRow = 4,
  });

  List<List<Ebook>> _rows() {
    final rows = <List<Ebook>>[];
    for (var i = 0; i < ebooks.length; i += booksPerRow) {
      rows.add(ebooks.sublist(i, (i + booksPerRow).clamp(0, ebooks.length)));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      itemCount: rows.length,
      itemBuilder: (context, rowIndex) {
        final row = rows[rowIndex];
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            children: [
              SizedBox(
                height: 150,
                child: Row(
                  children: [
                    for (final ebook in row)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: EbookCover(
                            ebook: ebook,
                            onTap: () => onOpen(ebook),
                            onLongPress: () => onDeleteRequest(ebook),
                          ),
                        ),
                      ),
                    // pad the last row so covers don't stretch full-width
                    for (var i = row.length; i < booksPerRow; i++) const Expanded(child: SizedBox()),
                  ],
                ),
              ),
              // the wooden shelf plank beneath each row
              Container(
                height: 14,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5E3C), Color(0xFF6B4226)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
