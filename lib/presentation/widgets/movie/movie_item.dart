import 'package:flutter/material.dart';
import 'package:weave/domain/entities/movie/movie.dart';

class MovieItem extends StatelessWidget {
  final Movie movie;
  final String Function(String) getProxiedImageUrl;
  final VoidCallback? onTap;

  const MovieItem({
    super.key,
    required this.movie,
    required this.getProxiedImageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 포스터 이미지
            if (movie.posterPath != null && movie.posterPath!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  getProxiedImageUrl(movie.posterPath!),
                  width: 60,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 80,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.movie, color: Colors.grey),
                    );
                  },
                ),
              )
            else
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.movie, color: Colors.grey),
              ),
            const SizedBox(width: 12),
            // 영화 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (movie.releaseDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      movie.releaseDate!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                  if (movie.voteAverage != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '평점: ${movie.voteAverage!.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
