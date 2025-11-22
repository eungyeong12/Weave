import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weave/domain/entities/record/record.dart';
import 'package:weave/presentation/screens/record/record_write_screen.dart';
import 'package:weave/presentation/screens/home/home_screen.dart';
import 'package:weave/presentation/widgets/common/detail_screen_app_bar.dart';
import 'package:weave/presentation/widgets/common/delete_confirmation_dialog.dart';
import 'package:weave/di/injector.dart';

class RecordDetailScreen extends ConsumerStatefulWidget {
  final Record record;
  final String Function(String) getProxiedImageUrl;

  const RecordDetailScreen({
    super.key,
    required this.record,
    required this.getProxiedImageUrl,
  });

  @override
  ConsumerState<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends ConsumerState<RecordDetailScreen> {
  Record get record => widget.record;
  String Function(String) get getProxiedImageUrl => widget.getProxiedImageUrl;

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

  List<Widget> _buildMetadataWidgets() {
    final widgets = <Widget>[];
    if (record.metadata == null) return widgets;

    switch (record.type) {
      case 'book':
        if (record.metadata!['author'] != null &&
            record.metadata!['author'].toString().isNotEmpty) {
          widgets.add(
            _InfoRow(label: '저자', value: record.metadata!['author'].toString()),
          );
        }
        if (record.metadata!['publisher'] != null &&
            record.metadata!['publisher'].toString().isNotEmpty) {
          widgets.add(
            _InfoRow(
              label: '출판사',
              value: record.metadata!['publisher'].toString(),
            ),
          );
        }
        if (record.metadata!['pubDate'] != null &&
            record.metadata!['pubDate'].toString().isNotEmpty) {
          widgets.add(
            _InfoRow(
              label: '출판일',
              value: record.metadata!['pubDate'].toString(),
            ),
          );
        }
        break;
      case 'movie':
        if (record.metadata!['releaseDate'] != null &&
            record.metadata!['releaseDate'].toString().isNotEmpty) {
          widgets.add(
            _InfoRow(
              label: '개봉일',
              value: record.metadata!['releaseDate'].toString(),
            ),
          );
        }
        if (record.metadata!['voteAverage'] != null) {
          widgets.add(
            _InfoRow(
              label: '평점',
              value: record.metadata!['voteAverage'].toString(),
            ),
          );
        }
        break;
      case 'performance':
        if (record.metadata!['venue'] != null &&
            record.metadata!['venue'].toString().isNotEmpty) {
          widgets.add(
            _InfoRow(label: '공연장', value: record.metadata!['venue'].toString()),
          );
        }
        if (record.metadata!['startDate'] != null &&
            record.metadata!['endDate'] != null) {
          widgets.add(
            _InfoRow(
              label: '공연기간',
              value:
                  '${record.metadata!['startDate']} ~ ${record.metadata!['endDate']}',
            ),
          );
        } else if (record.metadata!['startDate'] != null) {
          widgets.add(
            _InfoRow(
              label: '공연일',
              value: record.metadata!['startDate'].toString(),
            ),
          );
        }
        if (record.metadata!['genre'] != null &&
            record.metadata!['genre'].toString().isNotEmpty) {
          widgets.add(
            _InfoRow(label: '장르', value: record.metadata!['genre'].toString()),
          );
        }
        break;
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DetailScreenAppBar(
        date: record.date,
        onEdit: () {
          // RecordType 변환
          RecordType recordType;
          switch (record.type) {
            case 'book':
              recordType = RecordType.book;
              break;
            case 'movie':
              recordType = RecordType.movie;
              break;
            case 'performance':
              recordType = RecordType.performance;
              break;
            default:
              return; // 알 수 없는 타입이면 수정 화면으로 이동하지 않음
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecordWriteScreen(
                type: recordType,
                getProxiedImageUrl: getProxiedImageUrl,
                selectedDate: record.date,
                record: record,
              ),
            ),
          );
        },
        onDelete: () => _showDeleteConfirmationDialog(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 이미지
                if (record.imageUrl != null && record.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      getProxiedImageUrl(record.imageUrl!),
                      width: 100,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 150,
                          color: Colors.grey.shade200,
                          child: Icon(
                            _getTypeIcon(record.type),
                            color: Colors.grey,
                            size: 50,
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: 100,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTypeIcon(record.type),
                      color: Colors.grey,
                      size: 50,
                    ),
                  ),
                // 제목
                const SizedBox(height: 16),
                Text(
                  record.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
                // 별점 영역
                if (record.rating > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < record.rating.round()
                            ? Icons.star
                            : Icons.star_border,
                        size: 13,
                        color: Colors.amber.shade600,
                      );
                    }),
                  ),
                ],
                // 메타데이터 (저자, 출판사 등)
                if (_buildMetadataWidgets().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ..._buildMetadataWidgets(),
                ],
                // 내용
                if (record.content.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    record.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    DeleteConfirmationDialog.show(context, _deleteRecord);
  }

  Future<void> _deleteRecord() async {
    if (record.id == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('삭제할 기록을 찾을 수 없습니다.'),
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

    final viewModel = ref.read(recordWriteViewModelProvider.notifier);

    await viewModel.deleteRecord(recordId: record.id!, userId: user.uid);

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

    // 삭제 성공 시 홈 화면으로 이동
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('기록이 삭제되었습니다.'),
        duration: Duration(seconds: 2),
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
