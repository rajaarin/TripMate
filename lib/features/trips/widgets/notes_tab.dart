import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/trip_model.dart';
import '../providers/trip_provider.dart';
import '../../../core/constants.dart';

class NotesTab extends StatefulWidget {
  final Trip trip;

  const NotesTab({super.key, required this.trip});

  @override
  State<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab> {
  late TextEditingController _controller;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.trip.notes);
    _controller.addListener(() {
      if (_controller.text != (widget.trip.notes ?? '')) {
        if (!_isDirty) setState(() => _isDirty = true);
      } else {
        if (_isDirty) setState(() => _isDirty = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveNotes() {
    widget.trip.notes = _controller.text;
    Provider.of<TripProvider>(context, listen: false).updateTrip(widget.trip);
    setState(() => _isDirty = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Notes saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: 'Write your trip notes here...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isDirty ? _saveNotes : null,
              icon: const Icon(Icons.save),
              label: const Text('Save Notes'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey.shade300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
