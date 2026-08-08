import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/strings.dart';
import 'models/models.dart';
import 'screens/diet_screen.dart';
import 'screens/encyclopedia_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/label_screen.dart';
import 'screens/market_mode_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/paywall_screen.dart';
import 'screens/result_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/search_screen.dart';
import 'services/history_service.dart';
import 'services/knowledge_base.dart';
import 'services/premium_service.dart';
import 'widgets/verdict_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PremiumService.init(); // Anahtar tanımlı değilse sessizce çevrimdışı kalır.
  runApp(const HalisApp());
}

class HalisApp extends StatelessWidget {
  const HalisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Halis',
      debugShowCheckedModeBanner: false,
      // Çok dilli destek: TR/EN/DE/FR/AR/ID — Arapça'da RTL otomatiktir.
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), Locale('tr'), Locale('de'),
        Locale('fr'), Locale('ar'), Locale('id'),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B7A43)),
        useMaterial3: true,
      ),
      home: const _Gate(),
    );
  }
}

/// Onboarding kabul edilmeden ana ekrana geçilmez.
class _Gate extends StatefulWidget {
  const _Gate();

  @override
  State<_Gate> createState() => _GateState();
}

class _GateState extends State<_Gate> {
  bool? _accepted;

  @override
  void initState() {
    super.initState();
    OnboardingScreen.isAccepted().then((v) => setState(() => _accepted = v));
  }

  @override
  Widget build(BuildContext context) {
    return switch (_accepted) {
      null => const Scaffold(body: Center(child: CircularProgressIndicator())),
      false => OnboardingScreen(onAccepted: () => setState(() => _accepted = true)),
      true => const HomeScreen(),
    };
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Profile _profile = Profile.diyanet;
  KnowledgeBase? _kb;
  List<HistoryEntry> _history = const [];
  final _manualController = TextEditingController();

  @override
  void initState() {
    super.initState();
    KnowledgeBase.loadFromAssets().then((kb) => setState(() => _kb = kb));
    _reloadHistory();
  }

  Future<void> _reloadHistory() async {
    final entries = await HistoryService().load();
    if (mounted) setState(() => _history = entries);
  }

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  Future<void> _openScanner() async {
    final barcode = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );
    if (barcode != null && mounted) await _showResult(barcode);
  }

  Future<void> _showResult(String barcode) async {
    if (_kb == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultScreen(barcode: barcode, profile: _profile, kb: _kb!),
      ),
    );
    await _reloadHistory();
  }

  Future<void> _openLabelFlow() async {
    if (_kb == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LabelScreen(profile: _profile, kb: _kb!)),
    );
    await _reloadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.appName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            tooltip: s.myProducts,
            onPressed: () {
              if (_kb == null) return;
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => FavoritesScreen(profile: _profile, kb: _kb!),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: s.dietTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DietScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: s.encyclopediaTitle,
            onPressed: () {
              if (_kb == null) return;
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => EncyclopediaScreen(profile: _profile, kb: _kb!),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.workspace_premium),
            tooltip: s.premiumTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PaywallScreen()),
            ),
          ),
        ],
      ),
      body: _kb == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 8),
                Text(
                  s.tagline,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _openScanner,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(s.scanBarcode, style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _openLabelFlow,
                  icon: const Icon(Icons.photo_camera),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(s.analyzeLabel, style: const TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (_kb == null) return;
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => SearchScreen(profile: _profile, kb: _kb!),
                          ));
                        },
                        icon: const Icon(Icons.search),
                        label: Text(s.searchByName),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          if (_kb == null) return;
                          await Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => MarketModeScreen(profile: _profile, kb: _kb!),
                          ));
                          await _reloadHistory();
                        },
                        icon: const Icon(Icons.shopping_basket_outlined),
                        label: Text(s.marketMode),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(s.sensitivityProfile, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SegmentedButton<Profile>(
                  segments: [
                    for (final p in Profile.values)
                      ButtonSegment(value: p, label: Text(s.profileName(p))),
                  ],
                  selected: {_profile},
                  onSelectionChanged: (sel) async {
                    setState(() => _profile = sel.first);
                    // Geçmişteki hükümler yeni profilin gözünden tazelenir.
                    if (_kb != null) {
                      final updated = await HistoryService().reanalyze(_kb!, _profile);
                      if (mounted) setState(() => _history = updated);
                    }
                  },
                ),
                const SizedBox(height: 24),
                // Geliştirme/simülatör için elle barkod girişi.
                TextField(
                  controller: _manualController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: s.manualBarcode,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        final code = _manualController.text.trim();
                        if (code.isNotEmpty) _showResult(code);
                      },
                    ),
                  ),
                ),
                if (_history.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Builder(builder: (context) {
                    final now = DateTime.now();
                    final month = _history
                        .where((e) => e.date.year == now.year && e.date.month == now.month);
                    final flagged = month
                        .where((e) =>
                            e.verdict == Verdict.haram || e.verdict == Verdict.mushbooh)
                        .length;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.insights, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(s.statsLine(month.length, flagged))),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  Text(s.recentScans, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  for (final e in _history.take(10))
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(verdictStyle(e.verdict).$2, color: verdictStyle(e.verdict).$1),
                      title: Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        '${e.date.day.toString().padLeft(2, '0')}.${e.date.month.toString().padLeft(2, '0')}.${e.date.year}',
                      ),
                    ),
                ],
                const SizedBox(height: 24),
                Text(
                  s.disclaimer,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                if (_kb != null) ...[
                  const SizedBox(height: 8),
                  // Güven mesajı: sürüm numarası değil, veritabanının gücü
                  // vurgulanır (Ufuk, 2026-08-08: "v0.x" şüphe uyandırıyor).
                  Text(
                    s.ecodeDbBadge(_kb!.ecodes.length),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
    );
  }
}
