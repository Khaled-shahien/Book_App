import 'package:book_app/core/models/book_model.dart';

Map<String, dynamic> volumeJson({
  String id = 'id-1',
  String title = 'Clean Code',
  bool free = false,
  String? thumbnail = 'http://books.google.com/cover.jpg',
}) {
  return <String, dynamic>{
    'id': id,
    'volumeInfo': <String, dynamic>{
      'title': title,
      'authors': <Object?>['Robert C. Martin', '', null],
      'description': 'A handbook',
      'publishedDate': '2008-08-01',
      'categories': <Object?>['Computers'],
      'averageRating': 4,
      'ratingsCount': 12.0,
      'pageCount': 464,
      if (thumbnail != null)
        'imageLinks': <String, dynamic>{'thumbnail': thumbnail},
    },
    'saleInfo': <String, dynamic>{'saleability': free ? 'FREE' : 'FOR_SALE'},
  };
}

BookModel book({String id = 'id-1', bool free = false}) =>
    BookModel.fromJson(volumeJson(id: id, free: free));
