import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/reporting_service.dart';
import '../../../../core/services/export_service.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

/// Reporting screen with time-based reports
class ReportingScreen extends ConsumerStatefulWidget {
  const ReportingScreen({super.key});

  @override
  ConsumerState<ReportingScreen> createState() => _ReportingScreenState();
}

class _ReportingScreenState extends ConsumerState<ReportingScreen> {
  ReportPeriod _selectedPeriod = ReportPeriod.weekly;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  ReportData? _currentReport;
  ReportData? _compareReport;
  bool _isLoading = false;

  final ReportingService _reportingService = ReportingService();

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    try {
      final report = await _reportingService.generateReport(
        _selectedPeriod,
        customStart: _customStartDate,
        customEnd: _customEndDate,
      );
      setState(() {
        _currentReport = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading report: $e')),
        );
      }
    }
  }

  Future<void> _loadCompareReport() async {
    if (_currentReport == null) return;

    DateTime compareStart;
    final compareEnd = _currentReport!.startDate;

    switch (_selectedPeriod) {
      case ReportPeriod.daily:
        compareStart = compareEnd.subtract(const Duration(days: 1));
        break;
      case ReportPeriod.weekly:
        compareStart = compareEnd.subtract(const Duration(days: 7));
        break;
      case ReportPeriod.monthly:
        compareStart = DateTime(
          compareEnd.year,
          compareEnd.month - 1,
          compareEnd.day,
        );
        break;
      case ReportPeriod.custom:
        final duration = _currentReport!.endDate.difference(_currentReport!.startDate);
        compareStart = compareEnd.subtract(duration);
        break;
    }

    try {
      final report = await _reportingService.generateReport(
        ReportPeriod.custom,
        customStart: compareStart,
        customEnd: compareEnd,
      );
      setState(() => _compareReport = report);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading compare report: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _currentReport != null ? _exportReport : null,
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: Column(
        children: [
          // Period selector
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Report Period'),
                  const SizedBox(height: 8),
                  SegmentedButton<ReportPeriod>(
                    segments: const [
                      ButtonSegment(
                        value: ReportPeriod.daily,
                        label: Text('Daily'),
                      ),
                      ButtonSegment(
                        value: ReportPeriod.weekly,
                        label: Text('Weekly'),
                      ),
                      ButtonSegment(
                        value: ReportPeriod.monthly,
                        label: Text('Monthly'),
                      ),
                      ButtonSegment(
                        value: ReportPeriod.custom,
                        label: Text('Custom'),
                      ),
                    ],
                    selected: {_selectedPeriod},
                    onSelectionChanged: (Set<ReportPeriod> newSelection) {
                      setState(() {
                        _selectedPeriod = newSelection.first;
                      });
                      _loadReport();
                    },
                  ),
                  if (_selectedPeriod == ReportPeriod.custom) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _customStartDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() => _customStartDate = picked);
                                _loadReport();
                              }
                            },
                            child: Text(_customStartDate == null
                                ? 'Start Date'
                                : DateFormat('yyyy-MM-dd').format(_customStartDate!)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _customEndDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() => _customEndDate = picked);
                                _loadReport();
                              }
                            },
                            child: Text(_customEndDate == null
                                ? 'End Date'
                                : DateFormat('yyyy-MM-dd').format(_customEndDate!)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Report content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _currentReport == null
                    ? const Center(child: Text('No report data'))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSummaryCards(),
                            const SizedBox(height: 24),
                            _buildActionsTable(),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _compareReport == null
                                  ? _loadCompareReport
                                  : null,
                              child: const Text('Compare with Previous Period'),
                            ),
                            if (_compareReport != null) ...[
                              const SizedBox(height: 24),
                              _buildComparison(),
                            ],
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    if (_currentReport == null) return const SizedBox();

    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('Tracks Added'),
                  const SizedBox(height: 8),
                  Text(
                    '${_currentReport!.tracksAdded}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('Favorites'),
                  const SizedBox(height: 8),
                  Text(
                    '${_currentReport!.favoritesAdded}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('Workflow Transitions'),
                  const SizedBox(height: 8),
                  Text(
                    '${_currentReport!.workflowTransitions}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionsTable() {
    if (_currentReport == null) return const SizedBox();

    return Card(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Action Type')),
          DataColumn(label: Text('Count'), numeric: true),
        ],
        rows: _currentReport!.actionsByType.entries.map((entry) {
          return DataRow(
            cells: [
              DataCell(Text(entry.key)),
              DataCell(Text(entry.value.toString())),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildComparison() {
    if (_currentReport == null || _compareReport == null) return const SizedBox();

    final comparison = _reportingService.compareReports(
      _compareReport!,
      _currentReport!,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comparison with Previous Period',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildComparisonRow(
              'Tracks Added',
              comparison['tracksAddedChange'] as int,
              comparison['tracksAddedPercentChange'] as double,
            ),
            _buildComparisonRow(
              'Favorites',
              comparison['favoritesChange'] as int,
              null,
            ),
            _buildComparisonRow(
              'Workflow Transitions',
              comparison['workflowTransitionsChange'] as int,
              null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(String label, int change, double? percentChange) {
    final isPositive = change >= 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositive ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                '${isPositive ? '+' : ''}$change',
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (percentChange != null) ...[
                const SizedBox(width: 8),
                Text(
                  '(${percentChange.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportReport() async {
    if (_currentReport == null) return;

    try {
      final file = await ExportService.exportStatisticsToPDF(
        totalTracks: _currentReport!.totalTracks,
        favoriteTracks: _currentReport!.favoritesAdded,
        totalDuration: 0, // Would need to calculate
        avgDuration: 0, // Would need to calculate
        topArtists: [], // Would need to calculate
      );
      await Share.shareXFiles([XFile(file.path)], text: 'Report export');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }
}
