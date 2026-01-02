import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/trip_model.dart';
import '../providers/trip_provider.dart';
import '../../../core/constants.dart';

class ItineraryTab extends StatelessWidget {
  final Trip trip;

  const ItineraryTab({super.key, required this.trip});

  void _addActivity(BuildContext context, int dayIndex) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Activity'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'e.g., Visit Museum',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final item = ItineraryItem(
                  dayIndex: dayIndex,
                  activity: controller.text,
                );
                Provider.of<TripProvider>(
                  context,
                  listen: false,
                ).addItineraryItem(trip, item);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = trip.endDate.difference(trip.startDate).inDays + 1;
    final dateFormat = DateFormat('EEEE, MMM d');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: days,
      itemBuilder: (context, index) {
        final date = trip.startDate.add(Duration(days: index));
        final dayItems = trip.itinerary
            .where((item) => item.dayIndex == index)
            .toList();

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Day ${index + 1}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      dateFormat.format(date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                if (dayItems.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'No activities planned',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dayItems.length,
                    itemBuilder: (context, itemIndex) {
                      final item = dayItems[itemIndex];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Checkbox(
                          value: item.isCompleted,
                          onChanged: (val) {
                            Provider.of<TripProvider>(
                              context,
                              listen: false,
                            ).toggleActivityCompletion(trip, item);
                          },
                        ),
                        title: Text(
                          item.activity,
                          style: TextStyle(
                            decoration: item.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: item.isCompleted
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            Provider.of<TripProvider>(
                              context,
                              listen: false,
                            ).deleteItineraryItem(trip, item);
                          },
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _addActivity(context, index),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Activity'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
