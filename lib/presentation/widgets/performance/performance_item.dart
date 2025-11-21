import 'package:flutter/material.dart';
import 'package:weave/domain/entities/performance/performance.dart';

class PerformanceItem extends StatelessWidget {
  final Performance performance;
  final String Function(String) getProxiedImageUrl;

  const PerformanceItem({
    super.key,
    required this.performance,
    required this.getProxiedImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 포스터 이미지
          if (performance.posterUrl != null &&
              performance.posterUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                getProxiedImageUrl(performance.posterUrl!),
                width: 60,
                height: 80,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 60,
                    height: 80,
                    color: Colors.grey.shade200,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 80,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.theater_comedy, color: Colors.grey),
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
              child: const Icon(Icons.theater_comedy, color: Colors.grey),
            ),
          const SizedBox(width: 12),
          // 공연 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  performance.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (performance.venue != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    performance.venue!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
                if (performance.startDate != null &&
                    performance.endDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${performance.startDate} ~ ${performance.endDate}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ] else if (performance.startDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    performance.startDate!,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
                if (performance.genre != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    performance.genre!,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
