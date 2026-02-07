import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  /// POST request with multipart/form-data
  Future<Map<String, dynamic>> postMultipart(
    String url,
    Map<String, String> fields,
    List<http.MultipartFile> files, {
    String? token,
    Map<String, List<String>>? arrayFields,
  }) async {
    // print('');
    // print('═══════════════════════════════════════════════════════');
    // print('📡 API MULTIPART POST REQUEST');
    // print('═══════════════════════════════════════════════════════');
    // print('🔗 URL: $url');
    // print('📦 Fields: $fields');
    // print('📎 Files: ${files.length} file(s)');
    // if (token != null) {
    //   print('🔑 Token: ${token.substring(0, 20)}...');
    // }
    // print('═══════════════════════════════════════════════════════');

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add regular fields
      request.fields.addAll(fields);
      // Hardcode 'business' field as it is required by backend but missing in our model mapping ??
      // Based on error: "business is not defined"
      // If the backend expects a JSON string for business, we might need to construct it.
      // But looking at previous errors, it seems like sometimes these "not defined" errors appear for missing fields.
      // If we don't have a specific business object to send, let's try sending an empty object or relevant fields.
      // BUT WAIT, the user showed a response where "business" is an object in the JSON.
      // In multipart updates, usually fields are flattened?
      // Or maybe it expects a field named 'business' with JSON content?
      // Let's try adding a dummy business field if not present.
      if (!request.fields.containsKey('business')) {
        // Removed hardcoded hack - validating properly in model
      }

      // Add array fields (multiple entries with the same key)
      // The http package's MultipartRequest.fields is a Map<String, String>,
      // which doesn't support duplicate keys. We need to manually add array fields.
      //
      // Solution: Use MultipartFile.fromString() which creates a file-like object
      // that can be sent as a form field. The backend should accept these as form fields.
      if (arrayFields != null && arrayFields.isNotEmpty) {
        print('\n📋 Adding array fields:');
        for (final entry in arrayFields.entries) {
          final key = entry.key; // e.g., 'categories[]'
          print('   $key: ${entry.value.length} value(s)');
          for (final value in entry.value) {
            // IMPORTANT: Always send array values, even if empty, to maintain array alignment
            // The backend expects arrays like documentNumber[] to match the length of doc_name[]
            // Skipping empty values causes array misalignment and backend errors
            final arrayField = http.MultipartFile.fromString(
              key, // Keep the [] in the key name
              value, // Send empty string if needed to maintain array alignment
            );
            request.files.add(arrayField);
            print('     - Added: ${value.isEmpty ? "(empty)" : value}');
          }
        }
      }

      // Add files
      // Add files
      request.files.addAll(files);
      print('\n═══════════════════════════════════════════════════════');
      print('🛠️ MULTIPART REQUEST DEBUG LOG (For Postman)');
      print('═══════════════════════════════════════════════════════');
      print('URL: $url');
      print('Method: POST');
      print('Headers: ${request.headers}');
      print('--- BODY FIELDS ---');
      request.fields.forEach((key, value) => print('$key: $value'));

      print('\n--- FILES ---');
      for (final file in request.files) {
        if (file.filename != null) {
          print(
            'Key: ${file.field} | File: ${file.filename} | Size: ${file.length} bytes',
          );
        } else {
          // For array fields that are finalized strings, we can't easily read them back
          // without keeping a copy or checking the type carefully.
          // Since this is just a debug log, we'll mark it as an array value.
          print('Key: ${file.field} | (Array Value)');
        }
      }
      print('═══════════════════════════════════════════════════════\n');

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      // log("sssssssssss${response.body}");
      // print('');
      // print('═══════════════════════════════════════════════════════');
      // print('📡 API RESPONSE');
      // print('═══════════════════════════════════════════════════════');
      // print('📊 Status Code: ${response.statusCode}');
      // print('📦 Response Body: ${response.body}');
      // print('═══════════════════════════════════════════════════════');
      // print('');

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

  Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    print('');
    print('═══════════════════════════════════════════════════════');
    print('📡 API POST REQUEST');
    print('═══════════════════════════════════════════════════════');
    print('🔗 URL: $url');
    print('📦 Body: ${jsonEncode(body)}');
    if (token != null) {
      print('🔑 Token: ${token.substring(0, 20)}...');
    }
    print('═══════════════════════════════════════════════════════');

    try {
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client.post(
        Uri.parse(url),
        headers: headers,
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

  Future<Map<String, dynamic>> get(String url, {String? token}) async {
    try {
      final headers = <String, String>{'Content-Type': 'application/json'};

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      print('');
      print('═══════════════════════════════════════════════════════');
      print('📡 API GET REQUEST');
      print('═══════════════════════════════════════════════════════');
      print('🔗 URL: $url');
      if (token != null) {
        print('🔑 Token: ${token.substring(0, 20)}...');
      }
      print('═══════════════════════════════════════════════════════');

      final response = await client.get(Uri.parse(url), headers: headers);

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

  /// GET request for categories
  Future<List<Map<String, dynamic>>> getCategories(String url) async {
    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = jsonDecode(response.body);

        List<dynamic> data = [];

        // Case 1: { success, message, data: { categories: [...] } }
        if (decoded is Map<String, dynamic>) {
          final dynamic dataField = decoded['data'];

          if (dataField is Map<String, dynamic>) {
            if (dataField['categories'] is List) {
              data = dataField['categories'];
            } else {
              // fallback: any list inside data map
              data = dataField.values
                  .whereType<List>()
                  .expand((e) => e)
                  .toList();
            }
          }
          // Case 2: { success, message, data: [...] }
          else if (dataField is List) {
            data = dataField;
          }
        }
        // Case 3: direct list response [...]
        else if (decoded is List) {
          data = decoded;
        }
        // Case 4: unexpected structure
        else {
          throw Exception('Unexpected response format');
        }

        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
