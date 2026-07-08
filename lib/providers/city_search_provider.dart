import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/app_failure.dart';
import '../data/models/city_model.dart';
import 'core_providers.dart';

class CitySearchState {
  final List<CityResult> results;
  final bool isLoading;
  final AppFailure? failure;
  const CitySearchState({
    this.results = const [],
    this.isLoading = false,
    this.failure,
  });
}

/// Debounces user keystrokes (~450ms) and cancels any in-flight geocoding
/// request when a newer query comes in, so stale results never render.
class CitySearchNotifier extends StateNotifier<CitySearchState> {
  final Ref _ref;
  Timer? _debounceTimer;
  CancelToken? _cancelToken;

  CitySearchNotifier(this._ref) : super(const CitySearchState());

  void onQueryChanged(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      _cancelToken?.cancel();
      state = const CitySearchState();
      return;
    }

    state = CitySearchState(results: state.results, isLoading: true);
    _debounceTimer = Timer(
      AppConstants.citySearchDebounce,
      () => _search(query),
    );
  }

  Future<void> _search(String query) async {
    _cancelToken?.cancel('superseded by newer query');
    _cancelToken = CancelToken();

    final result = await _ref
        .read(geocodingRepositoryProvider)
        .searchCity(query, cancelToken: _cancelToken);

    if (result.isSuccess) {
      state = CitySearchState(results: result.data ?? []);
    } else {
      state = CitySearchState(failure: result.failure);
    }
  }

  void clear() {
    _debounceTimer?.cancel();
    _cancelToken?.cancel();
    state = const CitySearchState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _cancelToken?.cancel();
    super.dispose();
  }
}

final citySearchProvider = StateNotifierProvider.autoDispose
    .family<CitySearchNotifier, CitySearchState, String>((ref, tag) {
      return CitySearchNotifier(ref);
    });
