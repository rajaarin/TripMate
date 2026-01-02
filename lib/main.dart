import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'data/models/trip_model.dart';
import 'data/repositories/trip_repository.dart';
import 'features/trips/providers/trip_provider.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(TripAdapter());
  Hive.registerAdapter(ItineraryItemAdapter());

  // Initialize Repository
  final tripRepository = TripRepository();
  await tripRepository.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TripProvider(tripRepository)),
      ],
      child: const TravelPlannerApp(),
    ),
  );
}

class TravelPlannerApp extends StatelessWidget {
  const TravelPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripNote',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
