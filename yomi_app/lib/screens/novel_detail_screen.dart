import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/novel.dart';
import '../models/chapter.dart';
import '../services/api_service.dart';
import '../providers/library_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'reader_screen.dart';

class NovelDetailScreen extends StatefulWidget {
  final Novel novel;

  const NovelDetailScreen({super.key, required this.novel});

  @override
  State<NovelDetailScreen> createState() => _NovelDetailScreenState();
}

class _NovelDetailScreenState extends State<NovelDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Chapter>> _chaptersFuture;

  @override
  void initState() {
    super.initState();
    _chaptersFuture = _apiService.getChapters(widget.novel.id);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final libraryProvider = Provider.of<LibraryProvider>(context);

    final bool isInLibrary = libraryProvider.isInLibrary(widget.novel.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.novel.title,
                style: const TextStyle(
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.novel.coverImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppTheme.cardBackground,
                      child: const Icon(Icons.book, size: 50, color: AppTheme.secondaryTextColor),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (isInLibrary) {
                              libraryProvider.removeFromLibrary(authProvider.user!.id, widget.novel.id);
                            } else {
                              libraryProvider.addToLibrary(authProvider.user!.id, widget.novel.id);
                            }
                          },
                          icon: Icon(isInLibrary ? Icons.delete : Icons.add_to_photos),
                          label: Text(isInLibrary ? 'Remove from Library' : 'Add to Library'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isInLibrary ? Colors.red.withOpacity(0.8) : AppTheme.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Synopsis', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(widget.novel.synopsis),
                  const SizedBox(height: 24),
                  Text('Chapters', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          FutureBuilder<List<Chapter>>(
            future: _chaptersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return SliverToBoxAdapter(child: Center(child: Text('Error: ${snapshot.error}')));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverToBoxAdapter(child: Center(child: Text("No chapters found.")));
              }

              final chapters = snapshot.data!;
              final lastRead = libraryProvider.getProgress(widget.novel.id);

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final chapter = chapters[index];
                    final bool isRead = chapter.chapterNumber <= lastRead;

                    return ListTile(
                      title: Text(
                        'Chapter ${chapter.chapterNumber}: ${chapter.title}',
                        style: TextStyle(
                          color: isRead ? Colors.grey : Colors.white,
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      trailing: isRead ? const Icon(Icons.check_circle, color: Colors.green, size: 16) : null,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReaderScreen(
                              novel: widget.novel,
                              chapter: chapter,
                              allChapters: chapters,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: chapters.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
