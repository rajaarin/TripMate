import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/env.dart';

class LocationService {
  // API Key is loaded from lib/core/env.dart
  // Make sure to add lib/core/env.dart to your .gitignore file
  static const String _apiKey = Env.openRouterApiKey;
  static const String _baseUrl =
      'https://openrouter.ai/api/v1/chat/completions';

  Future<String> fetchLocationBrief(String destination) async {
    if (_apiKey == 'YOUR_OPENROUTER_API_KEY') {
      await Future.delayed(const Duration(seconds: 1));
      return 'API Key not configured. Please add your OpenRouter API key in lib/data/services/location_service.dart.';
    }

    try {
      print('Requesting description for $destination...');
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer':
              'https://github.com/travel-planner', // Required by OpenRouter
          'X-Title': 'Travel Planner', // Required by OpenRouter
        },
        body: jsonEncode({
          'model': 'xiaomi/mimo-v2-flash:free',
          'messages': [
            {
              'role': 'user',
              'content':
                  'Give me a short, neutral, 2-sentence overview of $destination for a traveler. No promotional text.',
            },
          ],
        }),
      );

      print('Description Response Status: ${response.statusCode}');
      print('Description Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices']?[0]?['message']?['content'] ??
            'No description available.';
      }
      return 'Description unavailable (Status: ${response.statusCode}).';
    } catch (e) {
      print('Error fetching description: $e');
      return 'Error fetching description: $e';
    }
  }

  Future<List<Map<String, String>>> fetchSuggestedPlaces(
    String destination,
  ) async {
    if (_apiKey == 'YOUR_OPENROUTER_API_KEY') {
      return [];
    }

    try {
      print('Requesting suggestions for $destination...');
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer':
              'https://github.com/travel-planner', // Required by OpenRouter
          'X-Title': 'Travel Planner', // Required by OpenRouter
        },
        body: jsonEncode({
          'model': 'xiaomi/mimo-v2-flash:free',
          'messages': [
            {
              'role': 'user',
              'content':
                  'List 3 must-visit places in $destination. Return ONLY a JSON array of objects with keys: "name", "description" (short), and "image_keyword" (for searching an image). Do not include markdown formatting.',
            },
          ],
        }),
      );

      print('Suggestions Response Status: ${response.statusCode}');
      print('Suggestions Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String content = data['choices']?[0]?['message']?['content'] ?? '[]';

        // Clean up potential markdown code blocks
        content = content
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();

        final List<dynamic> jsonList = jsonDecode(content);
        return jsonList
            .map(
              (item) => {
                'name': item['name'].toString(),
                'description': item['description'].toString(),
                'image_keyword': item['image_keyword'].toString(),
              },
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching suggestions: $e');
      return [];
    }
  }
}
