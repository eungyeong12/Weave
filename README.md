# ✏️ Weave(위브) - 도서, 영화·드라마, 공연·전시, 일상 기록을 한 곳에

## 🔗 Links

- **Web:** [웹 브라우저에서 실행하기 (Click)](https://weave-9b2c7.web.app/)
- **Android App:** [APK 다운로드 (v1.0.0)](https://github.com/eungyeong12/Weave/releases/download/v1.0.0/app-release.apk)

## 🛠️ 기술 스택

### 프론트엔드

![Flutter](https://img.shields.io/badge/Flutter-02569B.svg?&style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2.svg?&style=for-the-badge&logo=Dart&logoColor=white)

### 백엔드 & 인프라

- **Firebase Authentication**: 이메일/비밀번호 기반 회원가입 및 로그인

- **Cloud Firestore**: 게시물 데이터 및 앱 잠금 비밀번호 설정 저장 및 조회

- **Firebase Storage**: 일기 이미지 파일 저장 및 관리

- **Cloud Functions**: 네이버 도서, TMDb 영화/드라마, KOPIS 공연 검색 API 호출

## 📝 기능 목록

### 1️⃣ 인증 및 보안

**회원가입 및 로그인**: Firebase Authentication을 통한 이메일/비밀번호 회원가입 및 로그인

**앱 잠금**: 앱 실행 시 PIN 번호 또는 생체 인증을 요구하는 잠금 화면 기능

**잠금 설정**: 설정 화면에서 앱 잠금 기능을 켜고 끄거나, PIN 번호를 변경

**로그아웃 및 회원 탈퇴**: 설정 화면에서 계정 로그아웃 및 서비스 탈퇴 기능 제공

<table>
  <tr>
    <td>
      <img src="https://velog.velcdn.com/images/eungyeong12/post/6858296b-8106-429f-a81c-ed12aa01f41a/image.gif" alt="설명1" />
    </td>
    <td>
      <img src="https://velog.velcdn.com/images/eungyeong12/post/7cbc2ead-b7d3-4d3c-98fd-c279f9d0f722/image.gif" alt="설명2" />
    </td>
    <td>
      <img src="https://velog.velcdn.com/images/eungyeong12/post/4c5f71f1-7e7c-489e-92eb-0fd12c1d7c86/image.gif" alt="설명3" />
    </td>
  </tr>
</table>

### 2️⃣ 기록 생성 및 관리

**기록 시작**: 메인 화면의 '+' 버튼을 눌러 신규 기록 시작

**4가지 카테고리 선택**: [도서], [영화·드라마], [공연·전시], [일상] 중 하나를 선택

**[문화] API 검색**: '문화 기록' 3종 선택 시, 외부 API(네이버, TMDb, KOPIS)와 연동된 검색 화면을 통해 항목(제목, 커버)을 선택

**[문화] 기록 작성**: API로 가져온 정보를 기반으로 별점, 날짜, 감상 텍스트를 입력

**[일상] 기록 작성**: 날짜, 이미지, 일기 텍스트를 입력

**기록 수정**: 기존에 작성된 기록의 내용을 수정

**기록 삭제**: 기존 기록을 삭제 (삭제 시 확인 팝업 노출)

<table>
  <tr>
    <td>
      <img src="https://velog.velcdn.com/images/eungyeong12/post/6ff2794e-601f-4827-b46b-4c19c7a16302/image.gif" alt="설명1" />
    </td>
    <td>
      <img src="https://velog.velcdn.com/images/eungyeong12/post/d2748ba5-9511-42e5-925f-79519ce71bc4/image.gif" alt="설명2" />
    </td>
    <td>
      <img src="https://velog.velcdn.com/images/eungyeong12/post/a1715c52-e475-4cda-b98a-539a642f9365/image.gif" alt="설명3" />
    </td>
  </tr>
</table>

<table>
  <tr>
    <td>
      <img src="https://velog.velcdn.com/images/eungyeong12/post/ce772e14-54ab-4441-84fb-63e5ebd1d961/image.gif" alt="설명1" />
    </td>
    <td>
      <img src="https://velog.velcdn.com/images/eungyeong12/post/3d5c4c98-f394-4dd6-ac13-25518de1c520/image.gif" alt="설명2" />
    </td>
    <td>
      <img src="https://velog.velcdn.com/images/eungyeong12/post/2bd1994c-f6a6-413a-b38b-7d85062844a2/image.gif" alt="설명3" />
    </td>
  </tr>
</table>

<table>
  <tr>
    <td>
      <img src="https://velog.velcdn.com/images/eungyeong12/post/7aa34273-254f-46e7-8dff-b3f690e98d22/image.gif" alt="설명2" />
    </td>
    <td>
      <img src="https://velog.velcdn.com/images/eungyeong12/post/16886813-c12b-45e8-8eaa-718c23274360/image.gif" alt="설명1" />
    </td>
  </tr>
</table>

### 3️⃣ 기록 조회 및 탐색

**캘린더 뷰**

- 앱의 메인 화면

- 월별 달력 형식으로, 기록이 있는 날짜의 배경에 해당 기록의 대표 이미지가 표시됨

- 날짜 선택 시 해당 날짜의 기록 상세(또는 목록)로 이동

**갤러리 뷰**

- 모든 기록의 대표 이미지를 최신순 그리드(Grid) 레이아웃으로 모아보기

- 하단 탭을 통해 '캘린더 뷰'와 상호 전환

**기록 상세 조회**

- **문화 기록 상세**: 커버 이미지, 별점, 날짜, 감상 텍스트를 표시

- **일상 기록 상세**: 첨부된 이미지 URL 목록을 스와이프형 뷰어로 표시, 날짜, 일기 텍스트를 표시

<table>
  <tr>
    <td>
      <img src="https://velog.velcdn.com/images/eungyeong12/post/9fad81aa-6572-42fa-b0af-ddcad41a98d9/image.gif" alt="설명1" />
    </td>
    <td>
      <img src="https://velog.velcdn.com/images/eungyeong12/post/a9d65850-2aae-4e0a-a294-77c89333d5f1/image.gif" alt="설명2" />
    </td>
    <td>
      <img src="https://velog.velcdn.com/images/eungyeong12/post/d1586b53-9643-476f-8a3f-f4b6dfc04ac1/image.gif" alt="설명2" />
    </td>
  </tr>
</table>

### 4️⃣ 검색

**검색 바**: '갤러리 뷰' 상단에 위치.

**키워드 검색**: 기록의 제목과 내용을 기반으로 기록을 필터링.

<table>
  <tr>
    <td>
      <img src="https://velog.velcdn.com/images/eungyeong12/post/5a373e03-5ec8-4656-97ca-e24956438a75/image.gif" alt="설명1" />
    </td>
    <td>
      <img src="https://velog.velcdn.com/images/eungyeong12/post/d3c3202b-a4ca-4390-8f08-d8ad0171043f/image.gif" alt="설명2" />
    </td>
  </tr>
</table>
