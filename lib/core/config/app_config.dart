/// Compile-time environment configuration.
///
/// Values are injected with `--dart-define-from-file=env/<flavor>.json`
/// (see `env/*.example.json`). Nothing secret is hardcoded here; every value
/// has a safe default so `flutter run` works without extra flags.
abstract final class AppConfig {
  /// One of `dev`, `staging`, `prod`.
  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  /// Base URL of the Google Books API (must be HTTPS).
  static const String booksApiBaseUrl = String.fromEnvironment(
    'BOOKS_API_BASE_URL',
    defaultValue: 'https://www.googleapis.com/books/v1/',
  );

  /// Optional Google Books API key. Empty means anonymous (rate-limited)
  /// access. Restrict the key to the app's package/bundle ID in Google Cloud.
  static const String booksApiKey = String.fromEnvironment('BOOKS_API_KEY');

  static bool get isProduction => environment == 'prod';
}
