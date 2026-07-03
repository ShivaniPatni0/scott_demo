import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/ebook.dart';

/// Thrown for any non-2xx API response, carrying a user-displayable message.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  /// iOS simulator: localhost works. Android emulator: use 10.0.2.2.
  /// Physical device: use your machine's LAN IP. Override via --dart-define=API_BASE_URL=...
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
  );

  Future<List<Ebook>> fetchEbooks({String? query}) async {
    final uri = Uri.parse('$_baseUrl/ebooks').replace(
      queryParameters: (query != null && query.isNotEmpty) ? {'q': query} : null,
    );

    final response = await _safeGet(uri);
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => Ebook.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Ebook> uploadEbook({
    required String title,
    String? author,
    required File file,
  }) async {
    final uri = Uri.parse('$_baseUrl/ebooks');
    final request = http.MultipartRequest('POST', uri)
      ..fields['ebook[title]'] = title
      ..fields['ebook[author]'] = author ?? ''
      ..files.add(await http.MultipartFile.fromPath('ebook[file]', file.path));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 201) {
      return Ebook.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw ApiException(_extractError(response), statusCode: response.statusCode);
  }

  Future<void> deleteEbook(int id) async {
    final uri = Uri.parse('$_baseUrl/ebooks/$id');
    final response = await http.delete(uri);

    if (response.statusCode != 204) {
      throw ApiException(_extractError(response), statusCode: response.statusCode);
    }
  }

  String downloadUrlFor(Ebook ebook) => '$_baseUrl/ebooks/${ebook.id}/download';

  Future<http.Response> _safeGet(Uri uri) async {
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }
      throw ApiException(_extractError(response), statusCode: response.statusCode);
    } on SocketException {
      throw ApiException('Could not reach the server. Is the Rails backend running?');
    }
  }

  String _extractError(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['errors'] is List) {
        return (body['errors'] as List).join(', ');
      }
      if (body is Map && body['error'] != null) {
        return body['error'].toString();
      }
    } catch (_) {
      // fall through to generic message
    }
    return 'Something went wrong (${response.statusCode}).';
  }
}
