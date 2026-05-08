import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/services/asma_service.dart';
import '../../data/models/asma_model.dart';

class AsmaUlHusnaScreen extends StatefulWidget {
  const AsmaUlHusnaScreen({super.key});

  @override
  State<AsmaUlHusnaScreen> createState() => _AsmaUlHusnaScreenState();
}

class _AsmaUlHusnaScreenState extends State<AsmaUlHusnaScreen> {
  List<AsmaName> names = [];
  
  // 0: 2-column small grid, 1: 1-column list, 2: 1-item per screen Max
  int _zoomLevel = 1; 

  @override
  void initState() {
    super.initState();
    _loadNames();
  }

  Future<void> _loadNames() async {
    final service = AsmaService();
    final data = await service.loadNames();
    setState(() => names = data);
  }

  @override
  Widget build(BuildContext context) {
    if (names.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asma ul Husna'),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out),
            tooltip: "Zoom Out (Smaller Cards)",
            onPressed: () {
              if (_zoomLevel > 0) {
                setState(() => _zoomLevel--);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            tooltip: "Zoom In (Larger Cards)",
            onPressed: () {
              if (_zoomLevel < 2) {
                setState(() => _zoomLevel++);
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  // ============================================================
  // BODY SWITCH
  // ============================================================

  Widget _buildBody() {
    if (_zoomLevel == 0) return _gridLayout();
    if (_zoomLevel == 1) return _listView();
    return _pagedView();
  }

  // ============================================================
  // GRID VIEW (2 COLUMNS) - MINIMUM ZOOM
  // ============================================================
  Widget _gridLayout() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: names.length,
      itemBuilder: (context, index) {
        return _asmaCard(names[index], isGrid: true);
      },
    );
  }

  // ============================================================
  // LIST VIEW - MID ZOOM
  // ============================================================
  Widget _listView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: names.length,
      itemBuilder: (context, index) {
        return _asmaCard(names[index]);
      },
    );
  }

  // ============================================================
  // PAGED FIT-TO-SCREEN VIEW - MAX ZOOM
  // ============================================================
  Widget _pagedView() {
    final screenHeight = MediaQuery.of(context).size.height;
    final usableHeight = screenHeight * 0.82;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: names.length,
      itemBuilder: (context, index) {
        return SizedBox(
          height: usableHeight,
          child: _asmaCard(names[index], isMaxZoom: true),
        );
      },
    );
  }

  // ============================================================
  // ADAPTIVE CARD UI
  // ============================================================
  Widget _asmaCard(AsmaName name, {bool isGrid = false, bool isMaxZoom = false}) {
    return Container(
      margin: isGrid 
          ? EdgeInsets.zero 
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor, // Uses the 4% white tint
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.0), // Specular edge highlight
            ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name.arabic,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isGrid ? 28 : (isMaxZoom ? 48 : 36),
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name.transliteration,
            style: TextStyle(
              fontSize: isGrid ? 14 : (isMaxZoom ? 22 : 18),
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name.meaning,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isGrid ? 14 : (isMaxZoom ? 20 : 18),
              fontWeight: FontWeight.bold,
            ),
          ),

          // Only show full description if we are not in the tight grid view
          if (!isGrid) ...[
            const SizedBox(height: 12),
            Text(
              name.description,
              textAlign: TextAlign.center,
              maxLines: isMaxZoom ? 10 : 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isMaxZoom ? 18 : 14,
                height: 1.4,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ],
      ),
          ),
        ),
      ),
    );
  }
}
