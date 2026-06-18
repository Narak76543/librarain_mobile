import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiResponse {
  final String type; // 'faq' or 'book_search'
  final String message;
  final Map<String, dynamic>? filters;

  AiResponse({required this.type, required this.message, this.filters});
}

class AiSearchService {
  Future<AiResponse> handleQuery(String query) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY is not defined in .env');
    }

    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );

    final prompt = '''
You are a friendly, helpful customer service assistant for "Librarain", a modern bookstore app.
Your job is to read the user's query and do ONE of two things:

1. FAQ / General Question: If the user asks about store policies, shipping, refunds, hours, or general chat, answer them warmly in natural language.
2. Book Search: If the user is looking to buy or find specific books, extract their search criteria AND write a friendly message saying you found some books for them.

You MUST output your response as a JSON object matching this schema exactly:
{
  "type": "faq" OR "book_search",
  "message": "Your conversational, friendly reply to the user",
  "filters": {
    "category": string (e.g., "science", "fiction", "history"),
    "max_price": double (e.g., 15),
    "sort": string (e.g., "price_asc", "price_desc", "newest", "rating"),
    "search": string (any specific keywords or title they are looking for)
  }
}
*Note: The "filters" object is optional and should ONLY be included if type is "book_search".

Store Policies for your knowledge:
- Shipping: 3-5 business days standard. Free shipping over \$50.
- Returns: Accepted within 30 days of purchase in original condition.
- Location: We are completely online!
- Payments: We only accept KHQR (QR Code Payment) and COD (Cash on Delivery). We DO NOT accept credit cards, PayPal, or Apple Pay.

User query: "$query"
''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '{}';
      
      final Map<String, dynamic> json;
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(text);
      if (jsonMatch != null) {
        json = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
      } else {
        json = jsonDecode(text) as Map<String, dynamic>;
      }

      return AiResponse(
        type: json['type'] as String? ?? 'faq',
        message: json['message'] as String? ?? 'I am not sure how to answer that.',
        filters: json['filters'] as Map<String, dynamic>?,
      );
    } catch (e) {
      throw Exception('Failed to handle query: $e');
    }
  }
}
