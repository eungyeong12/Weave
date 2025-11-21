import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:weave/di/injector.dart';
import 'package:weave/presentation/widgets/search/search_bar.dart';
import 'package:weave/presentation/widgets/performance/performance_search_results.dart';

class PerformanceSearchScreen extends ConsumerStatefulWidget {
  final DateTime? selectedDate;

  const PerformanceSearchScreen({super.key, this.selectedDate});

  @override
  ConsumerState<PerformanceSearchScreen> createState() =>
      _PerformanceSearchScreenState();
}

class _PerformanceSearchScreenState
    extends ConsumerState<PerformanceSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String value) {
    if (value.trim().isNotEmpty) {
      ref
          .read(performanceSearchViewModelProvider.notifier)
          .searchPerformances(value);
      _searchFocusNode.unfocus();
    } else {
      ref.read(performanceSearchViewModelProvider.notifier).clearSearch();
    }
  }

  // 이미지 프록시 URL 생성
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.chevron_left, color: Colors.black),
          ),
        ),
        title: const Text(
          '공연·전시 검색',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          _searchFocusNode.unfocus();
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            // 검색 바
            SearchTextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onSubmitted: _onSearchSubmitted,
              onClear: () {
                setState(() {
                  _searchController.clear();
                });
              },
              hintText: '공연·전시 제목을 입력하세요',
            ),
            // 검색 결과 영역
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
                child: PerformanceSearchResults(
                  searchController: _searchController,
                  getProxiedImageUrl: _getProxiedImageUrl,
                  selectedDate: widget.selectedDate,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
