/// Typed, user-presentable failures produced by the data layer.
///
/// UI code shows [message] directly; it never shows `e.toString()`.
sealed class Failure implements Exception {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'No internet connection. Please check your network.',
  ]);
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure([
    super.message =
        'The connection timed out. Please check your internet connection.',
  ]);
}

final class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'The server could not complete the request. Try again.',
  ]);
}

final class RateLimitFailure extends Failure {
  const RateLimitFailure([
    super.message = 'Too many requests. Please wait a moment and try again.',
  ]);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([
    super.message = 'Something went wrong. Please try again.',
  ]);
}
