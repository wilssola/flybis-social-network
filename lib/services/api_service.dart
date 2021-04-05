// 🎯 Dart imports:
import 'dart:convert';
import 'dart:math';

// 📦 Package imports:
import 'package:http/http.dart' as http;

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  Future<String> getErrorGiphy() async {
    const String authority = 'api.giphy.com';
    const String unencodedPath = '/v1/gifs/random';

    http.Response response =
        await http.get(Uri.https(authority, unencodedPath), headers: {
      'api_key': '0TH9WzvgjcHUKckMJLnGfrwvLz8DLfqa',
      'tag': '404',
      'rating': 'g',
    });

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    String gif = jsonDecode(response.body)['data']['images']
        ['fixed_height_small']['url'];

    print('Response gif: $gif');

    return gif;
  }

  Future<String> getErrorTenor() async {
    final int random = new Random().nextInt(100);

    const String authority = 'g.tenor.com';
    const String unencodedPath = '/v1/random';

    final Map<String, dynamic> queryParameters = {
      'q': '404', 
      'contentfilter': 'high', 
      'media_filter': 'minimal', 
      'ar_range': 'wide', 
      'limit' : 1, 
      'pos': random,
    };

    http.Response response =
        await http.get(Uri.https(authority, unencodedPath, queryParameters));

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    String gif =
        jsonDecode(response.body)['results'][0]['media'][0]['tinygif']['url'];

    print('Response gif: $gif');

    return gif;
  }
}
