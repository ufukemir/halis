import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/strings.dart';

/// İlk açılış: konumlandırma + yasal/dini sorumluluk beyanı. Kabul edilmeden
/// uygulamaya geçilmez (docs/02 disclaimer pratiği).
class OnboardingScreen extends StatelessWidget {
  static const prefsKey = 'onboarding_accepted_v1';

  final VoidCallback onAccepted;

  const OnboardingScreen({super.key, required this.onAccepted});

  static Future<bool> isAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefsKey) ?? false;
  }

  Future<void> _accept() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsKey, true);
    onAccepted();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Icon(Icons.verified_outlined,
                  size: 72, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(s.onboardingTitle,
                  textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(s.onboardingBody, style: Theme.of(context).textTheme.bodyMedium),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _accept,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(s.onboardingAccept, style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
