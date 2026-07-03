import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/library_provider.dart';
import 'screens/library_screen.dart';

void main() {
  runApp(const EbookLibraryApp());
}

class EbookLibraryApp extends StatelessWidget {
  const EbookLibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LibraryProvider()..loadEbooks(),
      child: MaterialApp(
        title: 'Ebook Library',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF6B4226), // warm wood tone for the shelf theme
          scaffoldBackgroundColor: const Color(0xFFF5EFE6),
        ),
        home: const LibraryScreen(),
      ),
    );
  }
}
