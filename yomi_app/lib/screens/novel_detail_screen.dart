import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/novel.dart';
import '../models/chapter.dart';
import '../services/firestore_service.dart';
import '../providers/library_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'reader_screen.dart';

class NovelDetailScreen extends StatelessWidget {
  final Novel novel;

  const NovelDetailScreen({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final libraryProvider = Provider.of<LibraryProvider>(context);

    final bool isInLibrary = libraryProvider.isInLibrary(novel.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Tachiyomi-style Header with Image Background
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                novel.title,
                style: const TextStyle(
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: novel.coverUrl,
                    fit: BoxFit.cover,
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

          // Action Buttons and Info
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
                              libraryProvider.removeFromLibrary(authProvider.user!.uid, novel.id);
                            } else {
                              libraryProvider.addToLibrary(authProvider.user!.uid, novel.id);
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
                  Text(novel.synopsis),
                  const SizedBox(height: 24),
                  Text('Chapters', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Chapter List
          StreamBuilder<List<Chapter>>(
            stream: firestoreService.getChapters(novel.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverToBoxAdapter(child: Center(child: Text("No chapters found.")));
              }

              final chapters = snapshot.data!;
              final lastRead = libraryProvider.getProgress(novel.id);

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
                              novel: novel,
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
