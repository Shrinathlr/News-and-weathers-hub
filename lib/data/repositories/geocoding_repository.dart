import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_failure.dart';
import '../models/city_model.dart';

class GeocodingRepository {
  final Dio _dio;
  GeocodingRepository({required Dio dio}) : _dio = dio;

  /// Looks up candidate cities for a search string. Supports cancellation
  /// via [cancelToken] so the caller (debounced search bar) can abort an
  /// in-flight request when the user keeps typing.
  Future<Result<List<CityResult>>> searchCity(String query, {CancelToken? cancelToken}) async {
    if (query.trim().isEmpty) return const Result.success([]);
    try {
      final response = await _dio.get(
        AppConstants.geocodingBaseUrl,
        queryParameters: {'name': query.trim(), 'count': 8},
        cancelToken: cancelToken,
      );
      final results = response.data['results'] as List?;
      if (results == null || results.isEmpty) {
        return const Result.failure(CityNotFoundFailure());
      }
      final cities = results
          .map((e) => CityResult.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return Result.success(cities);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        // Swallow: a newer request superseded this one.
        return const Result.success([]);
      }
      return const Result.failure(UnknownFailure('Could not search city.'));
    }
  }
}
