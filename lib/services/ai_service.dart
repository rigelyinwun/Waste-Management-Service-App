import 'dart:convert';
import '../models/ai_analysis_model.dart';
import 'package:http/http.dart' as http;

class AIService {
  final String apiKey = const String.fromEnvironment('AI_API_KEY');

  Future<AIAnalysis> analyzeWaste({
    required String description,
  }) async {

    final response = await http.post(
      Uri.parse(
        "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$apiKey",
      ),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text": """
  You are a waste management AI.

  Analyze the waste description below and respond ONLY in valid JSON format:

  {
    "category": "string",
    "estimatedWeightKg": number,
    "recommendedTransport": "string",
    "estimatedCost": number,
    "hazardLevel": "low | medium | high",
    "isRecyclable": boolean
  }

  Description:
  $description
  """
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.2
        }
      }),
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode != 200) {
      throw Exception("AI Error: ${response.body}");
    }

    final data = jsonDecode(response.body);

    final rawText = data["candidates"][0]["content"]["parts"][0]["text"];

    // Remove markdown ```json and ``` if present
    final cleanedText = rawText
        .replaceAll("```json", "")
        .replaceAll("```", "")
        .trim();

    print("CLEANED JSON: $cleanedText");

    return AIAnalysis.fromMap(jsonDecode(cleanedText));
  }
}