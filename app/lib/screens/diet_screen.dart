import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../services/diet_service.dart';

/// Diyet/alerjen hassasiyet seçimi. Seçimler cihazda saklanır; ürün kartında
/// helal hükmünden AYRI uyarılar üretir.
class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  Set<String>? _selected;

  @override
  void initState() {
    super.initState();
    DietService().selected().then((v) {
      if (mounted) setState(() => _selected = v);
    });
  }

  Future<void> _toggle(String key, bool on) async {
    final next = {..._selected!};
    on ? next.add(key) : next.remove(key);
    setState(() => _selected = next);
    await DietService().setSelected(next);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.dietTitle)),
      body: _selected == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(s.dietHint, style: Theme.of(context).textTheme.bodySmall),
                ),
                for (final key in DietService.allergenTagByKey.keys)
                  CheckboxListTile(
                    value: _selected!.contains(key),
                    title: Text(s.allergenName(key)),
                    onChanged: (v) => _toggle(key, v ?? false),
                  ),
                const Divider(),
                for (final key in DietService.dietKeys)
                  CheckboxListTile(
                    value: _selected!.contains(key),
                    title: Text(s.dietPrefName(key)),
                    onChanged: (v) => _toggle(key, v ?? false),
                  ),
              ],
            ),
    );
  }
}
