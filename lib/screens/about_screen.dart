import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
        title: const Text('Acerca de'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ── Foto de perfil ──────────────────────────────
            CircleAvatar(
              radius: 70,
              backgroundColor: Colors.grey.shade200,
              // Cambia esta URL por tu foto
              backgroundImage: const NetworkImage(
                'https://media.licdn.com/dms/image/v2/D4E03AQFru_LRy5qJ6g/profile-displayphoto-shrink_800_800/profile-displayphoto-shrink_800_800/0/1698866308447?e=1774483200&v=beta&t=tFbAMSFkOMnF5YwIDCOdx341H1k62a3-4QcIZz0yQck',
              ),
            ),
            const SizedBox(height: 20),

            // ── Nombre ──────────────────────────────────────
            const Text(
              'Fausto Jose Arredondo Saladin',          // ← Cambia esto
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),

            // ── Título profesional ───────────────────────────
            Text(
              'Desarrollador de Software',    // ← Cambia esto
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),

            // ── Descripción breve ────────────────────────────
            Text(
              'Estudiante de desarrollo de software apasionado '
              'por crear soluciones.',  // ← Cambia esto
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            const Divider(),
            const SizedBox(height: 24),

            // ── Contacto ─────────────────────────────────────
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Contacto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            _ContactTile(
              icon: Icons.email,
              label: 'Email',
              value: 'Faustojoseas@gmail.com',       // ← Cambia esto
              color: Colors.red,
              onTap: () => _openLink('mailto:faustojoseas@gmail.com'),
            ),
            _ContactTile(
              icon: Icons.code,
              label: 'GitHub',
              value: 'github.com/FJSaladin',     // ← Cambia esto
              color: Colors.black,
              onTap: () => _openLink('https://github.com/FJSaladin'),
            ),
            _ContactTile(
              icon: Icons.work,
              label: 'LinkedIn',
              value: 'linkedin.com/in/fausto-josé-arredondo-saladin-350947232/', // ← Cambia esto
              color: Colors.blue,
              onTap: () => _openLink('https://linkedin.com/in/fausto-josé-arredondo-saladin-350947232/'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}