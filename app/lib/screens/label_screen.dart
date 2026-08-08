import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
import '../services/history_service.dart';
import '../services/knowledge_base.dart';
import '../services/normalize_api.dart';
import '../services/ocr_service.dart';
import '../services/premium_service.dart';
import '../services/rule_engine.dart';
import '../widgets/verdict_view.dart';
import 'paywall_screen.dart';

/// Etiket fotoğrafı akışı: foto → cihaz üstü OCR → düzenlenebilir metin →
/// yerel kural motoru. Simülatörde kamera olmadığından metin elle de girilir.
class LabelScreen extends StatefulWidget {
  final Profile profile;
  final KnowledgeBase kb;

  const LabelScreen({super.key, required this.profile, required this.kb});

  @override
  State<LabelScreen> createState() => _LabelScreenState();
}

class _LabelScreenState extends State<LabelScreen> {
  final _controller = TextEditingController();
  final _picker = ImagePicker();
  AnalysisResult? _result;
  bool _busy = false;
  bool _aiNormalized = false;
  String? _error;
  int? _remaining; // null → premium veya henüz yüklenmedi (gösterilmez)

  @override
  void initState() {
    super.initState();
    _loadQuota();
  }

  Future<void> _loadQuota() async {
    if (await PremiumService.isPremium()) return;
    final r = await PremiumService.remainingLabelAnalyses();
    if (mounted) setState(() => _remaining = r);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final lang = S.of(context).lang;
      final image = await _picker.pickImage(source: source, maxWidth: 2048);
      if (image == null) return;
      final text = await OcrService().extractText(image.path);
      if (!mounted) return;
      if (text.trim().isEmpty) {
        setState(() => _error = S.of(context).ocrFailed);
      } else {
        var display = text.replaceAll('\n', ' ');
        var aiUsed = false;
        // Backend tanımlıysa ve kota varsa OCR metnini LLM ile normalize et.
        // Hata/zaman aşımında sessizce ham metinle devam edilir; hüküm her
        // durumda yerel kural motorundadır.
        if (NormalizeApi.isConfigured && await PremiumService.canAnalyzeLabel()) {
          final norm = await NormalizeApi().normalize(text, lang: lang);
          if (norm != null && norm.combinedText.isNotEmpty) {
            display = norm.combinedText;
            aiUsed = true;
          }
        }
        if (!mounted) return;
        setState(() {
          _controller.text = display;
          _aiNormalized = aiUsed;
          _result = null;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = S.of(context).ocrFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _analyze() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (!await PremiumService.canAnalyzeLabel()) {
      if (mounted) _showQuotaDialog();
      return;
    }
    final result = RuleEngine(widget.kb).analyze(
      profile: widget.profile,
      ingredientsText: text,
    );
    setState(() => _result = result);
    await PremiumService.recordLabelAnalysis();
    await _loadQuota();
    final title = text.length > 40 ? '${text.substring(0, 40)}…' : text;
    await HistoryService().add(HistoryEntry(title: title, verdict: result.verdict, date: DateTime.now()));
  }

  void _showQuotaDialog() {
    final s = S.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.quotaTitle),
        content: Text(PremiumService.storeConfigured ? s.quotaBodyUpgrade : s.quotaBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(s.ok)),
          if (PremiumService.storeConfigured)
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PaywallScreen()),
                );
              },
              child: Text(s.goPremium),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.labelTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(s.ocrHint, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _pick(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera),
                  label: Text(s.takePhoto),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _pick(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: Text(s.fromGallery),
                ),
              ),
            ],
          ),
          if (_busy) const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          if (_aiNormalized)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(child: Text(s.aiNormalized, style: Theme.of(context).textTheme.bodySmall)),
                ],
              ),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 5,
            decoration: InputDecoration(labelText: s.labelTextField, border: const OutlineInputBorder()),
            onChanged: (_) {
              if (_result != null) setState(() => _result = null);
            },
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _busy ? null : _analyze,
            icon: const Icon(Icons.search),
            label: Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(s.analyze)),
          ),
          if (_remaining != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                s.remainingAnalyses(_remaining!),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          if (_result != null) ...[
            const SizedBox(height: 16),
            VerdictView(result: _result!, profile: widget.profile),
          ],
        ],
      ),
    );
  }
}
