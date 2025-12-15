import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final http.Client client;
  
  ApiService({http.Client? client}) : client = client ?? http.Client();
  
  Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body,
  ) async {
    print('');
    print('═══════════════════════════════════════════════════════');
    print('📡 API POST REQUEST');
    print('═══════════════════════════════════════════════════════');
    print('🔗 URL: $url');
    print('📦 Body: ${jsonEncode(body)}');
    print('═══════════════════════════════════════════════════════');
    
    try {
      final response = await client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      
      print('');
      print('═══════════════════════════════════════════════════════');
      print('📡 API RESPONSE');
      print('═══════════════════════════════════════════════════════');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('═══════════════════════════════════════════════════════');
      print('');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        print('✅ JSON Parsed Successfully');
        print('📄 Parsed Data: $jsonResponse');
        return jsonResponse;
      } else {
        final errorMsg = 'API Error: ${response.statusCode} - ${response.body}';
        print('❌ $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('');
      print('═══════════════════════════════════════════════════════');
      print('❌ NETWORK ERROR');
      print('═══════════════════════════════════════════════════════');
      print('Error: $e');
      print('═══════════════════════════════════════════════════════');
      print('');
      throw Exception('Network error: $e');
    }
  }
  
  Future<Map<String, dynamic>> get(String url) async {
    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'API Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

