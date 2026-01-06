import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/track.dart';
import '../../services/database_service.dart';
import '../../widgets/track_item.dart';
import '../../widgets/loading_indicator.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  List<Track> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final db = LocalDatabaseService();
      final favorites = await db.getFavoriteTracks();
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite(Track track) async {
    try {
      final db = LocalDatabaseService();
      if (track.isFavorite) {
        await db.removeFromFavorites(track.id!);
      } else {
        await db.addToFavorites(track.id!);
      }
      await _loadFavorites();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu thích'),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _favorites.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Chưa có bài hát yêu thích'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    itemCount: _favorites.length,
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      final track = _favorites[index];
                      return TrackItem(
                        track: track,
                        onTap: () => context.push('/player/${track.id}'),
                        onToggleFavorite: () => _toggleFavorite(track),
                      );
                    },
                  ),
                ),
    );
  }
}

