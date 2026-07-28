import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // ⚠️ REPLACE WITH YOUR ACTUAL GEMINI API KEY
  static const String _apiKey = 'AIzaSyC9uhezqwM3uPI1BREw2nO9RHLOPtv077E';

  static late GenerativeModel _model;
  static ChatSession? _chatSession;

  static void init() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 2048,
      ),
    );
  }

  // ─── Workout Plan Generator ───
  static Future<String> generateWorkoutPlan({
    required int age,
    required double weight,
    required double height,
    required String goal,
    required String level,
    required int daysPerWeek,
  }) async {
    final prompt = '''
Create a detailed $daysPerWeek-day gym workout plan for:
- Age: $age years
- Weight: ${weight}kg
- Height: ${height}cm
- Goal: $goal
- Level: $level
- Days per week: $daysPerWeek

Please provide a structured plan with:
1. Day-wise breakdown (e.g., Day 1: Chest & Triceps)
2. Each exercise with sets, reps, and rest time
3. Warm-up and cool-down recommendations
4. Important tips for the given fitness level

Format the response clearly with headers and bullet points.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to generate workout plan. Please try again.';
    } catch (e) {
      return 'Error generating workout plan: ${e.toString()}';
    }
  }

  // ─── Diet Plan Generator ───
  static Future<String> generateDietPlan({
    required String dietType,
    required String goal,
    required int calories,
    required String cuisine,
  }) async {
    final prompt = '''
Create a detailed $dietType diet plan for $goal.
- Target calories: $calories per day
- Cuisine preference: $cuisine

Please include:
1. Breakfast (with portion sizes and calories)
2. Mid-morning snack
3. Lunch (with portion sizes and calories)
4. Evening snack
5. Dinner (with portion sizes and calories)
6. Pre/Post workout meals
7. Total macros breakdown (protein, carbs, fats)
8. Hydration recommendations

Format the response clearly with headers and bullet points.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to generate diet plan. Please try again.';
    } catch (e) {
      return 'Error generating diet plan: ${e.toString()}';
    }
  }

  // ─── Chat (Fitness Chatbot) ───
  static Future<String> chat(String message) async {
    _chatSession ??= _model.startChat(history: [
      Content.text(
        'You are FitBot, an expert AI fitness coach. You help users with workout advice, '
        'nutrition guidance, supplement information, and general fitness questions. '
        'Keep responses helpful, concise, and motivating. Use emojis occasionally to be friendly.',
      ),
      Content.model([
        TextPart(
          'Hey there! 💪 I\'m FitBot, your AI fitness coach! I\'m here to help you with '
          'workouts, nutrition, supplements, and anything fitness-related. '
          'What would you like to know?',
        ),
      ]),
    ]);

    try {
      final response = await _chatSession!.sendMessage(Content.text(message));
      return response.text ?? 'Sorry, I couldn\'t process that. Try again!';
    } catch (e) {
      // Reset chat session on error
      _chatSession = null;
      return 'Error: ${e.toString()}';
    }
  }

  // ─── Progress Analysis ───
  static Future<String> analyzeProgress(String progressData) async {
    final prompt = '''
You are a fitness progress analyst. Analyze the following weight tracking data and provide insights:

$progressData

Please provide:
1. Overall trend analysis (gaining/losing/maintaining)
2. Rate of change per week
3. Whether the pace is healthy and sustainable
4. Specific suggestions to improve
5. Motivational feedback

Keep the response encouraging and actionable.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to analyze progress. Please try again.';
    } catch (e) {
      return 'Error analyzing progress: ${e.toString()}';
    }
  }

  // ─── Reset Chat ───
  static void resetChat() {
    _chatSession = null;
  }
}
