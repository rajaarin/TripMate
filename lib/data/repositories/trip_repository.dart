import 'package:hive_flutter/hive_flutter.dart';
import '../models/trip_model.dart';
import '../../core/constants.dart';

class TripRepository {
  late Box<Trip> _tripsBox;

  Future<void> init() async {
    _tripsBox = await Hive.openBox<Trip>(AppConstants.tripsBoxName);
  }

  List<Trip> getTrips() {
    return _tripsBox.values.toList();
  }

  Future<void> addTrip(Trip trip) async {
    await _tripsBox.add(trip);
  }

  Future<void> updateTrip(Trip trip) async {
    await trip.save();
  }

  Future<void> deleteTrip(Trip trip) async {
    await trip.delete();
  }
}
