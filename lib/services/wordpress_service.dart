import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wp_post.dart';

class WordPressService {
  final String baseUrl;

  WordPressService(this.baseUrl);

  Future<List<WpPost>> getLatestPosts() async {
    final url = Uri.parse('$baseUrl/wp-json/wp/v2/posts?per_page=3');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => WpPost.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener posts: ${response.statusCode}');
    }
  }

  // Segunda llamada: obtener URL de la imagen destacada
  Future<String> getMediaUrl(int mediaId) async {
    if (mediaId == 0) return '';

    try {
      final url = Uri.parse('$baseUrl/wp-json/wp/v2/media/$mediaId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['source_url'] ?? '';
      }
    } catch (_) {}
    return '';
  }

  // Obtiene el logo del sitio
  Future<String> getSiteIcon() async {
    try {
      final url = Uri.parse('$baseUrl/wp-json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['site_icon_url'] ?? '';
      }
    } catch (_) {}
    return '';
  }
}