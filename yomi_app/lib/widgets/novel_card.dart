import 'package:flutter/material.dart';
import '../models/novel.dart';
import '../theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NovelCard extends StatelessWidget {
  final Novel novel;
  final VoidCallback onTap;
  final String? progressLabel;

  const NovelCard({
    super.key,
    required this.novel,
    required this.onTap,
    this.progressLabel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Cover Image
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: novel.coverUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppTheme.cardBackground,
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppTheme.cardBackground,
                  child: const Icon(Icons.book, size: 50, color: AppTheme.secondaryTextColor),
                ),
              ),
            ),
            
            // Title Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black87,
                    ],
                  ),
                ),
              ),
            ),

            // Title Text
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                novel.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),

            // Progress Badge (Tachiyomi-style)
            if (progressLabel != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    progressLabel!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
