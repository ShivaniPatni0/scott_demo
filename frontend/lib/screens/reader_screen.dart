import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/ebook.dart';
import '../services/api_service.dart';

/// Reads PDFs in-app via Syncfusion's viewer. EPUBs are opened externally
/// (add an EPUB renderer package like `epub_view` if in-app EPUB reading
/// becomes a requirement — kept out here to limit dependency surface area).
class ReaderScreen extends StatelessWidget {
  final Ebook ebook;
  const ReaderScreen({super.key, required this.ebook});

  @override
  Widget build(BuildContext context) {
    final api = ApiService();

    return Scaffold(
      appBar: AppBar(
        title: Text(ebook.title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Download',
            onPressed: () async {
              final uri = Uri.parse(api.downloadUrlFor(ebook));
              final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
              if (!launched && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not start the download')),
                );
              }
            },
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (ebook.isPdf && ebook.fileUrl != null) {
      return SfPdfViewer.network(
        ebook.fileUrl!,
        canShowScrollHead: true,
        canShowScrollStatus: true,
      );
    }

    // EPUB or missing file: offer to open externally instead of a blank screen.
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_outlined, size: 56),
            const SizedBox(height: 12),
            Text(
              ebook.isEpub
                  ? 'In-app EPUB reading isn\'t wired up yet — download to read in your preferred EPUB app.'
                  : 'This file can\'t be previewed. Try downloading it instead.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => launchUrl(
                Uri.parse(ApiService().downloadUrlFor(ebook)),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.download),
              label: const Text('Download'),
            ),
          ],
        ),
      ),
    );
  }
}
