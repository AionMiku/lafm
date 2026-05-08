import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

class ShareImageGeneratorDialog extends StatefulWidget {
  final String arabicText;
  final String? englishText;
  final String? transliterationText;
  final String reference;

  const ShareImageGeneratorDialog({
    super.key,
    required this.arabicText,
    this.englishText,
    this.transliterationText,
    required this.reference,
  });

  @override
  State<ShareImageGeneratorDialog> createState() => _ShareImageGeneratorDialogState();
}

class _ShareImageGeneratorDialogState extends State<ShareImageGeneratorDialog> {
  final GlobalKey _globalKey = GlobalKey();
  
  bool _showArabic = true;
  bool _showEnglish = true;
  bool _showTransliteration = true;
  int _selectedStyleIndex = 0;
  bool _isExporting = false;

  final List<List<Color>> _chromaticGradients = [
    [
      const Color(0xFF1B4E63),
      const Color(0xFF459E87),
      const Color(0xFF266C63),
      const Color(0xFF194042),
      const Color(0xFF0C2426),
    ], // Nordic Ummah Default
    [const Color(0xFF1E3C72), const Color(0xFF2A5298)], // Deep Ocean
    [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)], // Midnight
    [const Color(0xFFED213A), const Color(0xFF93291E)], // Blood Red
    [const Color(0xFF00b09b), const Color(0xFF96c93d)], // Earth Green
    [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)], // Purple Mystic
  ];

  Future<void> _captureAndShare() async {
    setState(() {
      _isExporting = true;
    });

    try {
      // 1. Give UI a microsecond to hide any focus states if needed
      await Future.delayed(const Duration(milliseconds: 100));

      // 2. Render Boundary to UI Image
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      // Use pixelRatio 3.0 for ultra crisp HD images perfect for Instagram
      ui.Image image = await boundary.toImage(pixelRatio: 3.0); 
      
      // 3. Convert Image to Bytes
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // 4. Share using cross_file XFile in memory
      final xFile = XFile.fromData(
        pngBytes, 
        mimeType: 'image/png', 
        name: 'shared_islamic_verse.png'
      );
      
      await Share.shareXFiles(
        [xFile],
        text: 'Read more in the App: ${widget.reference}',
      );
      
      if (mounted) Navigator.pop(context); // Close the dialog after sharing
    } catch (e) {
      debugPrint('Error generating graphic: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate image.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Customize Share Graphic",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // THE CANVAS TO BE CAPTURED
              RepaintBoundary(
                key: _globalKey,
                child: Container(
                  width: 1080 / 3, // Simulate Instagram square/portrait width for ideal text wrapping
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _chromaticGradients[_selectedStyleIndex],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // The Glassmorphic Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, spreadRadius: 5)
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // "Reference" mimicking the top title of the Dua card
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.menu_book, color: Colors.white70, size: 16),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    widget.reference,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            if (_showArabic) ...[
                              Text(
                                widget.arabicText,
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(
                                  fontSize: 26,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            
                            if (_showTransliteration && widget.transliterationText != null && widget.transliterationText!.isNotEmpty) ...[
                              Text(
                                widget.transliterationText!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            
                            if (_showEnglish && widget.englishText != null && widget.englishText!.isNotEmpty) ...[
                              Text(
                                widget.englishText!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // App Branding Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.mosque, color: Colors.white54, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "LAFM • Nordic Ummah",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              
              // CUSTOMIZATION CONTROLS
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Background Styles", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _chromaticGradients.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedStyleIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedStyleIndex = index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: _chromaticGradients[index],
                          ),
                          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                          boxShadow: isSelected ? [
                            BoxShadow(color: _chromaticGradients[index].first.withOpacity(0.5), blurRadius: 8)
                          ] : null,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
              
              SwitchListTile(
                title: const Text("Show Arabic"),
                value: _showArabic,
                onChanged: (val) => setState(() => _showArabic = val),
              ),
              if (widget.transliterationText != null)
                SwitchListTile(
                  title: const Text("Show Transliteration"),
                  value: _showTransliteration,
                  onChanged: (val) => setState(() => _showTransliteration = val),
                ),
              if (widget.englishText != null)
                SwitchListTile(
                  title: const Text("Show Translation"),
                  value: _showEnglish,
                  onChanged: (val) => setState(() => _showEnglish = val),
                ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isExporting ? null : _captureAndShare,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isExporting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.share),
                  label: Text(_isExporting ? "Generating High-Res Graphic..." : "Share to Social Media"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
