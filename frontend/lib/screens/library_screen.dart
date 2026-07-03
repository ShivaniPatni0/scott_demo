import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ebook.dart';
import '../services/library_provider.dart';
import '../widgets/bookshelf.dart';
import '../widgets/state_views.dart';
import 'reader_screen.dart';
import 'upload_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<LibraryProvider>().loadEbooks(query: value);
    });
  }

  Future<void> _confirmDelete(Ebook ebook) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this ebook?'),
        content: Text('"${ebook.title}" will be permanently removed from your library.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final ok = await context.read<LibraryProvider>().delete(ebook);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Deleted "${ebook.title}"' : 'Could not delete the ebook')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookshelf'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by title, author, or filename',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<LibraryProvider>().loadEbooks(query: '');
                        },
                      )
                    : null,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UploadScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Ebook'),
      ),
      body: Consumer<LibraryProvider>(
        builder: (context, provider, _) {
          switch (provider.state) {
            case LoadState.idle:
            case LoadState.loading:
              return const LoadingShelfView();
            case LoadState.error:
              return ErrorShelfView(
                message: provider.errorMessage ?? 'Something went wrong',
                onRetry: () => provider.loadEbooks(),
              );
            case LoadState.loaded:
              if (provider.ebooks.isEmpty) {
                return EmptyShelfView(
                  message: provider.query.isNotEmpty
                      ? 'No ebooks match "${provider.query}"'
                      : 'Your shelf is empty — add your first ebook',
                  actionLabel: provider.query.isEmpty ? 'Add Ebook' : null,
                  onAction: provider.query.isEmpty
                      ? () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const UploadScreen()),
                          )
                      : null,
                );
              }
              return RefreshIndicator(
                onRefresh: () => provider.loadEbooks(),
                child: Bookshelf(
                  ebooks: provider.ebooks,
                  onOpen: (ebook) => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ReaderScreen(ebook: ebook)),
                  ),
                  onDeleteRequest: _confirmDelete,
                ),
              );
          }
        },
      ),
    );
  }
}
