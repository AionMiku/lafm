import 'package:flutter/material.dart';
import '../../../core/services/quran_service.dart';

class PageReaderScreen extends StatefulWidget {
  final int page;

  const PageReaderScreen({
    super.key,
    required this.page,
  });

  @override
  State<PageReaderScreen> createState() => _PageReaderScreenState();
}

class _PageReaderScreenState extends State<PageReaderScreen> {
  final QuranService service = QuranService();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Page data to be integrated with API/DB later.
    if (!mounted) return;
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page ${widget.page}'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : const Center(
              child: Text(
                'Page view coming next',
                style: TextStyle(color: Colors.grey),
              ),
            ),
    );
  }
}
