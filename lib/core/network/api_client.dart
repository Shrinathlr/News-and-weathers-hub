import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

/// Retries a failed request up to [AppConstants.maxRetries] times with a
/// short exponential backoff. Only retries on network-level failures,
/// timeouts, and 5xx — never retries 4xx (client errors) except 429.
class RetryInterceptor extends Interceptor {
  final Dio dio;
  RetryInterceptor(this.dio);

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final attempt = (requestOptions.extra['retry_attempt'] as int?) ?? 0;

    final shouldRetry = attempt < AppConstants.maxRetries && _isRetryable(err);

    if (!shouldRetry) {
      return handler.next(err);
    }

    final nextAttempt = attempt + 1;
    final delay = AppConstants.retryBaseDelay * nextAttempt; // linear-ish backoff
    await Future.delayed(delay);

    try {
      requestOptions.extra['retry_attempt'] = nextAttempt;
      final response = await dio.fetch(requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  bool _isRetryable(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }
    final status = err.response?.statusCode;
    if (status == null) return false;
    if (status == 429) return true; // rate limit -> retry once with backoff
    if (status >= 500 && status < 600) return true;
    return false;
  }
}

class ApiClient {
  static Dio create({String? baseUrl, Map<String, dynamic>? defaultQueryParams}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? '',
        connectTimeout: AppConstants.requestTimeout,
        receiveTimeout: AppConstants.requestTimeout,
        queryParameters: defaultQueryParams,
      ),
    );
    dio.interceptors.add(RetryInterceptor(dio));
    return dio;
  }
}
