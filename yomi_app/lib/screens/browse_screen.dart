import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/novel_card.dart';
import '../models/novel.dart';
import 'novel_detail_screen.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse'),
      ),
      body: StreamBuilder<List<Novel>>(
        stream: firestoreService.getAllNovels(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No novels found.'));
          }

          final novels = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: novels.length,
            itemBuilder: (context, index) {
              return NovelCard(
                novel: novels[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NovelDetailScreen(novel: novels[index]),
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
}
