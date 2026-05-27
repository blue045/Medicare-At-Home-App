import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/app_state.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import 'about_screen.dart';
import 'ambulance_screen.dart';
import 'auth_screen.dart';
import 'contact_screen.dart';
import 'profile_screen.dart';
import 'services_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
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
    final state = context.watch<AppState>();
    return FutureBuilder<AppSettings>(
      future: future,
      builder: (context, snapshot) {
        final settings = snapshot.data;
        return RefreshIndicator(
          onRefresh: () async => setState(() => future = loadSettings()),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              const AppSectionHeader(kicker: 'Menu', title: 'Public pages', subtitle: 'Services, ambulance, contact, about, and your account.'),
              const SizedBox(height: 18),
              _menuTile(
                context,
                icon: Icons.person_outline,
                title: state.isLoggedIn ? 'Profile and Orders' : 'Log in / Sign up',
                subtitle: state.isLoggedIn ? state.user?.fullName ?? 'Manage account' : 'Access cart and order history',
                onTap: () => Navigator.pushNamed(context, state.isLoggedIn ? ProfileScreen.route : AuthScreen.route),
              ),
              _menuTile(
                context,
                icon: Icons.medical_services_outlined,
                title: 'Services',
                subtitle: 'Home visit medical care',
                onTap: () => Navigator.pushNamed(context, ServicesScreen.route),
              ),
              _menuTile(
                context,
                icon: Icons.emergency_outlined,
                title: 'Ambulance',
                subtitle: 'Send pickup request or call support',
                onTap: () => Navigator.pushNamed(context, AmbulanceScreen.route),
              ),
              _menuTile(
                context,
                icon: Icons.call_outlined,
                title: 'Contact',
                subtitle: 'Phone, WhatsApp, address, and social links',
                onTap: () => Navigator.pushNamed(context, ContactScreen.route),
              ),
              _menuTile(
                context,
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'Team profiles and published updates',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
              ),
              const SizedBox(height: 24),
              if (settings != null) ...[
                Text('Quick contact', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                SoftCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (settings.location.isNotEmpty) _contactLine(Icons.location_on_outlined, settings.location),
                    if (settings.email.isNotEmpty) _contactLine(Icons.email_outlined, settings.email),
                    ...settings.phones.map((phone) => ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.call_outlined), title: Text(phone), trailing: const Icon(Icons.open_in_new), onTap: () => launchPhone(phone))),
                    if (settings.whatsapp.isNotEmpty) ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.chat_bubble_outline), title: const Text('WhatsApp'), subtitle: Text(settings.whatsapp), trailing: const Icon(Icons.open_in_new), onTap: () => launchWhatsapp(settings.whatsapp)),
                    if (settings.facebookUrl.isNotEmpty) ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.facebook), title: const Text('Facebook'), trailing: const Icon(Icons.open_in_new), onTap: () => launchExternal(Uri.parse(settings.facebookUrl))),
                  ]),
                ),
              ] else if (snapshot.hasError)
                ErrorState(message: snapshot.error.toString(), onRetry: () => setState(() => future = loadSettings())),
            ],
          ),
        );
      },
    );
  }

  Widget _menuTile(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SoftCard(
        onTap: onTap,
        child: Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFEAF1FF), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: const Color(0xFF2367FF))),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Color(0xFF667085), height: 1.35))])),
          const Icon(Icons.chevron_right),
        ]),
      ),
    );
  }

  Widget _contactLine(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 22), const SizedBox(width: 12), Expanded(child: Text(text))]),
      );
}
