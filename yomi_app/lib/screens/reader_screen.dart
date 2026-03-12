import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/novel.dart';
import '../models/chapter.dart';
import '../providers/library_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class ReaderScreen extends StatefulWidget {
  final Novel novel;
  final Chapter chapter;
  final List<Chapter> allChapters;

  const ReaderScreen({
    super.key,
    required this.novel,
    required this.chapter,
    required this.allChapters,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late Chapter _currentChapter;
  double _fontSize = 18.0;

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.chapter;
    _updateProgress();
  }

  void _updateProgress() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final libraryProvider = Provider.of<LibraryProvider>(context, listen: false);
    
    if (libraryProvider.isInLibrary(widget.novel.id)) {
      libraryProvider.updateProgress(
        authProvider.user!.uid,
        widget.novel.id,
        _currentChapter.chapterNumber,
      );
    }
  }

  void _navigateToChapter(int increment) {
    final nextIndex = widget.allChapters.indexWhere((c) => c.chapterNumber == _currentChapter.chapterNumber) + increment;
    
    if (nextIndex >= 0 && nextIndex < widget.allChapters.length) {
      setState(() {
        _currentChapter = widget.allChapters[nextIndex];
      });
      _updateProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chapter ${_currentChapter.chapterNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => StatefulBuilder(
                  builder: (context, setModalState) => Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Font Size'),
                        Slider(
                          value: _fontSize,
                          min: 12,
                          max: 30,
                          onChanged: (val) {
                            setModalState(() => _fontSize = val);
                            setState(() => _fontSize = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: SelectableText(
                _currentChapter.content.replaceAll(r'\n', '\n'),
                style: TextStyle(
                  fontSize: _fontSize,
                  height: 1.6,
                  color: AppTheme.textColor,
                ),
              ),
            ),
          ),
          
          // Navigation Bottom Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: AppTheme.cardBackground,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: widget.allChapters.first.chapterNumber == _currentChapter.chapterNumber 
                      ? null : () => _navigateToChapter(-1),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Prev'),
                ),
                Text(
                  '${_currentChapter.chapterNumber} / ${widget.novel.totalChapters}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: widget.allChapters.last.chapterNumber == _currentChapter.chapterNumber 
                      ? null : () => _navigateToChapter(1),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
