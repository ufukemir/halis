import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../l10n/strings.dart';
import '../services/premium_service.dart';

/// Halis Premium satın alma ekranı.
///
/// Fiyat daima mağazadan (RevenueCat teklifi) okunur — elle fiyat yazılmaz,
/// bölgesel fiyatlandırma ve vergiler mağazanındır. Mağaza yapılandırılmamışsa
/// (anahtar öncesi geliştirme sürümleri) bilgilendirme gösterilir.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  Package? _package;
  bool _loading = true;
  bool _busy = false;
  bool _premium = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final premium = await PremiumService.isPremium();
    final package = await PremiumService.currentPackage();
    if (!mounted) return;
    setState(() {
      _premium = premium;
      _package = package;
      _loading = false;
    });
  }

  Future<void> _buy() async {
    final package = _package;
    if (package == null) return;
    setState(() => _busy = true);
    final ok = await PremiumService.purchase(package);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _premium = ok;
    });
    if (!ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(S.of(context).purchaseFailed)));
    }
  }

  Future<void> _restore() async {
    setState(() => _busy = true);
    final ok = await PremiumService.restore();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _premium = ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.premiumTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Icon(Icons.workspace_premium, size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(s.premiumTitle,
                    style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Text(s.premiumBenefits, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 24),
                if (_premium)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(child: Text(s.premiumActive)),
                        ],
                      ),
                    ),
                  )
                else if (_package != null) ...[
                  FilledButton(
                    onPressed: _busy ? null : _buy,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        s.subscribeFor(_package!.storeProduct.priceString),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _busy ? null : _restore,
                    child: Text(s.restorePurchases),
                  ),
                ] else
                  Text(s.storeUnavailable,
                      style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
                if (_busy)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
    );
  }
}
