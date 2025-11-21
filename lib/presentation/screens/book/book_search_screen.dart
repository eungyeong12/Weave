import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:weave/di/injector.dart';
import 'package:weave/domain/entities/book/book.dart';

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
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: SizedBox(
                height: 36,
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: const TextStyle(fontSize: 14),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: '도서 제목을 입력하세요',
                    hintStyle: const TextStyle(fontSize: 14),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF111111),
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: Color(0xFF111111),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Color(0xFFF1F1F1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                  onSubmitted: _onSearchSubmitted,
                  textInputAction: TextInputAction.search,
                ),
              ),
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
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.error != null) {
                      return Center(
                        child: Text(
                          state.error!,
                          style: TextStyle(
                            color: Colors.red.shade400,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    if (_searchController.text.trim().isEmpty) {
                      return Center(
                        child: Text(
                          '도서 제목을 검색해보세요',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    if (state.books.isEmpty) {
                      return Center(
                        child: Text(
                          '검색 결과가 없습니다',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: state.books.length,
                      itemBuilder: (context, index) {
                        final book = state.books[index];
                        return _BookItem(
                          book: book,
                          getProxiedImageUrl: _getProxiedImageUrl,
                        );
                      },
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

class _BookItem extends StatelessWidget {
  final Book book;
  final String Function(String) getProxiedImageUrl;

  const _BookItem({required this.book, required this.getProxiedImageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 책 표지 이미지
          if (book.imageUrl != null && book.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                getProxiedImageUrl(book.imageUrl!),
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
                  print('❌ 이미지 로딩 실패: ${book.imageUrl}');
                  print('오류: $error');
                  return Container(
                    width: 60,
                    height: 80,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.book, color: Colors.grey),
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
              child: const Icon(Icons.book, color: Colors.grey),
            ),
          const SizedBox(width: 12),
          // 책 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  book.author,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (book.publisher != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    book.publisher!,
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
