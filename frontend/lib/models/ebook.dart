class Ebook {
  final int id;
  final String title;
  final String? author;
  final String? fileType;
  final int? fileSize;
  final String? filename;
  final String? coverUrl;
  final String? fileUrl;
  final String? downloadUrl;
  final DateTime createdAt;

  Ebook({
    required this.id,
    required this.title,
    this.author,
    this.fileType,
    this.fileSize,
    this.filename,
    this.coverUrl,
    this.fileUrl,
    this.downloadUrl,
    required this.createdAt,
  });

  factory Ebook.fromJson(Map<String, dynamic> json) {
    return Ebook(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Untitled',
      author: json['author'] as String?,
      fileType: json['file_type'] as String?,
      fileSize: json['file_size'] as int?,
      filename: json['filename'] as String?,
      coverUrl: json['cover_url'] as String?,
      fileUrl: json['file_url'] as String?,
      downloadUrl: json['download_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  bool get isPdf => fileType == 'application/pdf';
  bool get isEpub => fileType == 'application/epub+zip';

  String get readableSize {
    if (fileSize == null) return '';
    final kb = fileSize! / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }
}
