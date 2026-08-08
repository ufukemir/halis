import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
import '../services/knowledge_base.dart';
import '../services/off_api.dart';
import 'result_screen.dart';

/// Barkodsuz ürün arama: isim/marka → OFF sonuç listesi → sonuç kartı.
/// Barkod gibi sınırsız ve ücretsizdir (yerel kural motoru).
class SearchScreen extends StatefulWidget {
  final Profile profile;
  final KnowledgeBase kb;

  const SearchScreen({super.key, required this.profile, required this.kb});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<OffSearchHit>? _hits;
  bool _busy = false;
  bool _error = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _controller.text.trim();
    if (q.length < 2) return;
    setState(() {
      _busy = true;
      _error = false;
    });
    try {
      final hits = await OffApi().searchByName(q);
      if (mounted) setState(() => _hits = hits);
    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
          if (_busy) const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
          if (_error)
            Padding(padding: const EdgeInsets.all(16), child: Text(s.networkError)),
          if (!_busy && _hits != null && _hits!.isEmpty)
            Padding(padding: const EdgeInsets.all(16), child: Text(s.noResults)),
          if (!_busy && _hits != null)
            Expanded(
              child: ListView(
                children: [
                  for (final hit in _hits!)
                    ListTile(
                      leading: hit.imageUrl != null
                          ? Image.network(hit.imageUrl!, width: 40,
                              errorBuilder: (_, _, _) => const Icon(Icons.fastfood))
                          : const Icon(Icons.fastfood),
                      title: Text(hit.name ?? hit.barcode, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: hit.brands != null ? Text(hit.brands!, maxLines: 1) : null,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ResultScreen(
                            barcode: hit.barcode, profile: widget.profile, kb: widget.kb),
                      )),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
