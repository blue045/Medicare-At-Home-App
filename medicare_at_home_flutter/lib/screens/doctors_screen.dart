import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  late Future<List<Doctor>> future;
  String query = '';
  String service = '';

  @override
  void initState() {
    super.initState();
    future = loadDoctors();
  }

  Future<List<Doctor>> loadDoctors() async {
    final data = await context.read<ApiClient>().getJson('/api/doctors');
    return (data['doctors'] is List ? data['doctors'] as List : const []).map(Doctor.fromJson).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Doctor>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const LoadingState();
        if (snapshot.hasError) return ErrorState(message: snapshot.error.toString(), onRetry: () => setState(() => future = loadDoctors()));
        final doctors = snapshot.data ?? [];
        final services = doctors.expand((d) => d.services).toSet().toList()..sort();
        final filtered = doctors.where((d) {
          final text = '${d.name} ${d.designation} ${d.specialty} ${d.serviceArea} ${d.services.join(' ')}'.toLowerCase();
          return text.contains(query.toLowerCase()) && (service.isEmpty || d.services.contains(service));
        }).toList();
        return RefreshIndicator(
          onRefresh: () async => setState(() => future = loadDoctors()),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              const AppSectionHeader(kicker: 'Doctors', title: 'Choose the right professional', subtitle: 'Open a profile to view chamber, time, and contact options.'),
              const SizedBox(height: 18),
              TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search doctor, specialty or area'), onChanged: (v) => setState(() => query = v)),
              if (services.isNotEmpty) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: service.isEmpty ? null : service,
                  decoration: const InputDecoration(labelText: 'Filter by service'),
                  items: [const DropdownMenuItem(value: '', child: Text('All services')), ...services.map((s) => DropdownMenuItem(value: s, child: Text(s)))],
                  onChanged: (v) => setState(() => service = v ?? ''),
                ),
              ],
              const SizedBox(height: 18),
              if (filtered.isEmpty) const EmptyState(message: 'No doctors found.'),
              ...filtered.map((doctor) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: SoftCard(
                      onTap: () => showDoctorSheet(context, doctor),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        AppImage(url: doctor.photoUrl, width: 82, height: 82, placeholderIcon: Icons.person),
                        const SizedBox(width: 16),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(doctor.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                          if (doctor.designation.isNotEmpty) Text(doctor.designation, style: const TextStyle(color: Color(0xFF2367FF), fontWeight: FontWeight.w800)),
                          if (doctor.specialty.isNotEmpty) Text(doctor.specialty),
                          if (doctor.serviceArea.isNotEmpty) Text(doctor.serviceArea, style: const TextStyle(color: Color(0xFF667085))),
                        ])),
                        const Icon(Icons.chevron_right),
                      ]),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  void showDoctorSheet(BuildContext context, Doctor doctor) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .82,
        maxChildSize: .95,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          children: [
            Row(children: [
              AppImage(url: doctor.photoUrl, width: 86, height: 86, placeholderIcon: Icons.person),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(doctor.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                Text(doctor.designation),
                Text(doctor.specialty, style: const TextStyle(color: Color(0xFF2367FF), fontWeight: FontWeight.w800)),
              ])),
            ]),
            const SizedBox(height: 18),
            if (doctor.bio.isNotEmpty) Text(doctor.bio),
            const SizedBox(height: 18),
            if (doctor.degrees.isNotEmpty) _info('Degrees', doctor.degrees),
            if (doctor.experience.isNotEmpty) _info('Experience', doctor.experience),
            if (doctor.hospital.isNotEmpty) _info('Hospital', doctor.hospital),
            if (doctor.fee.isNotEmpty) _info('Fee', doctor.fee),
            if (doctor.services.isNotEmpty) _info('Services', doctor.services.join(', ')),
            if (doctor.languages.isNotEmpty) _info('Languages', doctor.languages.join(', ')),
            if (doctor.chambers.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Chambers', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              ...doctor.chambers.map((c) => SoftCard(
                    padding: const EdgeInsets.all(14),
                    child: Text('${str(c['location'])}\n${str(c['weekday'])} • ${str(c['time'])}', style: const TextStyle(height: 1.6)),
                  )),
            ],
            const SizedBox(height: 18),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () => launchPhone(doctor.phone), icon: const Icon(Icons.call), label: const Text('Call'))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(onPressed: () => launchWhatsapp(doctor.whatsapp, 'Hello, I want to book an appointment.'), icon: const Icon(Icons.chat), label: const Text('WhatsApp'))),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SoftCard(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(value)])),
      );
}
