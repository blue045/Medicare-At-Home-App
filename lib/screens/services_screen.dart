import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});
  static const route = '/services';

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
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
      appBar: AppBar(title: const Text('Services')),
      body: FutureBuilder<AppSettings>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const LoadingState();
          if (snapshot.hasError) {
            return ErrorState(message: snapshot.error.toString(), onRetry: () => setState(() => future = loadSettings()));
          }
          final settings = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => setState(() => future = loadSettings()),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              children: [
                AppSectionHeader(
                  kicker: 'Services',
                  title: 'Home medical services',
                  subtitle: 'Professional home visit medical services. Contact by WhatsApp or phone for appointment confirmation.',
                ),
                const SizedBox(height: 18),
                ...settings.serviceTags.map((service) {
                  final icon = settings.serviceIcons[service]?.toString() ?? '✚';
                  final desc = settings.serviceDescriptions[service]?.toString() ?? 'Home visit support from Medicare At Home.';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(color: const Color(0xFFEAF1FF), borderRadius: BorderRadius.circular(20)),
                                alignment: Alignment.center,
                                child: Text(icon, style: const TextStyle(fontSize: 25)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(service, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, height: 1.2)),
                                    const SizedBox(height: 8),
                                    Text(desc, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF647084), height: 1.6)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => launchWhatsapp(settings.whatsapp, 'Hello Medicare At Home, I want to book $service.'),
                              icon: const Icon(Icons.chat_bubble_outline),
                              label: const Text('Book on WhatsApp'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
