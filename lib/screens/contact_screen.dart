import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});
  static const route = '/contact';

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  late Future<AppSettings> future;

  @override
  void initState() {
    super.initState();
    future = loadSettings();
  }

  Future<AppSettings> loadSettings() async {
    final data = await context.read<ApiClient>().getJson('/api/settings', query: {'fresh': DateTime.now().millisecondsSinceEpoch.toString()});
    return AppSettings.fromJson(mapValue(data['settings']));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact')),
      body: FutureBuilder<AppSettings>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const LoadingState();
          if (snapshot.hasError) {
            return ErrorState(message: snapshot.error.toString(), onRetry: () => setState(() => future = loadSettings()));
          }
          final settings = snapshot.data!;
          final firstPhone = settings.phones.isNotEmpty ? settings.phones.first : '';
          return RefreshIndicator(
            onRefresh: () async => setState(() => future = loadSettings()),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              children: [
                AppSectionHeader(
                  kicker: 'Contact',
                  title: settings.contactPageTitle,
                  subtitle: settings.contactPageCopy,
                ),
                const SizedBox(height: 18),
                PrimaryGradientBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fast appointment support', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w900, height: 1.15)),
                      const SizedBox(height: 10),
                      Text('Use WhatsApp or phone to confirm service availability and patient details.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: .92), height: 1.6)),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => launchWhatsapp(settings.whatsapp),
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: const Text('WhatsApp Appointment'),
                        ),
                      ),
                      if (firstPhone.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white70)),
                            onPressed: () => launchPhone(firstPhone),
                            icon: const Icon(Icons.call_outlined),
                            label: const Text('Call Now'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (settings.location.isNotEmpty) _contactLine(Icons.location_on_outlined, settings.location),
                      if (settings.email.isNotEmpty) _contactLine(Icons.email_outlined, settings.email),
                      ...settings.phones.map((phone) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.call_outlined),
                            title: Text(phone),
                            trailing: const Icon(Icons.open_in_new),
                            onTap: () => launchPhone(phone),
                          )),
                      if (settings.whatsapp.isNotEmpty)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.chat_bubble_outline),
                          title: const Text('WhatsApp'),
                          subtitle: Text(settings.whatsapp),
                          trailing: const Icon(Icons.open_in_new),
                          onTap: () => launchWhatsapp(settings.whatsapp),
                        ),
                      if (settings.facebookUrl.isNotEmpty)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.facebook),
                          title: const Text('Facebook'),
                          trailing: const Icon(Icons.open_in_new),
                          onTap: () => launchExternal(Uri.parse(settings.facebookUrl)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _contactLine(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      );
}
