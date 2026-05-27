import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import 'ambulance_screen.dart';
import 'profile_screen.dart';
import 'services_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<AppSettings> future;

  @override
  void initState() {
    super.initState();
    future = loadSettings();
  }

  Future<AppSettings> loadSettings() async {
    final api = context.read<ApiClient>();
    final data = await api.getJson('/api/settings', query: {'fresh': DateTime.now().millisecondsSinceEpoch.toString()});
    return AppSettings.fromJson(mapValue(data['settings']));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppSettings>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const LoadingState();
        if (snapshot.hasError) {
          return ErrorState(
            message: snapshot.error.toString(),
            onRetry: () => setState(() => future = loadSettings()),
          );
        }
        final settings = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async => setState(() => future = loadSettings()),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFDCE6F7))),
                    child: const Icon(Icons.local_hospital, color: Color(0xFF2367FF)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(settings.siteName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                      Text(settings.tagline, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF667085))),
                    ]),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => Navigator.pushNamed(context, ProfileScreen.route),
                    icon: const Icon(Icons.person_outline),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              PrimaryGradientBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('HOME MEDICAL SERVICE', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    const SizedBox(height: 18),
                    Text('${settings.heroHighlight}\n${settings.heroTitleLine}', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w900, height: 1.08)),
                    const SizedBox(height: 16),
                    Text(settings.description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: .92), height: 1.65)),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => launchWhatsapp(settings.whatsapp),
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('WhatsApp Appointment', maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white70),
                        ),
                        onPressed: () => Navigator.pushNamed(context, AmbulanceScreen.route),
                        icon: const Icon(Icons.emergency_outlined),
                        label: const Text('Order Ambulance', maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              if (settings.stats.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: settings.stats.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.35),
                  itemBuilder: (context, i) {
                    final stat = settings.stats[i];
                    return SoftCard(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(stat.value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                        Text(stat.label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF667085), fontWeight: FontWeight.w700)),
                      ]),
                    );
                  },
                ),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Expanded(child: AppSectionHeader(kicker: 'Services', title: 'Home care support', subtitle: 'Tap WhatsApp to confirm availability before booking.')),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, ServicesScreen.route),
                    child: const Text('View all'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ...settings.serviceTags.map((service) {
                final icon = settings.serviceIcons[service]?.toString() ?? '✚';
                final desc = settings.serviceDescriptions[service]?.toString() ?? 'Home visit support from Medicare At Home.';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SoftCard(
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(color: const Color(0xFFEAF1FF), borderRadius: BorderRadius.circular(18)),
                          alignment: Alignment.center,
                          child: Text(icon, style: const TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(service, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                            const SizedBox(height: 6),
                            Text(desc, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF667085))),
                          ]),
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
    );
  }
}
