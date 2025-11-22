import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:weave/domain/entities/record/record.dart';
import 'package:weave/domain/entities/diary/diary.dart';
import 'package:weave/presentation/widgets/search/search_bar.dart';
import 'package:weave/presentation/widgets/gallery/month_picker_bottom_sheet.dart';

class GalleryWidget extends StatefulWidget {
  final List<Record> records;
  final List<Diary> diaries;
  final bool isLoading;
  final VoidCallback onRefresh;
  final DateTime currentMonth;
  final Function(DateTime) onMonthChanged;
  final ValueChanged<String>? onSearchQueryChanged;

  const GalleryWidget({
    super.key,
    required this.records,
    required this.diaries,
    this.isLoading = false,
    required this.onRefresh,
    required this.currentMonth,
    required this.onMonthChanged,
    this.onSearchQueryChanged,
  });

  @override
  State<GalleryWidget> createState() => _GalleryWidgetState();
}

class _GalleryWidgetState extends State<GalleryWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        widget.onSearchQueryChanged?.call(_searchQuery);
      });
    });
  }

  Future<void> _selectMonth() async {
    final DateTime? picked = await MonthPickerBottomSheet.show(
      context,
      widget.currentMonth,
    );

    if (picked != null) {
      widget.onMonthChanged(picked);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _onSearchClear() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      widget.onSearchQueryChanged?.call(_searchQuery);
    });
  }

  // Record 검색 필터링
  List<Record> get _filteredRecords {
    if (_searchQuery.isEmpty) {
      return widget.records;
    }
    final query = _searchQuery.toLowerCase().trim();
    if (query.isEmpty) {
      return widget.records;
    }
    return widget.records.where((record) {
      final titleMatch = record.title.toLowerCase().contains(query);
      final contentMatch = record.content.toLowerCase().contains(query);
      final dateMatch = _formatDate(record.date).contains(query);
      return titleMatch || contentMatch || dateMatch;
    }).toList();
  }

  // Diary 검색 필터링
  List<Diary> get _filteredDiaries {
    if (_searchQuery.isEmpty) {
      return widget.diaries;
    }
    final query = _searchQuery.toLowerCase().trim();
    if (query.isEmpty) {
      return widget.diaries;
    }
    return widget.diaries.where((diary) {
      final contentMatch =
          diary.content.isNotEmpty &&
          diary.content.toLowerCase().contains(query);
      final dateMatch = _formatDate(diary.date).contains(query);
      return contentMatch || dateMatch;
    }).toList();
  }

  // Record와 Diary를 동시에 검색하여 합친 결과 반환
  List<dynamic> get _allItems {
    final allItems = <dynamic>[];
    // Record 검색 결과 추가
    allItems.addAll(_filteredRecords);
    // Diary 검색 결과 추가
    allItems.addAll(_filteredDiaries);
    // 날짜순으로 정렬 (최신순)
    allItems.sort((a, b) {
      final dateA = a is Record ? a.date : (a as Diary).date;
      final dateB = b is Record ? b.date : (b as Diary).date;
      return dateB.compareTo(dateA);
    });
    return allItems;
  }

  String _getProxiedImageUrl(String originalUrl) {
    try {
      final projectId = Firebase.app().options.projectId;
      final encodedUrl = Uri.encodeComponent(originalUrl);
      return 'https://us-central1-$projectId.cloudfunctions.net/proxyImage?url=$encodedUrl';
    } catch (e) {
      return originalUrl;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'book':
        return Icons.book;
      case 'movie':
        return Icons.movie;
      case 'performance':
        return Icons.theater_comedy;
      default:
        return Icons.article;
    }
  }

  String _formatDate(DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year.$month.$day';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          if (_searchQuery.isNotEmpty) {
            // 검색 상태에서 뒤로가기를 누르면 검색 초기화 및 포커스 해제
            _searchController.clear();
            _searchFocusNode.unfocus();
            setState(() {
              _searchQuery = '';
              widget.onSearchQueryChanged?.call(_searchQuery);
            });
            // 검색 초기화 후에도 뒤로가기를 차단하기 위해 아무것도 하지 않음
            return;
          }
          // 검색어가 없을 때만 부모의 PopScope로 전달 (앱 종료)
          // 하지만 GalleryWidget은 TabBarView 안에 있으므로 Navigator.pop()을 호출하지 않음
          // 대신 아무것도 하지 않으면 HomeScreen의 PopScope가 처리함
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () {
            // 검색바 이외의 공간을 클릭하면 포커스 해제
            FocusScope.of(context).unfocus();
          },
          child: SafeArea(
            child: Column(
              children: [
                // 년도와 월 헤더
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _selectMonth,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${widget.currentMonth.year}년 ${widget.currentMonth.month}월',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (widget.isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),
                // 검색바
                SearchTextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onSubmitted: _onSearchSubmitted,
                  onClear: _onSearchClear,
                  hintText: '검색',
                ),
                // 갤러리 그리드
                Expanded(
                  child:
                      widget.isLoading &&
                          widget.records.isEmpty &&
                          widget.diaries.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : _allItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _searchQuery.isEmpty
                                    ? '기록이 없습니다'
                                    : '검색 결과가 없습니다',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            widget.onRefresh();
                          },
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.75,
                                ),
                            itemCount: _allItems.length,
                            itemBuilder: (context, index) {
                              final item = _allItems[index];
                              if (item is Record) {
                                return _GalleryItem(
                                  record: item,
                                  getProxiedImageUrl: _getProxiedImageUrl,
                                  getTypeIcon: _getTypeIcon,
                                  formatDate: _formatDate,
                                );
                              } else {
                                return _DiaryGalleryItem(
                                  diary: item as Diary,
                                  getProxiedImageUrl: _getProxiedImageUrl,
                                  formatDate: _formatDate,
                                );
                              }
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryItem extends StatelessWidget {
  final Record record;
  final String Function(String) getProxiedImageUrl;
  final IconData Function(String) getTypeIcon;
  final String Function(DateTime) formatDate;

  const _GalleryItem({
    required this.record,
    required this.getProxiedImageUrl,
    required this.getTypeIcon,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: 상세 화면으로 이동
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 영역
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: record.imageUrl != null && record.imageUrl!.isNotEmpty
                    ? Image.network(
                        getProxiedImageUrl(record.imageUrl!),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: Icon(
                                getTypeIcon(record.type),
                                color: Colors.grey.shade400,
                                size: 32,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Icon(
                            getTypeIcon(record.type),
                            color: Colors.grey.shade400,
                            size: 32,
                          ),
                        ),
                      ),
              ),
            ),
            // 정보 영역
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatDate(record.date),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiaryGalleryItem extends StatelessWidget {
  final Diary diary;
  final String Function(String) getProxiedImageUrl;
  final String Function(DateTime) formatDate;

  const _DiaryGalleryItem({
    required this.diary,
    required this.getProxiedImageUrl,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: 상세 화면으로 이동
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 영역
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: diary.imageUrls.isNotEmpty
                    ? Image.network(
                        getProxiedImageUrl(diary.imageUrls.first),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: Icon(
                                Icons.book,
                                color: Colors.grey.shade400,
                                size: 32,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Icon(
                            Icons.book,
                            color: Colors.grey.shade400,
                            size: 32,
                          ),
                        ),
                      ),
              ),
            ),
            // 정보 영역
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    diary.content,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatDate(diary.date),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
