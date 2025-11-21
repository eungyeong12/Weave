import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:weave/di/injector.dart';
import 'package:weave/presentation/widgets/search/search_bar.dart';
import 'package:weave/presentation/widgets/book/book_search_loading_state.dart';
import 'package:weave/presentation/widgets/book/book_search_error_state.dart';
import 'package:weave/presentation/widgets/book/book_search_empty_state.dart';
import 'package:weave/presentation/widgets/movie/movie_search_results_list.dart';

class MovieSearchScreen extends ConsumerStatefulWidget {
  const MovieSearchScreen({super.key});

  @override
  ConsumerState<MovieSearchScreen> createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends ConsumerState<MovieSearchScreen> {
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
      ref.read(movieSearchViewModelProvider.notifier).searchMovies(value);
      _searchFocusNode.unfocus();
    } else {
      ref.read(movieSearchViewModelProvider.notifier).clearSearch();
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
          '영화·드라마 검색',
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
              hintText: '영화·드라마 제목을 입력하세요',
            ),
            // 검색 결과 영역
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
                child: Consumer(
                  builder: (context, ref, _) {
                    final state = ref.watch(movieSearchViewModelProvider);

                    if (state.isLoading) {
                      return const BookSearchLoadingState();
                    }

                    if (state.error != null) {
                      return BookSearchErrorState(error: state.error!);
                    }

                    if (_searchController.text.trim().isEmpty) {
                      return const BookSearchEmptyState(
                        message: '영화·드라마 제목을 검색해보세요',
                      );
                    }

                    if (state.movies.isEmpty) {
                      return const BookSearchEmptyState(message: '검색 결과가 없습니다');
                    }

                    return MovieSearchResultsList(
                      movies: state.movies,
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
