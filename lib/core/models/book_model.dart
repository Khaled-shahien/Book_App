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
  final bool isFree;  // Added: هل الكتاب مجاني

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
    final volumeInfo = json['volumeInfo'] ?? {};
    final saleInfo = json['saleInfo'] ?? {};
    final accessInfo = json['accessInfo'] ?? {};

    // Check if book is free
    bool isFree = false;
    if (saleInfo['saleability'] == 'FREE' || 
        accessInfo['accessViewStatus'] == 'FULL_PUBLIC_DOMAIN' ||
        saleInfo['isEbook'] == true && saleInfo['listPrice'] == null) {
      isFree = true;
    }

    return BookModel(
      id: json['id'] ?? '',
      title: volumeInfo['title'] ?? 'No Title',
      authors: volumeInfo['authors'] != null
          ? (volumeInfo['authors'] as List).join(', ')
          : 'Unknown Author',
      thumbnail: volumeInfo['imageLinks']?['thumbnail'] ?? '',
      description: volumeInfo['description'] ?? 'No Description',
      publishedDate: volumeInfo['publishedDate'] ?? 'Unknown',
      category: volumeInfo['categories'] != null
          ? volumeInfo['categories'][0]
          : 'General',

      // Fixed: Handle null values properly with default 0.0
      rating: volumeInfo['averageRating'] != null 
          ? (volumeInfo['averageRating'] as num).toDouble()
          : 0.0,
      ratingsCount: volumeInfo['ratingsCount'] ?? 0,
      pageCount: volumeInfo['pageCount'] ?? 0,
      isFree: isFree,
    );
  }
}