import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weave/domain/entities/book/book.dart';
import 'package:weave/domain/entities/movie/movie.dart';
import 'package:weave/domain/entities/performance/performance.dart';
import 'package:weave/presentation/widgets/record/star_rating.dart';
import 'package:weave/presentation/widgets/diary/diary_text_field.dart';
import 'package:weave/presentation/widgets/common/write_screen_app_bar.dart';
import 'package:weave/di/injector.dart';
import 'package:weave/presentation/screens/home/home_screen.dart';
import 'package:weave/domain/entities/record/record.dart';

enum RecordType { book, movie, performance }

class RecordWriteScreen extends ConsumerStatefulWidget {
  final RecordType type;
  final Book? book;
  final Movie? movie;
  final Performance? performance;
  final String Function(String) getProxiedImageUrl;
  final DateTime? selectedDate;
  final Record? record; // 수정 모드일 때 기존 기록 데이터

  const RecordWriteScreen({
    super.key,
    required this.type,
    this.book,
    this.movie,
    this.performance,
    required this.getProxiedImageUrl,
    this.selectedDate,
    this.record,
  }) : assert(
         record != null ||
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
    _selectedDate =
        widget.record?.date ?? widget.selectedDate ?? DateTime.now();
    // 수정 모드일 때 기존 데이터 로드
    if (widget.record != null) {
      _contentController.text = widget.record!.content;
      _rating = widget.record!.rating;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  String _getTitle() {
    // 수정 모드일 때는 Record의 title 사용
    if (widget.record != null) {
      return widget.record!.title;
    }
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
    // 수정 모드일 때는 Record의 imageUrl 사용
    if (widget.record != null) {
      return widget.record!.imageUrl;
    }
    switch (widget.type) {
      case RecordType.book:
        return widget.book?.imageUrl;
      case RecordType.movie:
        return widget.movie?.posterPath;
      case RecordType.performance:
        return widget.performance?.posterUrl;
    }
  }

  String _formatPubDate(String pubDate) {
    // '20230714' 형식을 '2024.07.14' 형식으로 변환
    if (pubDate.length == 8) {
      final year = pubDate.substring(0, 4);
      final month = pubDate.substring(4, 6);
      final day = pubDate.substring(6, 8);
      return '$year.$month.$day';
    }
    return pubDate;
  }

  List<Widget> _buildInfoWidgets() {
    // 수정 모드일 때는 Record의 metadata 사용
    if (widget.record != null && widget.record!.metadata != null) {
      final metadata = widget.record!.metadata!;
      final widgets = <Widget>[];
      switch (widget.record!.type) {
        case 'book':
          if (metadata['author'] != null &&
              metadata['author'].toString().isNotEmpty) {
            widgets.add(
              _InfoRow(label: '저자', value: metadata['author'].toString()),
            );
          }
          if (metadata['publisher'] != null &&
              metadata['publisher'].toString().isNotEmpty) {
            widgets.add(
              _InfoRow(label: '출판사', value: metadata['publisher'].toString()),
            );
          }
          if (metadata['pubDate'] != null &&
              metadata['pubDate'].toString().isNotEmpty) {
            widgets.add(
              _InfoRow(
                label: '출판일',
                value: _formatPubDate(metadata['pubDate'].toString()),
              ),
            );
          }
          break;
        case 'movie':
          if (metadata['releaseDate'] != null &&
              metadata['releaseDate'].toString().isNotEmpty) {
            widgets.add(
              _InfoRow(label: '개봉일', value: metadata['releaseDate'].toString()),
            );
          }
          if (metadata['voteAverage'] != null) {
            widgets.add(
              _InfoRow(label: '평점', value: metadata['voteAverage'].toString()),
            );
          }
          break;
        case 'performance':
          if (metadata['venue'] != null &&
              metadata['venue'].toString().isNotEmpty) {
            widgets.add(
              _InfoRow(label: '공연장', value: metadata['venue'].toString()),
            );
          }
          if (metadata['startDate'] != null && metadata['endDate'] != null) {
            widgets.add(
              _InfoRow(
                label: '공연기간',
                value: '${metadata['startDate']} ~ ${metadata['endDate']}',
              ),
            );
          } else if (metadata['startDate'] != null) {
            widgets.add(
              _InfoRow(label: '공연일', value: metadata['startDate'].toString()),
            );
          }
          if (metadata['genre'] != null &&
              metadata['genre'].toString().isNotEmpty) {
            widgets.add(
              _InfoRow(label: '장르', value: metadata['genre'].toString()),
            );
          }
          break;
      }
      return widgets;
    }

    // 새로 작성 모드
    switch (widget.type) {
      case RecordType.book:
        final book = widget.book!;
        return [
          if (book.author.isNotEmpty) _InfoRow(label: '저자', value: book.author),
          if (book.publisher != null)
            _InfoRow(label: '출판사', value: book.publisher!),
          if (book.pubDate != null)
            _InfoRow(label: '출판일', value: _formatPubDate(book.pubDate!)),
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
    Map<String, dynamic> metadata = {};

    // 수정 모드일 때는 Record의 데이터 사용
    if (widget.record != null) {
      typeString = widget.record!.type;
      metadata = widget.record!.metadata ?? {};
    } else {
      // 새로 작성 모드
      switch (widget.type) {
        case RecordType.book:
          typeString = 'book';
          final book = widget.book!;
          metadata = {
            'author': book.author,
            'publisher': book.publisher,
            'pubDate': book.pubDate,
            'isbn': book.isbn,
          };
          break;
        case RecordType.movie:
          typeString = 'movie';
          final movie = widget.movie!;
          metadata = {
            'releaseDate': movie.releaseDate,
            'voteAverage': movie.voteAverage,
            'id': movie.id,
          };
          break;
        case RecordType.performance:
          typeString = 'performance';
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
    }

    final viewModel = ref.read(recordWriteViewModelProvider.notifier);

    // 수정 모드인지 확인
    if (widget.record != null && widget.record!.id != null) {
      // 업데이트 모드
      await viewModel.updateRecord(
        recordId: widget.record!.id!,
        userId: user.uid,
        type: typeString,
        date: _selectedDate,
        title: _getTitle(),
        imageUrl: _getImageUrl(),
        content: _contentController.text,
        rating: _rating,
        metadata: metadata,
      );
    } else {
      // 새로 작성 모드
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
    }

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
      SnackBar(
        content: Text(widget.record != null ? '기록이 수정되었습니다.' : '기록이 저장되었습니다.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getImageUrl();
    final title = _getTitle();
    final state = ref.watch(recordWriteViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: WriteScreenAppBar(
        selectedDate: _selectedDate,
        onDateChanged: (date) {
          setState(() {
            _selectedDate = date;
          });
        },
        onSave: _save,
        isContentEmpty: _contentController.text.trim().isEmpty,
        isLoading: state.isLoading,
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
                              textAlign: TextAlign.left,
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
                    mainAxisAlignment: MainAxisAlignment.start,
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
