import 'package:flutter/material.dart';
import 'package:weave/presentation/screens/book/book_search_screen.dart';
import 'package:weave/presentation/screens/movie/movie_search_screen.dart';
import 'package:weave/presentation/screens/performance/performance_search_screen.dart';

class CategoryBottomSheet {
  static void show(
    BuildContext context,
    Function(String) onCategorySelected, {
    DateTime? selectedDate,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 드래그 핸들
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 카테고리 항목들
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    _CategoryItem(
                      title: '도서 기록하기',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BookSearchScreen(selectedDate: selectedDate),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _CategoryItem(
                      title: '영화·드라마 기록하기',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MovieSearchScreen(selectedDate: selectedDate),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _CategoryItem(
                      title: '공연·전시 기록하기',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PerformanceSearchScreen(
                              selectedDate: selectedDate,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _CategoryItem(
                      title: '일상 기록하기',
                      onTap: () {
                        Navigator.pop(context);
                        onCategorySelected('일상');
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _CategoryItem({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
