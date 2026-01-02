import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'trip_model.g.dart';

@HiveType(typeId: 0)
class Trip extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String destination;

  @HiveField(3)
  DateTime startDate;

  @HiveField(4)
  DateTime endDate;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  List<ItineraryItem> itinerary;

  Trip({
    String? id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.notes,
    List<ItineraryItem>? itinerary,
  }) : id = id ?? const Uuid().v4(),
       itinerary = itinerary ?? [];
}

@HiveType(typeId: 1)
class ItineraryItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  int dayIndex; // 0-based index relative to start date

  @HiveField(2)
  String activity;

  @HiveField(3)
  bool isCompleted;

  ItineraryItem({
    String? id,
    required this.dayIndex,
    required this.activity,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();
}
