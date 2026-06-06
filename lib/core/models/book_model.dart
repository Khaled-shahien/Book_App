class BookModel {
  final String id;
  final String title;
  final String authors;
  final String thumbnail;
  final String description;
  final String publishedDate;
  final String category;
  final double rating;
  final int ratingsCount;
  final int pageCount;
  final bool isFree;

  BookModel({
    required this.id,
    required this.title,
    required this.authors,
    required this.thumbnail,
    required this.description,
    required this.publishedDate,
    required this.category,
    required this.rating,
    required this.ratingsCount,
    required this.pageCount,
    required this.isFree,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final volumeInfo = _readMap(json['volumeInfo']);
    final saleInfo = _readMap(json['saleInfo']);
    final accessInfo = _readMap(json['accessInfo']);
    final imageLinks = _readMap(volumeInfo['imageLinks']);

    final saleability = _readString(saleInfo['saleability']);
    final accessViewStatus = _readString(accessInfo['accessViewStatus']);
    final isEbook = saleInfo['isEbook'] == true;
    final isFree =
        saleability == 'FREE' ||
        accessViewStatus == 'FULL_PUBLIC_DOMAIN' ||
        isEbook && !saleInfo.containsKey('listPrice');

    return BookModel(
      id: _readString(json['id']),
      title: _readString(volumeInfo['title'], fallback: 'No Title'),
      authors: _readAuthors(volumeInfo['authors']),
      thumbnail: _readString(imageLinks['thumbnail']),
      description: _readString(
        volumeInfo['description'],
        fallback: 'No Description',
      ),
      publishedDate: _readString(
        volumeInfo['publishedDate'],
        fallback: 'Unknown',
      ),
      category: _readFirstString(volumeInfo['categories'], fallback: 'General'),
      rating: _readDouble(volumeInfo['averageRating']),
      ratingsCount: _readInt(volumeInfo['ratingsCount']),
      pageCount: _readInt(volumeInfo['pageCount']),
      isFree: isFree,
    );
  }

  static Map<String, dynamic> _readMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    return <String, dynamic>{};
  }

  static String _readString(Object? value, {String fallback = ''}) {
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return fallback;
  }

  static String _readAuthors(Object? value) {
    if (value is List<Object?>) {
      final authors = value.whereType<String>().where((author) {
        return author.trim().isNotEmpty;
      }).toList();

      if (authors.isNotEmpty) {
        return authors.join(', ');
      }
    }
    return 'Unknown Author';
  }

  static String _readFirstString(Object? value, {required String fallback}) {
    if (value is List<Object?> && value.isNotEmpty) {
      return _readString(value.first, fallback: fallback);
    }
    return fallback;
  }

  static double _readDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return 0.0;
  }

  static int _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }
}
