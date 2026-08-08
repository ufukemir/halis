import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
import '../services/knowledge_base.dart';
import '../services/off_api.dart';
import 'result_screen.dart';
import 'scan_screen.dart';

/// Barkodsuz ürün arama: isim/marka → OFF sonuç listesi → sonuç kartı.
/// Barkod gibi sınırsız ve ücretsizdir (yerel kural motoru).
///
/// Büyüme döngüsü: kullanıcının ülkesindeki ürünler öne gelir; aranan ürün
/// yoksa kullanıcı barkodu taratıp fotoğrafla ekler — veritabanı her
/// aramayla büyür.
class SearchScreen extends StatefulWidget {
  final Profile profile;
  final KnowledgeBase kb;

  const SearchScreen({super.key, required this.profile, required this.kb});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _hits = <OffSearchHit>[];
  bool _searched = false;
  bool _busy = false;
  bool _error = false;
  bool _moreAvailable = false;
  int _page = 1;

  /// OFF ülke alt alanları dil koduyla örtüşen pazarlar (TR/DE/FR/ID).
  /// Diğer dillerde yalnız dünya araması yapılır.
  static const _countryByLang = {'tr': 'tr', 'de': 'de', 'fr': 'fr', 'id': 'id'};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search({bool loadMore = false}) async {
    final q = _controller.text.trim();
    if (q.length < 2 || _busy) return;
    setState(() {
      _busy = true;
      _error = false;
      if (!loadMore) {
        _hits.clear();
        _page = 1;
        _searched = false;
      }
    });
    try {
      final lang = S.of(context).lang;
      final batch = await OffApi().searchByName(
        q,
        page: _page,
        countryCode: _countryByLang[lang],
      );
      if (!mounted) return;
      setState(() {
        final seen = {for (final h in _hits) h.barcode};
        _hits.addAll(batch.where((h) => !seen.contains(h.barcode)));
        _searched = true;
        _moreAvailable = batch.length >= 12;
        _page += 1;
      });
    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Bulunamayan ürün: barkod tarat → sonuç ekranı. Ürün OFF'ta yoksa oradaki
  /// "bulunamadı" akışı fotoğraflı katkıya götürür (OFF'a yükleme).
  Future<void> _scanAndAdd() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );
    if (code == null || code.isEmpty || !mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ResultScreen(barcode: code, profile: widget.profile, kb: widget.kb),
    ));
  }

  Widget _contributeCard() {
    final s = S.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.searchContributeHint, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton.tonalIcon(
                onPressed: _scanAndAdd,
                icon: const Icon(Icons.qr_code_scanner, size: 18),
                label: Text(s.scanAndAdd),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.searchByName)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: s.searchHint,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: _search),
              ),
            ),
          ),
          if (_error)
            Padding(padding: const EdgeInsets.all(16), child: Text(s.networkError)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                for (final hit in _hits)
                  ListTile(
                    leading: hit.imageUrl != null
                        ? Image.network(hit.imageUrl!, width: 40,
                            errorBuilder: (_, _, _) => const Icon(Icons.fastfood))
                        : const Icon(Icons.fastfood),
                    title: Text(hit.name ?? hit.barcode,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: hit.brands != null ? Text(hit.brands!, maxLines: 1) : null,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ResultScreen(
                          barcode: hit.barcode, profile: widget.profile, kb: widget.kb),
                    )),
                  ),
                if (_busy)
                  const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator())),
                if (!_busy && _searched && _hits.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(s.noResults, textAlign: TextAlign.center),
                        ),
                        _contributeCard(),
                      ],
                    ),
                  ),
                if (!_busy && _hits.isNotEmpty) ...[
                  if (_moreAvailable)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: OutlinedButton(
                        onPressed: () => _search(loadMore: true),
                        child: Text(s.loadMore),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: _contributeCard(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
