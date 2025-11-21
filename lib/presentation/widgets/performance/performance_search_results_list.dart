import 'package:flutter/material.dart';
import 'package:weave/domain/entities/performance/performance.dart';
import 'package:weave/presentation/widgets/performance/performance_item.dart';
import 'package:weave/presentation/screens/record/record_write_screen.dart';
import 'package:firebase_core/firebase_core.dart';

class PerformanceSearchResultsList extends StatelessWidget {
  final List<Performance> performances;
  final String Function(String) getProxiedImageUrl;
  final DateTime? selectedDate;

  const PerformanceSearchResultsList({
    super.key,
    required this.performances,
    required this.getProxiedImageUrl,
    this.selectedDate,
  });

  String _getProxiedImageUrl(String originalUrl) {
    try {
      final projectId = Firebase.app().options.projectId;
      final encodedUrl = Uri.encodeComponent(originalUrl);
      return 'https://us-central1-$projectId.cloudfunctions.net/proxyImage?url=$encodedUrl';
    } catch (e) {
      return originalUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: performances.length,
      itemBuilder: (context, index) {
        final performance = performances[index];
        return PerformanceItem(
          performance: performance,
          getProxiedImageUrl: getProxiedImageUrl,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecordWriteScreen(
                  type: RecordType.performance,
                  performance: performance,
                  getProxiedImageUrl: _getProxiedImageUrl,
                  selectedDate: selectedDate ?? DateTime.now(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
