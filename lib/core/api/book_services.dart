// ================= Book Services =================
import 'package:dio/dio.dart';
import 'dart:developer';

class BookServices {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://www.googleapis.com/books/v1/',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Future<List<dynamic>> fetchBooks(String query, {int maxResults = 30}) async {
    try {
      log('🔍 Fetching books for query: $query');
      
      final response = await _dio.get(
        'volumes',
        queryParameters: {
          'q': query,
          'maxResults': maxResults,
          'orderBy': 'relevance',
          'printType': 'books',
        },
      );

      log('✅ API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final items = response.data['items'] as List<dynamic>? ?? [];
        log('📚 Books found: ${items.length}');
        return items;
      } else {
        log('❌ API Error: ${response.statusCode}');
        throw Exception('API Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ DIO ERROR: ${e.type}', error: e);
      log('Message: ${e.message}');
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection. Please check your network.');
      } else {
        throw Exception('Failed to load books. Please try again.');
      }
    } catch (e) {
      log('❌ UNKNOWN ERROR', error: e);
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Method للبحث المتقدم
  Future<List<dynamic>> searchBooksAdvanced({
    String? title,
    String? author,
    String? subject,
    String? isbn,
  }) async {
    String query = '';
    
    if (title != null && title.isNotEmpty) {
      query += 'intitle:$title+';
    }
    if (author != null && author.isNotEmpty) {
      query += 'inauthor:$author+';
    }
    if (subject != null && subject.isNotEmpty) {
      query += 'subject:$subject+';
    }
    if (isbn != null && isbn.isNotEmpty) {
      query += 'isbn:$isbn+';
    }

    if (query.isEmpty) {
      query = 'flutter'; // default query
    } else {
      query = query.substring(0, query.length - 1); // remove last '+'
    }

    return fetchBooks(query);
  }
}

