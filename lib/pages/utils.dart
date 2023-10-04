import 'dart:convert';

import 'package:http/http.dart';

Future<Map<String, dynamic>> post(
  String url,
  Map<String, String> headers,
  Map<String, dynamic> body,
) async {
  try {
    final client = Client();
    final response = await client.post(
      Uri.parse(url),
      headers: headers,
      body: body,
      encoding: Encoding.getByName('utf-8'),
    );
    return jsonDecode(response.body);
  } on Exception {
    rethrow;
  }
}
