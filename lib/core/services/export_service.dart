import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../data/models/music_track_model.dart';

/// Service to export data to CSV and PDF
class ExportService {
  /// Export tracks to CSV
  static Future<File> exportToCSV(List<MusicTrack> tracks) async {
    final List<List<dynamic>> rows = [
      ['ID', 'Title', 'Artist', 'Duration (s)', 'Duration (MM:SS)', 'File Path', 'Created At', 'Is Favorite'],
    ];

    for (final track in tracks) {
      rows.add([
        track.id ?? '',
        track.title,
        track.artist,
        track.duration,
        track.formattedDuration,
        track.filePath,
        DateFormat('yyyy-MM-dd HH:mm:ss').format(track.createdAt),
        track.isFavorite ? 'Yes' : 'No',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/tracks_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv);
    return file;
  }

  /// Export tracks to PDF
  static Future<File> exportToPDF(List<MusicTrack> tracks, {String? title}) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                title ?? 'Music Tracks Export',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Generated: ${dateFormat.format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Total Tracks: ${tracks.length}',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Title', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Artist', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Duration', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Created', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Favorite', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                ...tracks.map((track) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(track.title, style: const pw.TextStyle(fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(track.artist, style: const pw.TextStyle(fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(track.formattedDuration, style: const pw.TextStyle(fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        dateFormat.format(track.createdAt),
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        track.isFavorite ? 'Yes' : 'No',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ];
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/tracks_export_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// Export statistics to PDF
  static Future<File> exportStatisticsToPDF({
    required int totalTracks,
    required int favoriteTracks,
    required int totalDuration,
    required double avgDuration,
    required List<MapEntry<String, int>> topArtists,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Music Player Statistics',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Generated: ${dateFormat.format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 30),
            pw.Text(
              'Summary',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Total Tracks: $totalTracks'),
            pw.SizedBox(height: 5),
            pw.Text('Favorite Tracks: $favoriteTracks'),
            pw.SizedBox(height: 5),
            pw.Text('Total Duration: ${_formatDuration(totalDuration)}'),
            pw.SizedBox(height: 5),
            pw.Text('Average Duration: ${_formatDuration(avgDuration.toInt())}'),
            pw.SizedBox(height: 30),
            pw.Text(
              'Top Artists',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Artist', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Tracks', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                ...topArtists.map((entry) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(entry.key, style: const pw.TextStyle(fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(entry.value.toString(), style: const pw.TextStyle(fontSize: 10)),
                    ),
                  ],
                )),
              ],
            ),
          ];
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/statistics_export_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }
}
