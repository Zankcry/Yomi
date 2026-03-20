import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/novel_card.dart';
import '../models/novel.dart';
import 'novel_detail_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Novel>> _novelsFuture;

  @override
  void initState() {
    super.initState();
    _novelsFuture = _apiService.getAllNovels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse'),
      ),
      body: FutureBuilder<List<Novel>>(
        future: _novelsFuture,
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
