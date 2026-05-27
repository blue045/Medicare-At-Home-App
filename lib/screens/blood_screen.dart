import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class BloodScreen extends StatefulWidget {
  const BloodScreen({super.key});

  @override
  State<BloodScreen> createState() => _BloodScreenState();
}

class _BloodScreenState extends State<BloodScreen> {
  late Future<List<BloodProfile>> future;
  String query = '';
  final bloodOrder = const ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    future = loadProfiles();
  }

  Future<List<BloodProfile>> loadProfiles() async {
    final data = await context.read<ApiClient>().getJson('/api/blood', query: {'fresh': DateTime.now().millisecondsSinceEpoch.toString()});
    final profiles = (data['profiles'] is List ? data['profiles'] as List : const []).map(BloodProfile.fromJson).toList();
    profiles.sort((a, b) {
      final ai = bloodOrder.indexOf(a.bloodGroup);
      final bi = bloodOrder.indexOf(b.bloodGroup);
      return (ai < 0 ? 99 : ai).compareTo(bi < 0 ? 99 : bi);
    });
    return profiles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<BloodProfile>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const LoadingState();
          if (snapshot.hasError) return ErrorState(message: snapshot.error.toString(), onRetry: () => setState(() => future = loadProfiles()));
          final profiles = snapshot.data ?? [];
          final filtered = profiles.where((p) => '${p.fullName} ${p.bloodGroup}'.toLowerCase().contains(query.toLowerCase())).toList();
          return RefreshIndicator(
            onRefresh: () async => setState(() => future = loadProfiles()),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 90),
              children: [
                const AppSectionHeader(kicker: 'Blood', title: 'Available blood people', subtitle: 'Cards are sorted by blood group. Female contact details are protected by admin rules.'),
                const SizedBox(height: 18),
                TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search name or blood group'), onChanged: (v) => setState(() => query = v)),
                const SizedBox(height: 18),
                if (filtered.isEmpty) const EmptyState(message: 'No blood profiles found.'),
                ...filtered.map((profile) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SoftCard(
                        onTap: () => showProfile(context, profile),
                        child: Row(children: [
                          Container(
                            width: 58,
                            height: 58,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: const Color(0xFFFFE9EF), borderRadius: BorderRadius.circular(20)),
                            child: Text(profile.bloodGroup, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFE11D48), fontSize: 18)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(profile.fullName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                            Text(profile.contactAdminRequired ? 'Contact through admin' : profile.phone, style: const TextStyle(color: Color(0xFF667085))),
                          ])),
                          const Icon(Icons.chevron_right),
                        ]),
                      ),
                    )),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => showAddSheet(context), icon: const Icon(Icons.add), label: const Text('Add')),
    );
  }

  void showProfile(BuildContext context, BloodProfile profile) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(profile.fullName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Chip(label: Text(profile.bloodGroup)),
          const SizedBox(height: 12),
          if (profile.contactAdminRequired)
            const Text('This profile contact information is protected. Please contact admin.')
          else ...[
            Text('Phone: ${profile.phone}'),
            Text('WhatsApp: ${profile.whatsapp}'),
            Text('Address: ${profile.homeAddress}'),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () => launchPhone(profile.phone), icon: const Icon(Icons.call), label: const Text('Call'))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(onPressed: () => launchWhatsapp(profile.whatsapp, 'Hello, I saw your blood donor profile.'), icon: const Icon(Icons.chat), label: const Text('WhatsApp'))),
            ]),
          ],
        ]),
      ),
    );
  }

  void showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BloodAddForm(onSaved: () => setState(() => future = loadProfiles())),
    );
  }
}

class BloodAddForm extends StatefulWidget {
  const BloodAddForm({super.key, required this.onSaved});
  final VoidCallback onSaved;

  @override
  State<BloodAddForm> createState() => _BloodAddFormState();
}

class _BloodAddFormState extends State<BloodAddForm> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final phone = TextEditingController();
  final whatsapp = TextEditingController();
  final address = TextEditingController();
  String bloodGroup = 'A+';
  String gender = 'male';
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text('Add blood information', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Full Name'), validator: _required),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(value: bloodGroup, decoration: const InputDecoration(labelText: 'Blood Group'), items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => bloodGroup = v ?? 'A+')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(value: gender, decoration: const InputDecoration(labelText: 'Gender'), items: const [DropdownMenuItem(value: 'male', child: Text('Male')), DropdownMenuItem(value: 'female', child: Text('Female')), DropdownMenuItem(value: 'other', child: Text('Other'))], onChanged: (v) => setState(() => gender = v ?? 'male')),
            const SizedBox(height: 12),
            TextFormField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone'), validator: _required),
            const SizedBox(height: 12),
            TextFormField(controller: whatsapp, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'WhatsApp'), validator: _required),
            const SizedBox(height: 12),
            TextFormField(controller: address, maxLines: 3, decoration: const InputDecoration(labelText: 'Home Address'), validator: _required),
            const SizedBox(height: 18),
            ElevatedButton.icon(onPressed: saving ? null : save, icon: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save), label: const Text('Submit for approval')),
          ],
        ),
      ),
    );
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => saving = true);
    try {
      await context.read<ApiClient>().postJson('/api/blood', {'fullName': name.text.trim(), 'bloodGroup': bloodGroup, 'gender': gender, 'phone': phone.text.trim(), 'whatsapp': whatsapp.text.trim(), 'homeAddress': address.text.trim()});
      if (!mounted) return;
      showSnack(context, 'Submitted. Admin approval required.');
      widget.onSaved();
      Navigator.pop(context);
    } catch (e) {
      if (mounted) showSnack(context, e.toString());
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Required' : null;
}
