import 'package:book_app/core/models/book_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

void main() {
  group('BookModel.fromJson', () {
    test('parses a full volume', () {
      final b = BookModel.fromJson(volumeJson());
      expect(b.id, 'id-1');
      expect(b.title, 'Clean Code');
      expect(b.authors, 'Robert C. Martin');
      expect(b.category, 'Computers');
      expect(b.rating, 4.0);
      expect(b.ratingsCount, 12);
      expect(b.pageCount, 464);
      expect(b.isFree, isFalse);
    });

    test('upgrades http thumbnails to https', () {
      final b = BookModel.fromJson(volumeJson());
      expect(b.thumbnail, 'https://books.google.com/cover.jpg');
    });

    test('free saleability marks the book free', () {
      expect(BookModel.fromJson(volumeJson(free: true)).isFree, isTrue);
    });

    test('never crashes on unexpected shapes and uses fallbacks', () {
      final b = BookModel.fromJson(<String, dynamic>{
        'id': 42,
        'volumeInfo': 'not a map',
        'saleInfo': null,
      });
      expect(b.id, '');
      expect(b.title, 'No Title');
      expect(b.authors, 'Unknown Author');
      expect(b.category, 'General');
      expect(b.thumbnail, '');
      expect(b.rating, 0);
    });
  });
}
