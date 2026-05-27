import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_config.dart';

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({super.key, required this.kicker, required this.title, this.subtitle});

  final String kicker;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0FF),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFC5D6FF)),
          ),
          child: Text(
            kicker.toUpperCase(),
            style: textTheme.labelLarge?.copyWith(color: const Color(0xFF255CD8), fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, height: 1.15, color: const Color(0xFF071022)),
        ),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(subtitle!, style: textTheme.bodyLarge?.copyWith(color: const Color(0xFF647084), height: 1.65)),
        ],
      ],
    );
  }
}

class SoftCard extends StatelessWidget {
  const SoftCard({super.key, required this.child, this.padding = const EdgeInsets.all(20), this.onTap});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: const BorderSide(color: Color(0xFFE0E8F8)),
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return card;
    return InkWell(borderRadius: BorderRadius.circular(26), onTap: onTap, child: card);
  }
}

class PrimaryGradientBox extends StatelessWidget {
  const PrimaryGradientBox({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF3267FF), Color(0xFF1EBCFF)]),
        borderRadius: BorderRadius.circular(30),
      ),
      child: DefaultTextStyle.merge(style: const TextStyle(color: Colors.white), child: child),
    );
  }
}

class AppImage extends StatelessWidget {
  const AppImage({super.key, required this.url, this.width, this.height, this.fit = BoxFit.cover, this.borderRadius = 22, this.placeholderIcon = Icons.medication_liquid});

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    Widget child;
    final clean = url.trim();
    if (clean.startsWith('data:image/')) {
      try {
        final data = clean.substring(clean.indexOf(',') + 1);
        final bytes = base64Decode(data);
        child = Image.memory(Uint8List.fromList(bytes), width: width, height: height, fit: fit);
      } catch (_) {
        child = _placeholder(context);
      }
    } else if (clean.isNotEmpty) {
      child = Image.network(
        AppConfig.absoluteUrl(clean),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(context),
        loadingBuilder: (context, widget, progress) => progress == null ? widget : _placeholder(context),
      );
    } else {
      child = _placeholder(context);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(width: width, height: height, child: child),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFEAF1FF),
      child: Icon(placeholderIcon, size: 34, color: Theme.of(context).colorScheme.primary),
    );
  }
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Future<void> launchPhone(String phone) async {
  final normalized = phone.replaceAll(RegExp(r'[^0-9+]'), '');
  if (normalized.isEmpty) return;
  await launchUrl(Uri.parse('tel:$normalized'), mode: LaunchMode.externalApplication);
}

Future<void> launchWhatsapp(String number, [String message = 'Hello Medicare At Home']) async {
  final clean = number.replaceAll(RegExp(r'[^0-9]'), '');
  if (clean.isEmpty) return;
  final uri = Uri.parse('https://wa.me/$clean?text=${Uri.encodeComponent(message)}');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<void> launchExternal(Uri uri) async {
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Text(message, textAlign: TextAlign.center)));
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
