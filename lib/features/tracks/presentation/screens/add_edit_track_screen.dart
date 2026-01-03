import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:record/record.dart';
import '../../../../data/models/music_track_model.dart';
import '../../../../data/repositories/track_repository.dart';
import '../providers/track_providers.dart';
import '../../audio/presentation/services/audio_recording_service.dart';
import '../widgets/loading_widget.dart';
import 'dart:io';

/// Screen to add or edit a track
class AddEditTrackScreen extends ConsumerStatefulWidget {
  final int? trackId;

  const AddEditTrackScreen({super.key, this.trackId});

  @override
  ConsumerState<AddEditTrackScreen> createState() => _AddEditTrackScreenState();
}

class _AddEditTrackScreenState extends ConsumerState<AddEditTrackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _durationController = TextEditingController();
  final _filePathController = TextEditingController();

  final AudioRecordingService _recordingService = AudioRecordingService();
  bool _isRecording = false;
  String? _recordingPath;
  int? _recordedDuration;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.trackId != null) {
      _loadTrack();
    }
  }

  Future<void> _loadTrack() async {
    setState(() => _isLoading = true);
    try {
      final repository = ref.read(trackRepositoryProvider);
      final track = await repository.getTrackById(widget.trackId!);
      if (track != null && mounted) {
        _titleController.text = track.title;
        _artistController.text = track.artist;
        _durationController.text = track.duration.toString();
        _filePathController.text = track.filePath;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading track: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      final path = await _recordingService.startRecording();
      if (path != null && mounted) {
        setState(() {
          _isRecording = true;
          _recordingPath = path;
          _recordedDuration = 0;
        });

        // Update duration every second
        _updateRecordingDuration();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting recording: $e')),
        );
      }
    }
  }

  void _updateRecordingDuration() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRecording && mounted) {
        setState(() {
          _recordedDuration = (_recordedDuration ?? 0) + 1;
        });
        _updateRecordingDuration();
      }
    });
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recordingService.stopRecording();
      if (path != null && mounted) {
        setState(() {
          _isRecording = false;
          _filePathController.text = path;
          if (_recordedDuration != null) {
            _durationController.text = _recordedDuration.toString();
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error stopping recording: $e')),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    // In a real app, you would use file_picker package
    // For now, we'll just show a dialog to enter file path manually
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter File Path'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '/path/to/audio/file.mp3',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _filePathController.text = result;
      });
    }
  }

  Future<void> _saveTrack() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final artist = _artistController.text.trim();
    final duration = int.tryParse(_durationController.text.trim());
    final filePath = _filePathController.text.trim();

    if (duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid duration in seconds')),
      );
      return;
    }

    if (filePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or record an audio file')),
      );
      return;
    }

    // Check if file exists (for non-recorded files)
    if (!_isRecording && 
        _recordingPath != null && 
        filePath != _recordingPath && 
        !File(filePath).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File does not exist. Please check the path.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final track = MusicTrack(
        id: widget.trackId,
        title: title,
        artist: artist,
        duration: duration,
        filePath: filePath,
        createdAt: widget.trackId != null
            ? DateTime.now() // Keep original date when editing
            : DateTime.now(),
      );

      if (widget.trackId != null) {
        await ref.read(trackActionsProvider).updateTrack(track);
      } else {
        await ref.read(trackActionsProvider).addTrack(track);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.trackId != null
                  ? 'Track updated successfully'
                  : 'Track added successfully',
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving track: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _durationController.dispose();
    _filePathController.dispose();
    _recordingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && widget.trackId != null) {
      return const Scaffold(
        body: LoadingWidget(message: 'Loading track...'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trackId != null ? 'Edit Track' : 'Add Track'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  hintText: 'Enter track title',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _artistController,
                decoration: const InputDecoration(
                  labelText: 'Artist *',
                  hintText: 'Enter artist name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Artist is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (seconds) *',
                  hintText: 'Enter duration in seconds',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Duration is required';
                  }
                  final duration = int.tryParse(value.trim());
                  if (duration == null || duration <= 0) {
                    return 'Please enter a valid duration';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _filePathController,
                decoration: const InputDecoration(
                  labelText: 'File Path *',
                  hintText: 'Select or record audio file',
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'File path is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isRecording ? null : _pickFile,
                      icon: const Icon(Icons.folder_open),
                      label: const Text('Select File'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isRecording ? _stopRecording : _startRecording,
                      icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                      label: Text(_isRecording ? 'Stop Recording' : 'Record'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRecording ? Colors.red : null,
                      ),
                    ),
                  ),
                ],
              ),
              if (_isRecording && _recordedDuration != null) ...[
                const SizedBox(height: 16),
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.fiber_manual_record, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          'Recording: ${_formatDuration(_recordedDuration!)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveTrack,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.trackId != null ? 'Update Track' : 'Add Track'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
