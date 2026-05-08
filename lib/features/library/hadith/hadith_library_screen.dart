import 'package:flutter/material.dart';
import 'dart:ui'; // For ImageFilter

import 'hadith_models.dart';
import 'hadith_reader_screen.dart';
import 'data/hadith_repository.dart';
import 'data/hadith_books_config.dart';
import 'widgets/hadith_book_card.dart';

class HadithLibraryScreen extends StatefulWidget {
  const HadithLibraryScreen({super.key});

  @override
  State<HadithLibraryScreen> createState() => _HadithLibraryScreenState();
}

class _HadithLibraryScreenState extends State<HadithLibraryScreen> {
  String _searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter books
    final filteredBooks = hadithBooksConfig.where(
        (b) => b.titleEnglish.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    // Extract Bukhari as featured
    final bukhariIndex = filteredBooks.indexWhere((b) => b.id == 'bukhari');
    HadithBook? bukhari;
    if (bukhariIndex != -1) {
      bukhari = filteredBooks.removeAt(bukhariIndex);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevents LayoutBuilder from shrinking and crashing cards!
      appBar: AppBar(title: const Text('Hadith Library')),
      body: Column(
        children: [
          // Sticky search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search Hadith Collections',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty || _searchFocusNode.hasFocus
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          _searchFocusNode.unfocus();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
          ),
          
          Expanded(
            child: Stack(
              children: [
                 // The Base Grid Content
                 LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate static physical height so the grid never squishes when the keyboard layout shrinks
                    final physicalHeight = MediaQuery.sizeOf(context).height;
                    // Approximate the safe area (minus appbar, bottom nav, search bar, etc)
                    final staticAvailableHeight = physicalHeight - 220; 

                    final bukhariHeight = (staticAvailableHeight * 0.35).clamp(140.0, 240.0);
                    final totalVerticalPaddingAndSpacing = 16.0 + 8.0 + 8.0 + 16.0; 
                    final targetGridHeight = staticAvailableHeight - bukhariHeight - totalVerticalPaddingAndSpacing;
                    
                    final rowHeight = (targetGridHeight / 2.0).clamp(100.0, 300.0);
                    final crossAxisWidth = (constraints.maxWidth - 32.0 - 16.0) / 2.0;
                    final childAspectRatio = crossAxisWidth / rowHeight;

                    return CustomScrollView(
                      slivers: [
                        if (bukhari != null)
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            sliver: SliverToBoxAdapter(
                              child: SizedBox(
                                height: bukhariHeight,
                                child: HadithBookCard(
                                  book: bukhari,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => HadithReaderScreen(book: bukhari!),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                        if (filteredBooks.isEmpty)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Center(child: Text('No books found')),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            sliver: SliverGrid(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: childAspectRatio,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final book = filteredBooks[index];
                                  return HadithBookCard(
                                    book: book,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => HadithReaderScreen(book: book),
                                        ),
                                      );
                                    },
                                  );
                                },
                                childCount: filteredBooks.length,
                              ),
                            ),
                          ),
                          
                        const SliverToBoxAdapter(child: SizedBox(height: 32)),
                      ],
                    );
                  },
                ),

                // Blur Overlay triggered when Keyboard/Search is focused
                if (_searchFocusNode.hasFocus)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => _searchFocusNode.unfocus(), // Tap background to dismiss keyboard
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                          child: Container(
                            color: Colors.black.withOpacity(0.0), // Empty transparent screen over blur
                            alignment: Alignment.topCenter,
                            padding: const EdgeInsets.only(top: 40),
                            // Later we will put Search Suggestions here!
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
