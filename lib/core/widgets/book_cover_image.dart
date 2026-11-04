import 'package:flutter/material.dart';

/// Network book cover with memory-friendly decoding, a loading placeholder
/// and an error fallback.
///
/// [width] is the logical display width; the image is decoded at that size
/// times the device pixel ratio instead of its full resolution.
class BookCoverImage extends StatelessWidget {
  const BookCoverImage({
    super.key,
    required this.url,
    required this.width,
    required this.placeholder,
    this.fit = BoxFit.cover,
    this.semanticLabel,
  });

  final String url;
  final double width;
  final Widget placeholder;
  final BoxFit fit;
  final String? semanticLabel;

  /// Google Books returns `http://` thumbnails; upgrade them so cleartext
  /// traffic can stay disabled.
  static String secureUrl(String url) =>
      url.startsWith('http://') ? 'https://${url.substring(7)}' : url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return placeholder;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return Image.network(
      secureUrl(url),
      fit: fit,
      cacheWidth: (width * dpr).round(),
      semanticLabel: semanticLabel,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : placeholder,
      errorBuilder: (context, error, stack) => placeholder,
    );
  }
}
