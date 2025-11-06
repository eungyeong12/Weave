// Flutter의 material 디자인 위젯 사용
import 'package:flutter/material.dart';

// 상태를 갖지 않으므로 'StatelessWidget'을 상속 받음
class GoogleSignInButton extends StatelessWidget {
  // 'VoidCallback'은 파라미터가 없고 아무것도 반환하지 않는 함수 타입 (버튼 클릭 시 실행될 함수)
  final VoidCallback onPressed;

  // 생성자. 'const'는 컴파일 타임에 상수로 만들 수 있음을 나타냄
  // 'key'는 위젯 트리의 식별자이며, 'super.key'를 통해 부모 클래스에 전달
  // 이 위젯을 사용할 때 'onPressed' 함수를 반드시 전달해야 함을 의미
  const GoogleSignInButton({super.key, required this.onPressed});

  @override
  // 'build' 메서드는 이 위젯이 화면에 어떻게 보일지를 정의함
  // 'context'는 위젯 트리에서 현재 위젯의 위치 정보
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFDADCE0)), // 테두리
      ),
      child: InkWell(
        // 'InkWell'은 자식 위젯을 탭할 수 있게 만들고, 탭할 때 물결 효과를 보여줌
        borderRadius: BorderRadius.circular(4),
        onTap:
            onPressed, // 'InkWell'이 탭되었을 때 실행될 함수. 생성자에서 전달받은 'onPressed' 함수를 연결
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // 'Row'의 자식 위젯들을 가로 방향에서 중앙 정렬
          // 'Row' 내부에 배치될 위젯 리스트
          children: [
            Image.asset('assets/images/google_logo.png', height: 24),
            const SizedBox(width: 12), // 공간을 차지하는 빈 박스
            const Text(
              'Sign in with Google',
              style: TextStyle(
                color: Color(0xFF3C4043),
                fontWeight: FontWeight.w500, // 보통(w400)보다 약간 굵은 굵기
                fontFamily: 'Roboto',
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
