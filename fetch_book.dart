import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  try {
    // try the api from the first prompt
    final res1 = await http.get(Uri.parse('http://192.168.0.198:8000/api/v1/books'));
    print('198 response status: ${res1.statusCode}');
    if (res1.statusCode == 200) {
      final json = jsonDecode(res1.body);
      final firstBookId = json['data']['books'][0]['id'];
      print('First book ID: $firstBookId');
      final detail = await http.get(Uri.parse('http://192.168.0.198:8000/api/v1/books/$firstBookId'));
      print('Detail keys: ${jsonDecode(detail.body)['data'].keys}');
      print('Detail data: ${detail.body}');
    }
  } catch (e) {
    print('198 error: $e');
  }

  try {
    final res2 = await http.get(Uri.parse('http://192.168.1.26:8000/api/v1/books'));
    print('26 response status: ${res2.statusCode}');
    if (res2.statusCode == 200) {
      final json = jsonDecode(res2.body);
      final firstBookId = json['data']['books'][0]['id'];
      print('First book ID: $firstBookId');
      final detail = await http.get(Uri.parse('http://192.168.1.26:8000/api/v1/books/$firstBookId'));
      print('Detail keys: ${jsonDecode(detail.body)['data'].keys}');
      print('Detail data: ${detail.body}');
    }
  } catch (e) {
    print('26 error: $e');
  }
}
