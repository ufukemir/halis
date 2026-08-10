import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../services/app_settings.dart';

/// Ayarlar: yazı boyutu + dil seçimi (sistem dili ya da 17 dilden biri).
/// Değişiklikler anında uygulanır ve cihazda saklanır.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final s = S.of(context);
        return Scaffold(
          appBar: AppBar(title: Text(s.settingsTitle)),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _sectionTitle(context, s.textSizeSection),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.text_fields, size: 16),
                    Expanded(
                      child: Slider(
                        value: settings.textScale,
                        min: AppSettings.minScale,
                        max: AppSettings.maxScale,
                        divisions: 11,
                        label: '%${(settings.textScale * 100).round()}',
                        onChanged: settings.setTextScale,
                      ),
                    ),
                    const Icon(Icons.text_fields, size: 28),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  s.textSizePreview,
                  // Önizleme kasıtlı olarak seçilen ölçekle çizilir; sayfanın
                  // geri kalanı da MaterialApp builder'ı üzerinden ölçeklenir.
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const Divider(),
              _sectionTitle(context, s.languageSection),
              RadioGroup<String?>(
                groupValue: settings.locale?.languageCode,
                onChanged: settings.setLanguage,
                child: Column(
                  children: [
                    RadioListTile<String?>(
                      value: null,
                      title: Text(s.systemLanguage),
                    ),
                    for (final code in S.supported)
                      RadioListTile<String?>(
                        value: code,
                        title: Text(S.nativeNames[code] ?? code),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      );
}
