import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../widgets/common.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  static const route = '/auth';

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final formKey = GlobalKey<FormState>();
  final identifier = TextEditingController();
  final password = TextEditingController();
  final fullName = TextEditingController();
  final age = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  bool signup = false;
  bool loading = false;

  @override
  void dispose() {
    identifier.dispose();
    password.dispose();
    fullName.dispose();
    age.dispose();
    email.dispose();
    phone.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      final state = context.read<AppState>();
      if (signup) {
        await state.signup(
          fullName: fullName.text.trim(),
          age: age.text.trim(),
          email: email.text.trim(),
          phone: phone.text.trim(),
          password: password.text,
        );
      } else {
        await state.login(identifier: identifier.text.trim(), password: password.text);
      }
      if (!mounted) return;
      showSnack(context, signup ? 'Account created.' : 'Logged in.');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) showSnack(context, e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(signup ? 'Sign up' : 'Log in')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppSectionHeader(
              kicker: signup ? 'New account' : 'Welcome back',
              title: signup ? 'Create your store account' : 'Log in to continue',
              subtitle: signup ? 'Create an account to order medicine and manage your cart.' : 'Use your email or phone and password.',
            ),
            const SizedBox(height: 22),
            if (signup) ...[
              TextFormField(controller: fullName, decoration: const InputDecoration(labelText: 'Full Name'), validator: _required),
              const SizedBox(height: 12),
              TextFormField(controller: age, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Age'), validator: _required),
              const SizedBox(height: 12),
              TextFormField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 12),
              TextFormField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number')),
            ] else
              TextFormField(controller: identifier, decoration: const InputDecoration(labelText: 'Email or phone'), validator: _required),
            const SizedBox(height: 12),
            TextFormField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password'), validator: (v) => v == null || v.length < 6 ? 'Minimum 6 characters' : null),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: loading ? null : submit,
              icon: loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.login),
              label: Text(signup ? 'Create Account' : 'Log In'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: loading ? null : () => setState(() => signup = !signup),
              child: Text(signup ? 'Already have an account? Log in' : 'Need an account? Sign up'),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Required' : null;
}
