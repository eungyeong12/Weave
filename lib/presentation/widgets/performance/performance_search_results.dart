import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weave/di/injector.dart';
import 'package:weave/presentation/widgets/book/book_search_loading_state.dart';
import 'package:weave/presentation/widgets/book/book_search_error_state.dart';
import 'package:weave/presentation/widgets/book/book_search_empty_state.dart';
import 'package:weave/presentation/widgets/performance/performance_search_results_list.dart';

class PerformanceSearchResults extends ConsumerWidget {
  final TextEditingController searchController;
  final String Function(String) getProxiedImageUrl;

  const PerformanceSearchResults({
    super.key,
    required this.searchController,
    required this.getProxiedImageUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(performanceSearchViewModelProvider);

    if (state.isLoading) {
      return const BookSearchLoadingState();
    }

    if (state.error != null) {
      return BookSearchErrorState(error: state.error!);
    }

    if (searchController.text.trim().isEmpty) {
      return const BookSearchEmptyState(message: '공연·전시 제목을 검색해보세요');
    }

    if (state.performances.isEmpty) {
      return const BookSearchEmptyState(message: '검색 결과가 없습니다');
    }

    return PerformanceSearchResultsList(
      performances: state.performances,
      getProxiedImageUrl: getProxiedImageUrl,
    );
  }
}
