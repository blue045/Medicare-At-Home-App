import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late Future<Map<String, dynamic>> future;

  @override
  void initState() {
    super.initState();
    future = loadAbout();
  }

  Future<Map<String, dynamic>> loadAbout() async {
    final data = await context.read<ApiClient>().getJson('/api/about', query: {'fresh': DateTime.now().millisecondsSinceEpoch.toString()});
    return {
      'profiles': (data['profiles'] is List ? data['profiles'] as List : const []).map(AboutProfile.fromJson).toList(),
      'posts': (data['posts'] is List ? data['posts'] as List : const []).map(AboutPost.fromJson).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const LoadingState();
          if (snapshot.hasError) return ErrorState(message: snapshot.error.toString(), onRetry: () => setState(() => future = loadAbout()));
          final profiles = snapshot.data?['profiles'] as List<AboutProfile>? ?? [];
          final posts = snapshot.data?['posts'] as List<AboutPost>? ?? [];
          return RefreshIndicator(
            onRefresh: () async => setState(() => future = loadAbout()),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              children: [
                const AppSectionHeader(kicker: 'About', title: 'About Medicare At Home', subtitle: 'Team profiles and published updates from the admin panel.'),
                const SizedBox(height: 22),
                Text('Team profiles', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                if (profiles.isEmpty) const SoftCard(child: Text('Team profiles will appear here after admin publishes them.')),
                ...profiles.map((profile) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SoftCard(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        AppImage(url: profile.photoUrl, width: 76, height: 76, placeholderIcon: Icons.person),
                        const SizedBox(width: 16),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(profile.role.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF2367FF), fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                          const SizedBox(height: 8),
                          Text(profile.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                          if (profile.description.isNotEmpty) Text(profile.description),
                        ])),
                      ])),
                    )),
                const SizedBox(height: 22),
                Text('Updates', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                if (posts.isEmpty) const SoftCard(child: Text('Published posts will appear here.')),
                ...posts.map((post) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SoftCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (post.coverImage.isNotEmpty) ...[
                          AppImage(url: post.coverImage, width: double.infinity, height: 180),
                          const SizedBox(height: 14),
                        ],
                        Text(post.author.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF2367FF), fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                        const SizedBox(height: 8),
                        Text(post.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                        if (post.excerpt.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(post.excerpt)),
                        if (post.content.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(post.content)),
                      ])),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}
