import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/library_provider.dart';
import '../services/api_service.dart';
import '../widgets/novel_card.dart';
import '../models/novel.dart';
import 'novel_detail_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryProvider = Provider.of<LibraryProvider>(context);
    final apiService = ApiService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Implement settings
            },
          ),
        ],
      ),
      body: libraryProvider.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : libraryProvider.libraryEntries.isEmpty
              ? _buildEmptyState(context)
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.7,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: libraryProvider.libraryEntries.length,
                  itemBuilder: (context, index) {
                    final entry = libraryProvider.libraryEntries[index];
                    return FutureBuilder<Novel>(
                      future: apiService.getNovel(entry.novelId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Card(child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
                        }
                        final novel = snapshot.data!;
                        return NovelCard(
                          novel: novel,
                          progressLabel: 'Ch. ${entry.lastChapterRead}',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NovelDetailScreen(novel: novel),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.library_books_outlined, size: 80, color: Colors.grey[800]),
          const SizedBox(height: 16),
          Text(
            'Your library is empty',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text('Go to Browse to add novels!'),
        ],
      ),
    );
  }
}
