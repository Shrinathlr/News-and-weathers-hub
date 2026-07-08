import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../core/errors/app_failure.dart';

/// Resolves the device's current position, mapping every Geolocator failure
/// mode (service disabled, denied, denied forever) into an [AppFailure] so
/// the UI can render a specific message instead of a generic error.
class LocationService {
  Future<Result<Position>> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const Result.failure(LocationServiceDisabledFailure());
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return const Result.failure(LocationPermissionFailure());
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return const Result.failure(LocationPermissionFailure());
    }

    try {
      // Fast path: return a recent cached fix immediately if available, so
      // the UI isn't stuck spinning while a fresh GPS fix is acquired.
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        // Kick off a fresh fetch in the background for next time, but don't await it.
        Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 10),
        ).catchError((_) => last);
        return Result.success(last);
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
      return Result.success(position);
    } catch (_) {
      return const Result.failure(
        UnknownFailure('Could not get current location.'),
      );
    }
  }

  Future<void> openAppSettings() => Geolocator.openAppSettings();
}

final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(),
);
