import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
import '../services/history_service.dart';
import '../services/knowledge_base.dart';
import '../services/ocr_service.dart';
import '../services/rule_engine.dart';
import '../widgets/verdict_view.dart';

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
  String? _error;

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
      final image = await _picker.pickImage(source: source, maxWidth: 2048);
      if (image == null) return;
      final text = await OcrService().extractText(image.path);
      if (!mounted) return;
      if (text.trim().isEmpty) {
        setState(() => _error = S.of(context).ocrFailed);
      } else {
        setState(() {
          _controller.text = text.replaceAll('\n', ' ');
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
    final result = RuleEngine(widget.kb).analyze(
      profile: widget.profile,
      ingredientsText: text,
    );
    setState(() => _result = result);
    final title = text.length > 40 ? '${text.substring(0, 40)}…' : text;
    await HistoryService().add(HistoryEntry(title: title, verdict: result.verdict, date: DateTime.now()));
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
          if (_result != null) ...[
            const SizedBox(height: 16),
            VerdictView(result: _result!, profile: widget.profile),
          ],
        ],
      ),
    );
  }
}
