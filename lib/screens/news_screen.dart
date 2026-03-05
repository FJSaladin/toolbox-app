import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/wp_post.dart';
import '../services/wordpress_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  // ← Cambia esta URL por el sitio WordPress que elegiste
  final WordPressService _service =
      WordPressService('https://thenextweb.com');

  List<WpPost> _posts = [];
  Map<int, String> _mediaUrls = {};
  String _siteIconUrl = '';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Cargamos posts e ícono del sitio en paralelo
      final results = await Future.wait([
        _service.getLatestPosts(),
        _service.getSiteIcon(),
      ]);

      final posts = results[0] as List<WpPost>;
      final icon = results[1] as String;

      // Cargamos imágenes de cada post también en paralelo
      final mediaFutures = posts
          .where((p) => p.featuredMediaId != 0)
          .map((p) async {
            final url = await _service.getMediaUrl(p.featuredMediaId);
            return MapEntry(p.featuredMediaId, url);
          });

      final mediaEntries = await Future.wait(mediaFutures);

      setState(() {
        _posts = posts;
        _siteIconUrl = icon;
        _mediaUrls = Map.fromEntries(mediaEntries);
      });
    } catch (e) {
      setState(() => _errorMessage = 'No se pudieron cargar las noticias.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Últimas Noticias'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadContent,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 15)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadContent,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Logo del sitio
          if (_siteIconUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      _siteIconUrl,
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.language,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Últimas 3 publicaciones',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),

          // Lista de posts
          ..._posts.map((post) => _NewsCard(
                post: post,
                imageUrl: _mediaUrls[post.featuredMediaId] ?? '',
                onVisit: () => _openLink(post.link),
              )),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final WpPost post;
  final String imageUrl;
  final VoidCallback onVisit;

  const _NewsCard({
    required this.post,
    required this.imageUrl,
    required this.onVisit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen destacada
          if (imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported,
                    size: 48, color: Colors.grey),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titular
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),

                // Resumen
                Text(
                  post.excerpt,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),

                // Botón visitar
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onVisit,
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Visitar noticia'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}