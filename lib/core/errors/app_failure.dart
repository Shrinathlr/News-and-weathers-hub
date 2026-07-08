/// Unified failure type surfaced to the UI layer.
/// Keeping this as a sealed-ish class (not using freezed to avoid an extra
/// codegen dependency) so the data layer never leaks raw exceptions to widgets.
sealed class AppFailure {
  final String message;
  const AppFailure(this.message);
}

class NoInternetFailure extends AppFailure {
  const NoInternetFailure() : super('No internet connection.');
}

class TimeoutFailure extends AppFailure {
  const TimeoutFailure() : super('Request timed out.');
}

class ServerFailure extends AppFailure {
  final int? statusCode;
  const ServerFailure(this.statusCode, [String? message])
      : super(message ?? 'Server error');
}

class RateLimitFailure extends AppFailure {
  const RateLimitFailure() : super('Rate limit exceeded. Please try again later.');
}

class LocationPermissionFailure extends AppFailure {
  const LocationPermissionFailure() : super('Location permission denied.');
}

class LocationServiceDisabledFailure extends AppFailure {
  const LocationServiceDisabledFailure() : super('Location services are disabled.');
}

class CityNotFoundFailure extends AppFailure {
  const CityNotFoundFailure() : super('City not found.');
}

class UnknownFailure extends AppFailure {
  const UnknownFailure([String? message]) : super(message ?? 'Something went wrong.');
}

/// Simple Result wrapper (avoids pulling in dartz/fpdart for a single use case).
class Result<T> {
  final T? data;
  final AppFailure? failure;
  final bool isFromCache;
  final DateTime? cachedAt;

  const Result.success(this.data, {this.isFromCache = false, this.cachedAt}) : failure = null;
  const Result.failure(this.failure)
      : data = null,
        isFromCache = false,
        cachedAt = null;

  bool get isSuccess => failure == null;
}
