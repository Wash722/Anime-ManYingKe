import 'package:flutter/material.dart';
import '../models/anime_model.dart';

class AnimeCard extends StatelessWidget {
  final AnimeModel anime;
  final double? width;
  final VoidCallback? onTap;

  const AnimeCard({
    super.key, 
    required this.anime, 
    this.width,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  anime.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              anime.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}