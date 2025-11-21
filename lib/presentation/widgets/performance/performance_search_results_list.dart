import 'package:flutter/material.dart';
import 'package:weave/domain/entities/performance/performance.dart';
import 'package:weave/presentation/widgets/performance/performance_item.dart';

class PerformanceSearchResultsList extends StatelessWidget {
  final List<Performance> performances;
  final String Function(String) getProxiedImageUrl;

  const PerformanceSearchResultsList({
    super.key,
    required this.performances,
    required this.getProxiedImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: performances.length,
      itemBuilder: (context, index) {
        final performance = performances[index];
        return PerformanceItem(
          performance: performance,
          getProxiedImageUrl: getProxiedImageUrl,
        );
      },
    );
  }
}
