import 'package:book_app/core/models/book_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookModel.fromJson', () {
    test('maps Google Books metadata into the domain model', () {
      final book = BookModel.fromJson({
        'id': 'book-1',
        'volumeInfo': {
          'title': 'Clean Architecture',
          'authors': ['Robert C. Martin'],
          'imageLinks': {'thumbnail': 'https://example.com/cover.png'},
          'description': 'A software architecture guide.',
          'publishedDate': '2017',
          'categories': ['Software'],
          'averageRating': 4,
          'ratingsCount': 120,
          'pageCount': 432,
        },
        'saleInfo': {
          'saleability': 'FOR_SALE',
          'isEbook': true,
          'listPrice': {'amount': 24.99},
        },
        'accessInfo': {'accessViewStatus': 'SAMPLE'},
      });

      expect(book.id, 'book-1');
      expect(book.title, 'Clean Architecture');
      expect(book.authors, 'Robert C. Martin');
      expect(book.category, 'Software');
      expect(book.rating, 4.0);
      expect(book.ratingsCount, 120);
      expect(book.pageCount, 432);
      expect(book.isFree, isFalse);
    });

    test('uses safe defaults when optional metadata is missing', () {
      final book = BookModel.fromJson({'id': 'book-2'});

      expect(book.title, 'No Title');
      expect(book.authors, 'Unknown Author');
      expect(book.description, 'No Description');
      expect(book.publishedDate, 'Unknown');
      expect(book.category, 'General');
      expect(book.rating, 0);
      expect(book.ratingsCount, 0);
      expect(book.pageCount, 0);
      expect(book.isFree, isFalse);
    });

    test('marks explicitly free books as free', () {
      final book = BookModel.fromJson({
        'saleInfo': {'saleability': 'FREE'},
      });

      expect(book.isFree, isTrue);
    });

    test('marks full public-domain access as free', () {
      final book = BookModel.fromJson({
        'accessInfo': {'accessViewStatus': 'FULL_PUBLIC_DOMAIN'},
      });

      expect(book.isFree, isTrue);
    });
  });
}
