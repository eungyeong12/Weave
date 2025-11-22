import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weave/domain/entities/book/book.dart';
import 'package:weave/domain/entities/movie/movie.dart';
import 'package:weave/domain/entities/performance/performance.dart';
import 'package:weave/presentation/widgets/record/save_button.dart';
import 'package:weave/presentation/widgets/record/star_rating.dart';
import 'package:weave/presentation/widgets/diary/diary_text_field.dart';
import 'package:weave/presentation/widgets/diary/date_picker_bottom_sheet.dart';
import 'package:weave/di/injector.dart';
import 'package:weave/presentation/screens/home/home_screen.dart';

enum RecordType { book, movie, performance }

class RecordWriteScreen extends ConsumerStatefulWidget {
  final RecordType type;
  final Book? book;
  final Movie? movie;
  final Performance? performance;
  final String Function(String) getProxiedImageUrl;
  final DateTime? selectedDate;

  const RecordWriteScreen({
    super.key,
    required this.type,
    this.book,
    this.movie,
    this.performance,
    required this.getProxiedImageUrl,
    this.selectedDate,
  }) : assert(
         (type == RecordType.book && book != null) ||
             (type == RecordType.movie && movie != null) ||
             (type == RecordType.performance && performance != null),
         '타입에 맞는 데이터가 필요합니다.',
       );

  @override
  ConsumerState<RecordWriteScreen> createState() => _RecordWriteScreenState();
}

class _RecordWriteScreenState extends ConsumerState<RecordWriteScreen> {
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();
  double _rating = 0.0;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  String _getTitle() {
    switch (widget.type) {
      case RecordType.book:
        return widget.book?.title ?? '';
      case RecordType.movie:
        return widget.movie?.title ?? '';
      case RecordType.performance:
        return widget.performance?.title ?? '';
    }
  }

  String? _getImageUrl() {
    switch (widget.type) {
      case RecordType.book:
        return widget.book?.imageUrl;
      case RecordType.movie:
        return widget.movie?.posterPath;
      case RecordType.performance:
        return widget.performance?.posterUrl;
    }
  }

  String _formatDate(DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year.$month.$day';
  }

  List<Widget> _buildInfoWidgets() {
    switch (widget.type) {
      case RecordType.book:
        final book = widget.book!;
        return [
          if (book.author.isNotEmpty) _InfoRow(label: '저자', value: book.author),
          if (book.publisher != null)
            _InfoRow(label: '출판사', value: book.publisher!),
          if (book.pubDate != null)
            _InfoRow(label: '출판일', value: book.pubDate!),
        ];
      case RecordType.movie:
        final movie = widget.movie!;
        return [
          if (movie.releaseDate != null)
            _InfoRow(label: '개봉일', value: movie.releaseDate!),
          if (movie.voteAverage != null)
            _InfoRow(label: '평점', value: movie.voteAverage!.toStringAsFixed(1)),
        ];
      case RecordType.performance:
        final performance = widget.performance!;
        return [
          if (performance.venue != null)
            _InfoRow(label: '공연장', value: performance.venue!),
          if (performance.startDate != null && performance.endDate != null)
            _InfoRow(
              label: '공연기간',
              value: '${performance.startDate} ~ ${performance.endDate}',
            )
          else if (performance.startDate != null)
            _InfoRow(label: '공연일', value: performance.startDate!),
          if (performance.genre != null)
            _InfoRow(label: '장르', value: performance.genre!),
        ];
    }
  }

  Future<void> _save() async {
    if (_contentController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('기록 내용을 입력해주세요.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final authState = ref.read(authViewModelProvider);
    final user = authState.user;

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인이 필요합니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // 타입 문자열 변환
    String typeString;
    switch (widget.type) {
      case RecordType.book:
        typeString = 'book';
        break;
      case RecordType.movie:
        typeString = 'movie';
        break;
      case RecordType.performance:
        typeString = 'performance';
        break;
    }

    // 메타데이터 생성
    Map<String, dynamic> metadata = {};
    switch (widget.type) {
      case RecordType.book:
        final book = widget.book!;
        metadata = {
          'author': book.author,
          'publisher': book.publisher,
          'pubDate': book.pubDate,
          'isbn': book.isbn,
        };
        break;
      case RecordType.movie:
        final movie = widget.movie!;
        metadata = {
          'releaseDate': movie.releaseDate,
          'voteAverage': movie.voteAverage,
          'id': movie.id,
        };
        break;
      case RecordType.performance:
        final performance = widget.performance!;
        metadata = {
          'venue': performance.venue,
          'startDate': performance.startDate,
          'endDate': performance.endDate,
          'genre': performance.genre,
          'id': performance.id,
        };
        break;
    }

    final viewModel = ref.read(recordWriteViewModelProvider.notifier);

    await viewModel.saveRecord(
      userId: user.uid,
      type: typeString,
      date: _selectedDate,
      title: _getTitle(),
      imageUrl: _getImageUrl(),
      content: _contentController.text,
      rating: _rating,
      metadata: metadata,
    );

    final state = ref.read(recordWriteViewModelProvider);

    if (!mounted) return;

    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error!),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // 저장 성공 시 홈 화면으로 이동
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('기록이 저장되었습니다.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getImageUrl();
    final title = _getTitle();

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
        title: GestureDetector(
          onTap: () async {
            final DateTime? picked = await DatePickerBottomSheet.show(
              context,
              _selectedDate,
            );
            if (picked != null) {
              setState(() {
                _selectedDate = picked;
              });
            }
          },
          child: Text(
            _formatDate(_selectedDate),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final state = ref.watch(recordWriteViewModelProvider);
              return SaveButton(
                onSave: _save,
                isContentEmpty: _contentController.text.trim().isEmpty,
                isLoading: state.isLoading,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            _contentFocusNode.unfocus();
          },
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 아이템 정보 섹션
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이미지
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.getProxiedImageUrl(imageUrl),
                            width: 80,
                            height: 112,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 112,
                                color: Colors.grey.shade200,
                                child: Icon(
                                  widget.type == RecordType.book
                                      ? Icons.book
                                      : widget.type == RecordType.movie
                                      ? Icons.movie
                                      : Icons.theater_comedy,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Container(
                          width: 80,
                          height: 112,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            widget.type == RecordType.book
                                ? Icons.book
                                : widget.type == RecordType.movie
                                ? Icons.movie
                                : Icons.theater_comedy,
                            color: Colors.grey,
                            size: 24,
                          ),
                        ),
                      const SizedBox(width: 12),
                      // 정보
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            ..._buildInfoWidgets(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // 별점 영역
                Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    bottom: 12,
                  ),
                  child: Row(
                    children: [
                      StarRating(
                        rating: _rating,
                        onRatingChanged: (rating) {
                          setState(() {
                            _rating = rating;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                // 기록 내용 입력 영역
                DiaryTextField(
                  controller: _contentController,
                  focusNode: _contentFocusNode,
                  onChanged: (_) => setState(() {}),
                  minHeight: 400,
                  hintText: '어떤 생각이 들었나요?',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
