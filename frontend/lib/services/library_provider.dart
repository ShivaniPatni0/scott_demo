import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/ebook.dart';
import 'api_service.dart';

enum LoadState { idle, loading, loaded, error }

class LibraryProvider extends ChangeNotifier {
  final ApiService _api;
  LibraryProvider({ApiService? api}) : _api = api ?? ApiService();

  List<Ebook> _ebooks = [];
  List<Ebook> get ebooks => _ebooks;

  LoadState _state = LoadState.idle;
  LoadState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _query = '';
  String get query => _query;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  Future<void> loadEbooks({String? query}) async {
    _query = query ?? _query;
    _state = LoadState.loading;
    notifyListeners();

    try {
      _ebooks = await _api.fetchEbooks();
      _state = LoadState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = LoadState.error;
    }
    notifyListeners();
  }

  Future<bool> upload({required String title, String? author, required File file}) async {
    _isUploading = true;
    notifyListeners();
    try {
      final ebook = await _api.uploadEbook(title: title, author: author, file: file);
      _ebooks = [ebook, ..._ebooks];
      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(Ebook ebook) async {
    final previous = _ebooks;
    _ebooks = _ebooks.where((e) => e.id != ebook.id).toList();
    notifyListeners();

    try {
      await _api.deleteEbook(ebook.id);
      return true;
    } catch (e) {
      _ebooks = previous; // rollback optimistic delete
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
