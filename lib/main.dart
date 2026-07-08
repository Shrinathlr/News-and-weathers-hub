import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/local/hive_setup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env is optional in dev if NEWS_API_KEY is passed via --dart-define instead;
  // see README for both options.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // No .env present — fall back to --dart-define(-from-file) values if used.
  }

  await HiveSetup.init();

  runApp(const ProviderScope(child: NewsWeatherHubApp()));
}
