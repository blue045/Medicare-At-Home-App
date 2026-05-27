import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class AmbulanceScreen extends StatefulWidget {
  const AmbulanceScreen({super.key});
  static const route = '/ambulance';

  @override
  State<AmbulanceScreen> createState() => _AmbulanceScreenState();
}

class _AmbulanceScreenState extends State<AmbulanceScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final phone = TextEditingController();
  final pickup = TextEditingController();
  final destination = TextEditingController();
  final condition = TextEditingController();
  bool sending = false;
  Future<AppSettings>? settingsFuture;

  @override
  void initState() {
    super.initState();
    settingsFuture = loadSettings();
  }

  Future<AppSettings> loadSettings() async {
    final data = await context.read<ApiClient>().getJson('/api/settings');
    return AppSettings.fromJson(mapValue(data['settings']));
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => sending = true);
    try {
      await context.read<ApiClient>().postJson('/api/ambulance', {
        'fullName': name.text.trim(),
        'phone': phone.text.trim(),
        'pickup': pickup.text.trim(),
        'destination': destination.text.trim(),
        'patientCondition': condition.text.trim(),
      });
      if (!mounted) return;
      showSnack(context, 'Ambulance request sent.');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) showSnack(context, e.toString());
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ambulance')),
      body: FutureBuilder<AppSettings>(
        future: settingsFuture,
        builder: (context, snapshot) {
          final settings = snapshot.data;
          return Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              children: [
                AppSectionHeader(
                  kicker: 'Ambulance',
                  title: settings?.ambulancePageTitle ?? 'Need an ambulance?',
                  subtitle: settings?.ambulancePageCopy ?? 'Send pickup and patient details.',
                ),
                const SizedBox(height: 18),
                if (settings != null)
                  PrimaryGradientBox(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(settings.ambulanceDescription, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white, height: 1.65)),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => launchWhatsapp(settings.ambulanceWhatsapp, 'I need ambulance support.'),
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: const Text('WhatsApp Ambulance Support', maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white70)),
                          onPressed: () => launchPhone(settings.ambulancePhone),
                          icon: const Icon(Icons.call_outlined),
                          label: const Text('Call Ambulance Number', maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ]),
                  ),
                const SizedBox(height: 18),
                TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Full Name'), validator: _required),
                const SizedBox(height: 12),
                TextFormField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number'), validator: _required),
                const SizedBox(height: 12),
                TextFormField(controller: pickup, maxLines: 2, decoration: const InputDecoration(labelText: 'Pickup Location'), validator: _required),
                const SizedBox(height: 12),
                TextFormField(controller: destination, maxLines: 2, decoration: const InputDecoration(labelText: 'Destination')),
                const SizedBox(height: 12),
                TextFormField(controller: condition, maxLines: 3, decoration: const InputDecoration(labelText: 'Patient Condition')),
                const SizedBox(height: 18),
                ElevatedButton.icon(onPressed: sending ? null : submit, icon: sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.emergency), label: const Text('Send Request')),
              ],
            ),
          );
        },
      ),
    );
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Required' : null;
}
