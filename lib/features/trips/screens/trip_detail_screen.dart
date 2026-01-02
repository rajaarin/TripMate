import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/trip_model.dart';
import '../providers/trip_provider.dart';
import 'add_edit_trip_screen.dart';
import '../widgets/overview_tab.dart';
import '../widgets/itinerary_tab.dart';
import '../widgets/notes_tab.dart';

class TripDetailScreen extends StatefulWidget {
  final Trip trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap in Consumer to listen for updates (e.g. after edit)
    return Consumer<TripProvider>(
      builder: (context, provider, child) {
        // Ensure trip still exists (in case of deletion from elsewhere, though unlikely here)
        if (!provider.trips.contains(widget.trip)) {
          return const SizedBox.shrink(); // Or handle gracefully
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.trip.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddEditTripScreen(trip: widget.trip),
                    ),
                  );
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Itinerary'),
                Tab(text: 'Notes'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              OverviewTab(trip: widget.trip),
              ItineraryTab(trip: widget.trip),
              NotesTab(trip: widget.trip),
            ],
          ),
        );
      },
    );
  }
}
