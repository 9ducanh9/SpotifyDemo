import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:printing/printing.dart';
import 'dart:io';
import '../../../../data/repositories/track_repository.dart';
import '../../../../features/tracks/presentation/providers/track_providers.dart';
import '../../../../core/services/export_service.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

/// Statistics screen with charts and tables
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksAsync = ref.watch(tracksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _showExportDialog(context, ref),
            tooltip: 'Export',
          ),
        ],
      ),
      body: tracksAsync.when(
        data: (tracks) => _buildStatistics(context, tracks),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading statistics: $error'),
        ),
      ),
    );
  }

  Widget _buildStatistics(BuildContext context, List tracks) {
    if (tracks.isEmpty) {
      return const Center(
        child: Text('No tracks available for statistics'),
      );
    }

    // Calculate statistics
    final totalTracks = tracks.length;
    final favoriteTracks = tracks.where((t) => t.isFavorite).length;
    final totalDuration = tracks.fold<int>(
      0,
      (sum, track) => sum + track.duration,
    );
    final avgDuration = totalDuration / totalTracks;
    
    // Group by artist
    final artistCounts = <String, int>{};
    for (final track in tracks) {
      artistCounts[track.artist] = (artistCounts[track.artist] ?? 0) + 1;
    }
    final topArtists = artistCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5Artists = topArtists.take(5).toList();

    // Group by date (tracks created per day)
    final dateCounts = <String, int>{};
    for (final track in tracks) {
      final date = DateFormat('yyyy-MM-dd').format(track.createdAt);
      dateCounts[date] = (dateCounts[date] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Tracks',
                  totalTracks.toString(),
                  Icons.music_note,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Favorites',
                  favoriteTracks.toString(),
                  Icons.favorite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Duration',
                  _formatDuration(totalDuration),
                  Icons.timer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Avg Duration',
                  _formatDuration(avgDuration.toInt()),
                  Icons.access_time,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Charts
          Text(
            'Top Artists',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: top5Artists.isEmpty
                ? const Center(child: Text('No data'))
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: top5Artists.first.value.toDouble() + 2,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < top5Artists.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    top5Artists[index].key,
                                    style: const TextStyle(fontSize: 10),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: top5Artists.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.value.toDouble(),
                              color: Theme.of(context).colorScheme.primary,
                              width: 20,
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
          const SizedBox(height: 32),
          // Top artists table
          Text(
            'Top Artists Table',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Artist')),
                DataColumn(label: Text('Tracks'), numeric: true),
              ],
              rows: top5Artists.map((entry) {
                return DataRow(
                  cells: [
                    DataCell(Text(entry.key)),
                    DataCell(Text(entry.value.toString())),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  Future<void> _showExportDialog(BuildContext context, WidgetRef ref) async {
    final tracksAsync = ref.read(tracksProvider);
    final tracks = await tracksAsync.value;
    
    if (tracks == null || tracks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tracks to export')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export as CSV'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final file = await ExportService.exportToCSV(tracks);
                  await Share.shareXFiles([XFile(file.path)],
                      text: 'Tracks export');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('CSV exported successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Export failed: $e')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export as PDF'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  // Calculate statistics
                  final totalTracks = tracks.length;
                  final favoriteTracks = tracks.where((t) => t.isFavorite).length;
                  final totalDuration = tracks.fold<int>(
                    0,
                    (sum, track) => sum + track.duration,
                  );
                  final avgDuration = totalDuration / totalTracks;
                  
                  // Group by artist
                  final artistCounts = <String, int>{};
                  for (final track in tracks) {
                    artistCounts[track.artist] = (artistCounts[track.artist] ?? 0) + 1;
                  }
                  final topArtists = artistCounts.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));
                  
                  final file = await ExportService.exportStatisticsToPDF(
                    totalTracks: totalTracks,
                    favoriteTracks: favoriteTracks,
                    totalDuration: totalDuration,
                    avgDuration: avgDuration,
                    topArtists: topArtists,
                  );
                  
                  // Show PDF preview
                  if (context.mounted) {
                    await Printing.layoutPdf(
                      onLayout: (format) async {
                        return await file.readAsBytes();
                      },
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Export failed: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
