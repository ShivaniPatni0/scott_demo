import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/ebook.dart';

/// A book spine/cover tile used on the shelf. Falls back to a generated
/// placeholder (title initial + color derived from the title) when no
/// cover image was uploaded.
class EbookCover extends StatelessWidget {
  final Ebook ebook;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const EbookCover({
    super.key,
    required this.ebook,
    required this.onTap,
    required this.onLongPress,
  });

  Color _placeholderColor() {
    final palette = [
      const Color(0xFF8E5B3C),
      const Color(0xFF3C6E71),
      const Color(0xFF9B2226),
      const Color(0xFF4A5859),
      const Color(0xFF7B506F),
    ];
    return palette[ebook.title.hashCode.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Hero(
        tag: 'ebook-cover-${ebook.id}',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 4,
                offset: const Offset(2, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: ebook.coverUrl != null
              ? CachedNetworkImage(
                  imageUrl: ebook.coverUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => _placeholder(),
                )
              : _placeholder(),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: _placeholderColor(),
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            ebook.isEpub ? Icons.menu_book : Icons.picture_as_pdf,
            color: Colors.white70,
            size: 22,
          ),
          const SizedBox(height: 6),
          Text(
            ebook.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
