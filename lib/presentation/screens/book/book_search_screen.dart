import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:weave/di/injector.dart';
import 'package:weave/presentation/widgets/book/book_search_bar.dart';
import 'package:weave/presentation/widgets/book/book_search_loading_state.dart';
import 'package:weave/presentation/widgets/book/book_search_error_state.dart';
import 'package:weave/presentation/widgets/book/book_search_empty_state.dart';
import 'package:weave/presentation/widgets/book/book_search_results_list.dart';

class BookSearchScreen extends ConsumerStatefulWidget {
  const BookSearchScreen({super.key});

  @override
  ConsumerState<BookSearchScreen> createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends ConsumerState<BookSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String value) {
    print('🔍 _onSearchSubmitted 호출됨: $value');
    if (value.trim().isNotEmpty) {
      print('📚 searchBooks 호출 시작');
      ref.read(bookSearchViewModelProvider.notifier).searchBooks(value);
      _searchFocusNode.unfocus();
    } else {
      print('🗑️ clearSearch 호출');
      ref.read(bookSearchViewModelProvider.notifier).clearSearch();
    }
  }

  // 이미지 프록시 URL 생성
  String _getProxiedImageUrl(String originalUrl) {
    try {
      final projectId = Firebase.app().options.projectId;
      final encodedUrl = Uri.encodeComponent(originalUrl);
      return 'https://us-central1-$projectId.cloudfunctions.net/proxyImage?url=$encodedUrl';
    } catch (e) {
      // Firebase 초기화 실패 시 원본 URL 반환
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
          '도서 검색',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // 검색바 외부를 클릭하면 포커스 해제
          _searchFocusNode.unfocus();
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            // 검색 바
            BookSearchBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onSubmitted: _onSearchSubmitted,
              onClear: () {
                setState(() {
                  _searchController.clear();
                });
              },
            ),
            // 검색 결과 영역
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
                child: Consumer(
                  builder: (context, ref, _) {
                    final state = ref.watch(bookSearchViewModelProvider);

                    if (state.isLoading) {
                      return const BookSearchLoadingState();
                    }

                    if (state.error != null) {
                      return BookSearchErrorState(error: state.error!);
                    }

                    if (_searchController.text.trim().isEmpty) {
                      return const BookSearchEmptyState(
                        message: '도서 제목을 검색해보세요',
                      );
                    }

                    if (state.books.isEmpty) {
                      return const BookSearchEmptyState(message: '검색 결과가 없습니다');
                    }

                    return BookSearchResultsList(
                      books: state.books,
                      getProxiedImageUrl: _getProxiedImageUrl,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
