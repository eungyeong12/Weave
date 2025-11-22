import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weave/di/injector.dart';
import 'package:weave/presentation/widgets/diary/image_list_section.dart';
import 'package:weave/presentation/widgets/diary/diary_text_field.dart';
import 'package:weave/presentation/widgets/diary/date_picker_bottom_sheet.dart';
import 'package:weave/presentation/widgets/record/save_button.dart';
import 'package:weave/presentation/screens/home/home_screen.dart';
import 'package:weave/domain/entities/diary/diary.dart';

class DailyDiaryWriteScreen extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final Diary? diary; // 수정 모드일 때 기존 일기 데이터

  const DailyDiaryWriteScreen({
    super.key,
    required this.selectedDate,
    this.diary,
  });

  @override
  ConsumerState<DailyDiaryWriteScreen> createState() =>
      _DailyDiaryWriteScreenState();
}

class _DailyDiaryWriteScreenState extends ConsumerState<DailyDiaryWriteScreen> {
  final TextEditingController _diaryController = TextEditingController();
  final FocusNode _diaryFocusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];
  final List<String> _existingImageUrls = []; // 수정 모드일 때 기존 이미지 URL
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.diary?.date ?? widget.selectedDate;
    // 수정 모드일 때 기존 데이터 로드
    if (widget.diary != null) {
      _diaryController.text = widget.diary!.content;
      _existingImageUrls.addAll(widget.diary!.imageUrls);
    }
  }

  @override
  void dispose() {
    _diaryController.dispose();
    _diaryFocusNode.dispose();
    super.dispose();
  }

  Future<void> _addImage() async {
    // Web은 권한 확인 불필요
    if (kIsWeb) {
      await _pickImage();
      return;
    }

    // 권한 확인 및 요청
    // Permission.photos는 Android 13+에서는 READ_MEDIA_IMAGES를,
    // Android 12 이하에서는 READ_EXTERNAL_STORAGE를 자동으로 처리.
    // iOS에서는 PHPhotoLibrary 권한을 처리.
    PermissionStatus status = await Permission.photos.status;

    // 권한이 거부된 경우
    if (status.isDenied) {
      // 권한 요청
      status = await Permission.photos.request();
      if (status.isDenied) {
        if (mounted) {
          _showPermissionDeniedDialog();
        }
        return;
      }
    }

    // 권한이 영구적으로 거부된 경우
    if (status.isPermanentlyDenied) {
      if (mounted) {
        _showPermissionPermanentlyDeniedDialog();
      }
      return;
    }

    // 권한이 허용된 경우 이미지 선택
    await _pickImage();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _images.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지를 선택하는 중 오류가 발생했습니다: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('권한 필요'),
        content: const Text('사진을 선택하려면 사진 라이브러리 접근 권한이 필요합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }

  void _showPermissionPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('권한 필요'),
        content: const Text(
          '사진을 선택하려면 사진 라이브러리 접근 권한이 필요합니다.\n설정에서 권한을 허용해주세요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  Future<void> _save() async {
    // 내용이 비어있으면 저장하지 않음
    if (_diaryController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('일기 내용을 입력해주세요.'),
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

    final viewModel = ref.read(dailyDiaryWriteViewModelProvider.notifier);
    final imageFilePaths = _images.map((image) => image.path).toList();

    // 수정 모드인지 확인
    if (widget.diary != null && widget.diary!.id != null) {
      // 업데이트 모드
      await viewModel.updateDailyDiary(
        diaryId: widget.diary!.id!,
        userId: user.uid,
        date: _selectedDate,
        content: _diaryController.text,
        existingImageUrls: _existingImageUrls,
        newImageFilePaths: imageFilePaths,
      );
    } else {
      // 새로 작성 모드
      await viewModel.saveDailyDiary(
        userId: user.uid,
        date: _selectedDate,
        content: _diaryController.text,
        imageFilePaths: imageFilePaths,
      );
    }

    final state = ref.read(dailyDiaryWriteViewModelProvider);

    if (!mounted) return;

    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error ?? '오류가 발생했습니다.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // 저장 성공 시 홈 화면으로 이동
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.diary != null ? '기록이 수정되었습니다.' : '기록이 저장되었습니다.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 12,
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
              final state = ref.watch(dailyDiaryWriteViewModelProvider);
              return SaveButton(
                onSave: _save,
                isContentEmpty: _diaryController.text.trim().isEmpty,
                isLoading: state.isLoading,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            // 텍스트 입력칸 외부를 클릭하면 포커스 해제
            _diaryFocusNode.unfocus();
          },
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                // 사진 추가 영역
                ImageListSection(
                  images: _images,
                  existingImageUrls: _existingImageUrls,
                  onAddImage: _addImage,
                  onRemoveImage: _removeImage,
                  onRemoveExistingImage: _removeExistingImage,
                ),
                // 일기 텍스트 입력 영역
                DiaryTextField(
                  controller: _diaryController,
                  focusNode: _diaryFocusNode,
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
