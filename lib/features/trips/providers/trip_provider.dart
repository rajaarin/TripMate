import 'package:flutter/foundation.dart';
import '../../../data/models/trip_model.dart';
import '../../../data/repositories/trip_repository.dart';

class TripProvider extends ChangeNotifier {
  final TripRepository _repository;
  List<Trip> _trips = [];

  TripProvider(this._repository) {
    _loadTrips();
  }

  List<Trip> get trips => _trips;

  void _loadTrips() {
    _trips = _repository.getTrips();
    // Sort by start date, most recent first
    _trips.sort((a, b) => a.startDate.compareTo(b.startDate));
    notifyListeners();
  }

  Future<void> addTrip(Trip trip) async {
    // Generate initial itinerary days
    final days = trip.endDate.difference(trip.startDate).inDays + 1;
    for (int i = 0; i < days; i++) {
      // We don't need to pre-fill itinerary items, but we could if we had a structure for days.
      // For now, the itinerary is just a list of items with day indices.
    }

    await _repository.addTrip(trip);
    _loadTrips();
  }

  Future<void> updateTrip(Trip trip) async {
    await _repository.updateTrip(trip);
    _loadTrips();
  }

  Future<void> deleteTrip(Trip trip) async {
    await _repository.deleteTrip(trip);
    _loadTrips();
  }

  Future<void> addItineraryItem(Trip trip, ItineraryItem item) async {
    trip.itinerary.add(item);
    await trip.save();
    notifyListeners();
  }

  Future<void> toggleActivityCompletion(Trip trip, ItineraryItem item) async {
    item.isCompleted = !item.isCompleted;
    await trip.save(); // Saving the trip saves its HiveObjects
    notifyListeners();
  }

  Future<void> deleteItineraryItem(Trip trip, ItineraryItem item) async {
    trip.itinerary.remove(item);
    await trip.save();
    notifyListeners();
  }
}
