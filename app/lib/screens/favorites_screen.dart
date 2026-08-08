import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
import '../services/favorites_service.dart';
import '../services/knowledge_base.dart';
import '../widgets/verdict_view.dart';
import 'result_screen.dart';

/// İşaretli ürünler: Favoriler / Kaçındıklarım sekmeleri.
class FavoritesScreen extends StatefulWidget {
  final Profile profile;
  final KnowledgeBase kb;

  const FavoritesScreen({super.key, required this.profile, required this.kb});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<FlaggedProduct> _all = const [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final all = await FavoritesService().load();
    if (mounted) setState(() => _all = all);
  }

  Widget _list(ProductFlag flag) {
    final s = S.of(context);
    final items = _all.where((p) => p.flag == flag).toList();
    if (items.isEmpty) {
      return Center(
        child: Padding(padding: const EdgeInsets.all(32), child: Text(s.noResults)),
      );
    }
    return ListView(
      children: [
        for (final p in items)
          ListTile(
            leading: Icon(verdictStyle(p.verdict).$2,
                color: verdictStyle(p.verdict).$1,
                semanticLabel: s.verdictTitle(p.verdict)),
            title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(p.barcode),
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ResultScreen(
                    barcode: p.barcode, profile: widget.profile, kb: widget.kb),
              ));
              await _reload();
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.myProducts),
          bottom: TabBar(tabs: [
            Tab(icon: const Icon(Icons.bookmark), text: s.favorites),
            Tab(icon: const Icon(Icons.block), text: s.avoided),
          ]),
        ),
        body: TabBarView(
          children: [_list(ProductFlag.fav), _list(ProductFlag.avoid)],
        ),
      ),
    );
  }
}
