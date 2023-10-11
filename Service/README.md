# HeadChecker 프로젝트

이 프로젝트는 낚시성 기사를 식별하고 판별하기 위한 세 가지 주요 컴포넌트를 포함하고 있습니다. 아래는 각각의 컴포넌트에 대한 간략한 설명입니다.

## headchecker_flutter 폴더
`headchecker_flutter` 폴더에는 Flutter 애플리케이션이 포함되어 있습니다. 이 앱은 서버로부터 뉴스 기사 리스트를 불러와 화면에 표시하고 주어진 기사 URL이 낚시성 기사인지 판별하는 기능을 제공합니다.

## headchecker_chrome_ex 폴더
`headchecker_chrome_ex` 폴더에는 Chrome 확장 프로그램(Extension)이 포함되어 있습니다. 이 확장 프로그램은 브라우저에서 웹 페이지를 방문할 때 해당 페이지의 뉴스 기사가 낚시성 기사인지 판별하고 사용자에게 알려주는 역할을 합니다.

## server 폴더
`server` 폴더에는 백엔드 서버가 구현되어 있습니다. 이 서버에는 두 가지 주요 엔드포인트가 있습니다:
1. **뉴스 기사 리스트를 불러오는 엔드포인트**: 이 엔드포인트는 GET 메서드를 사용하여 뉴스 기사 목록을 가져옵니다.
2. **URL을 받아 낚시성 기사 여부를 판별하는 엔드포인트**: 이 엔드포인트는 POST 메서드를 사용하여 애플리케이션으로부터 URL을 수신하고, 해당 URL이 낚시성 기사인지 여부를 판별한 후 결과값을 반환합니다.
