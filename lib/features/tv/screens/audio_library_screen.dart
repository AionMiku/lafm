import 'dart:ui';
import 'package:flutter/material.dart';

class AudioLibraryScreen extends StatefulWidget {
  const AudioLibraryScreen({super.key});

  @override
  State<AudioLibraryScreen> createState() => _AudioLibraryScreenState();
}

class _AudioLibraryScreenState extends State<AudioLibraryScreen> {
  bool _isPlaying = false;
  String? _currentTrackTitle;
  String? _currentTrackArtist;
  String? _currentTrackImage;

  void _playTrack(String title, String artist, String image) {
    setState(() {
      _currentTrackTitle = title;
      _currentTrackArtist = artist;
      _currentTrackImage = image;
      _isPlaying = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // MAIN SCROLLING LIBRARY
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: _currentTrackTitle != null ? 100.0 : 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("Popular Nasheeds", context),
                      _buildHorizontalLane([
                        _TrackData("Ya Ilahi", "Mishary Rashid", "https://images.unsplash.com/photo-1590465351717-36e65bac9ad7?q=80&w=400&fit=crop"),
                        _TrackData("Rahman", "Maher Zain", "https://images.unsplash.com/photo-1606122017369-d78222896d8e?q=80&w=400&fit=crop"),
                        _TrackData("As Subhu Bada", "Sami Yusuf", "https://images.unsplash.com/photo-1565552645632-d725f8bfc19a?q=80&w=400&fit=crop"),
                        _TrackData("Qamarun", "Mostafa Atef", "https://images.unsplash.com/photo-1574246604907-dbbc562be64d?q=80&w=400&fit=crop"),
                      ], context),

                      const SizedBox(height: 32),

                      _buildSectionHeader("Trending Podcasts", context),
                      _buildHorizontalLane([
                        _TrackData("Life of Prophet", "Mufti Menk", "https://images.unsplash.com/photo-1507676184212-d0330a151b14?q=80&w=400&fit=crop"),
                        _TrackData("Heart Detox", "Omar Suleiman", "https://images.unsplash.com/photo-1490730141103-6cac27aaab94?q=80&w=400&fit=crop"),
                        _TrackData("Qur'an Tafseer", "Nouman Ali Khan", "https://images.unsplash.com/photo-1584224097475-430349887f46?q=80&w=400&fit=crop"),
                      ], context, isRounded: false),

                      const SizedBox(height: 32),

                      _buildSectionHeader("Qur'an Collections", context),
                      _buildHorizontalLane([
                        _TrackData("Surah Yaseen", "Abdul Rahman", "https://images.unsplash.com/photo-1591604129935-1153308ce7a8?q=80&w=400&fit=crop"),
                        _TrackData("Surah Ar-Rahman", "Mishary", "https://images.unsplash.com/photo-1606122017369-d78222896d8e?q=80&w=400&fit=crop"),
                      ], context),
                      
                    ],
                  ),
                ),
              ),
            ],
          ),

          // iOS GLASSMORPHIC MINI PLAYER OVERLAY
          if (_currentTrackTitle != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: GestureDetector(
                onTap: () {},
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                    child: Container(
                      height: 68,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).dividerColor.withOpacity(0.2), 
                          width: 1
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              // Mini Art
                              Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                                ),
                                child: const Icon(Icons.music_note, size: 30, color: Colors.white54),
                              ),
                              const SizedBox(width: 12),
                              // Title & Artist
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _currentTrackTitle!,
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyLarge?.color, 
                                        fontWeight: FontWeight.bold, 
                                        fontSize: 14
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _currentTrackArtist!,
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7), 
                                        fontSize: 12
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Controls
                              IconButton(
                                icon: Icon(Icons.speaker_group_outlined, color: Theme.of(context).iconTheme.color?.withOpacity(0.7)),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Theme.of(context).iconTheme.color, size: 32),
                                onPressed: () => setState(() => _isPlaying = !_isPlaying),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                          // Mini Progress Bar!
                          Positioned(
                            bottom: 0,
                            left: 12,
                            right: 12,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                color: Theme.of(context).dividerColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 120, // Artificial progress
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20, 
          fontWeight: FontWeight.bold, 
          color: Theme.of(context).textTheme.bodyLarge?.color
        ),
      ),
    );
  }

  Widget _buildHorizontalLane(List<_TrackData> tracks, BuildContext context, {bool isRounded = true}) {
    return SizedBox(
      height: 195,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          final t = tracks[index];
          return GestureDetector(
            onTap: () => _playTrack(t.title, t.artist, t.image),
            child: Container(
              width: 140,
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(isRounded ? 16 : 4),
                    ),
                    child: const Icon(Icons.music_note, size: 50, color: Colors.white54),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    t.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600, 
                      color: Theme.of(context).textTheme.bodyLarge?.color, 
                      fontSize: 13
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t.artist,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7), 
                      fontSize: 12
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TrackData {
  final String title;
  final String artist;
  final String image;
  _TrackData(this.title, this.artist, this.image);
}