class WpPost {
  final int id;
  final String title;
  final String excerpt;
  final String link;
  final int featuredMediaId;

  WpPost({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.link,
    required this.featuredMediaId,
  });

  factory WpPost.fromJson(Map<String, dynamic> json) {
    return WpPost(
      id: json['id'],
      // WordPress devuelve HTML en estos campos, lo limpiamos
      title: _stripHtml(json['title']['rendered'] ?? ''),
      excerpt: _stripHtml(json['excerpt']['rendered'] ?? ''),
      link: json['link'] ?? '',
      featuredMediaId: json['featured_media'] ?? 0,
    );
  }

  // Elimina etiquetas HTML del texto
  static String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#8217;', "'")
        .replaceAll('&#8216;', "'")
        .trim();
  }
}