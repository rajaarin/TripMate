import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/trip_model.dart';
import '../../../data/services/location_service.dart';
import '../../../core/constants.dart';
import '../providers/trip_provider.dart';

class OverviewTab extends StatefulWidget {
  final Trip trip;

  const OverviewTab({super.key, required this.trip});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  String? _locationBrief;
  List<Map<String, String>> _suggestedPlaces = [];
  bool _isLoading = false;
  final LocationService _locationService = LocationService();

  Future<void> _fetchLocationBrief() async {
    setState(() {
      _isLoading = true;
    });

    final brief = await _locationService.fetchLocationBrief(
      widget.trip.destination,
    );
    final suggestions = await _locationService.fetchSuggestedPlaces(
      widget.trip.destination,
    );

    if (mounted) {
      setState(() {
        _locationBrief = brief;
        _suggestedPlaces = suggestions;
        _isLoading = false;
      });
    }
  }

  void _addToItinerary(Map<String, String> place) {
    final item = ItineraryItem(
      dayIndex: 0, // Default to Day 1
      activity: 'Visit ${place['name']}',
    );

    Provider.of<TripProvider>(
      context,
      listen: false,
    ).addItineraryItem(widget.trip, item);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${place['name']}" to Day 1'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            Provider.of<TripProvider>(
              context,
              listen: false,
            ).deleteItineraryItem(widget.trip, item);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, y');
    final duration =
        widget.trip.endDate.difference(widget.trip.startDate).inDays + 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.trip.destination,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start Date',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          Text(
                            dateFormat.format(widget.trip.startDate),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'End Date',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          Text(
                            dateFormat.format(widget.trip.endDate),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$duration Days',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Destination Overview',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (_locationBrief == null && !_isLoading)
            ElevatedButton.icon(
              onPressed: _fetchLocationBrief,
              icon: const Icon(Icons.auto_awesome_outlined),
              label: const Text('Get Place Overview'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                side: BorderSide(color: Colors.grey.shade300),
              ),
            )
          else if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                _locationBrief!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Suggested Places',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_suggestedPlaces.isEmpty)
              const Text('No suggestions available.')
            else
              SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _suggestedPlaces.length,
                  itemBuilder: (context, index) {
                    final place = _suggestedPlaces[index];
                    return Container(
                      width: 240,
                      margin: const EdgeInsets.only(right: 16),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 140,
                                  width: double.infinity,
                                  color: Colors.grey.shade300,
                                  child: Image.network(
                                    'https://image.pollinations.ai/prompt/${Uri.encodeComponent(place['image_keyword']!)}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        place['name']!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        place['description']!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 16,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.add,
                                    size: 20,
                                    color: AppColors.primary,
                                  ),
                                  onPressed: () => _addToItinerary(place),
                                  tooltip: 'Add to Itinerary',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ],
      ),
    );
  }
}
