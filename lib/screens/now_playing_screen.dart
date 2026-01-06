import 'package:flutter/material.dart';

/// Màn hình Now Playing hiển thị thông tin và điều khiển bài hát đang phát (UI-only, mock data)
class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    const String songTitle = 'Blinding Lights';
    const String artistName = 'The Weeknd';
    const String playlistSource = 'My Playlist';
    const String currentTime = '2:34';
    const String totalDuration = '3:20';
    const double progressValue = 0.48; // 2:34 / 3:20 ≈ 0.48
    const bool isPlaying = true;
    const bool isLiked = false;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP BAR
            _buildTopBar(context, playlistSource),
            
            const SizedBox(height: 24),
            
            // 2. ALBUM ARTWORK
            Expanded(
              flex: 3,
              child: _buildAlbumArtwork(context),
            ),
            
            const SizedBox(height: 32),
            
            // 3. SONG INFO ROW
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildSongInfoRow(songTitle, artistName, isLiked),
            ),
            
            const SizedBox(height: 32),
            
            // 4. PROGRESS BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildProgressBar(currentTime, totalDuration, progressValue),
            ),
            
            const SizedBox(height: 40),
            
            // 5. PLAYBACK CONTROLS
            _buildPlaybackControls(isPlaying),
            
            const SizedBox(height: 32),
            
            // 6. ACTION ICON ROW
            _buildActionIconRow(),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // 1. TOP BAR
  Widget _buildTopBar(BuildContext context, String playlistSource) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back/minimize icon (left)
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            iconSize: 32,
            onPressed: () => Navigator.of(context).pop(),
          ),
          
          // Optional playlist/source text (center, small)
          Text(
            playlistSource,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
          
          // More (⋮) icon (right)
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            iconSize: 24,
            onPressed: () {
              // Mock action - no real logic
            },
          ),
        ],
      ),
    );
  }

  // 2. ALBUM ARTWORK
  Widget _buildAlbumArtwork(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Center(
        child: AspectRatio(
          aspectRatio: 1.0, // Square (1:1 ratio)
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: Colors.grey.shade800,
                child: const Icon(
                  Icons.music_note,
                  size: 100,
                  color: Colors.white24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 3. SONG INFO ROW
  Widget _buildSongInfoRow(String songTitle, String artistName, bool isLiked) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Song title and artist (left side)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Song title (bold, max 2 lines)
              Text(
                songTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // Artist name (smaller, muted color)
              Text(
                artistName,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Like (heart) icon aligned to the right
        IconButton(
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red.shade400 : Colors.grey.shade400,
          ),
          iconSize: 28,
          onPressed: () {
            // Mock action - no real logic
          },
        ),
      ],
    );
  }

  // 4. PROGRESS BAR
  Widget _buildProgressBar(String currentTime, String totalDuration, double progressValue) {
    return Column(
      children: [
        // Slider
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.white,
            overlayColor: Colors.white.withValues(alpha: 0.1),
          ),
          child: Slider(
            value: progressValue,
            max: 1.0,
            onChanged: (value) {
              // Mock action - no real logic
            },
          ),
        ),
        
        // Time labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Current time (left)
              Text(
                currentTime,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
              ),
              // Total duration (right)
              Text(
                totalDuration,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 5. PLAYBACK CONTROLS
  Widget _buildPlaybackControls(bool isPlaying) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous button
        IconButton(
          icon: const Icon(Icons.skip_previous),
          iconSize: 32,
          color: Colors.white,
          onPressed: () {
            // Mock action - no real logic
          },
        ),
        
        const SizedBox(width: 24),
        
        // Play/Pause button (significantly larger)
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: IconButton(
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.black,
            ),
            iconSize: 48,
            padding: const EdgeInsets.all(16),
            onPressed: () {
              // Mock action - no real logic
            },
          ),
        ),
        
        const SizedBox(width: 24),
        
        // Next button
        IconButton(
          icon: const Icon(Icons.skip_next),
          iconSize: 32,
          color: Colors.white,
          onPressed: () {
            // Mock action - no real logic
          },
        ),
      ],
    );
  }

  // 6. ACTION ICON ROW
  Widget _buildActionIconRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Shuffle
        IconButton(
          icon: const Icon(Icons.shuffle),
          iconSize: 24,
          color: Colors.grey.shade400,
          onPressed: () {
            // Mock action - no real logic
          },
        ),
        
        const SizedBox(width: 32),
        
        // Repeat
        IconButton(
          icon: const Icon(Icons.repeat),
          iconSize: 24,
          color: Colors.grey.shade400,
          onPressed: () {
            // Mock action - no real logic
          },
        ),
        
        const SizedBox(width: 32),
        
        // Queue
        IconButton(
          icon: const Icon(Icons.queue_music),
          iconSize: 24,
          color: Colors.grey.shade400,
          onPressed: () {
            // Mock action - no real logic
          },
        ),
      ],
    );
  }
}

