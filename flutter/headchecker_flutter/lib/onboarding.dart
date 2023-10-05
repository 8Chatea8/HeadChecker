import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'news_screen.dart';

class OnBoarding extends StatefulWidget {
  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController pageController = PageController(initialPage: 0);
  final FocusNode unfocusNode = FocusNode();
  double currentPage = 0;

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {
        currentPage = pageController.page!;
      });
    });
  }

  Widget buildPage({
    required String imagePath,
    required String title,
    required String description,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 80),
          child: Container(
            width: double.infinity,
            height: 450,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    spreadRadius: 5,
                    blurRadius: 20,
                    offset: Offset(3, 3))
              ],
              color: Color(0xFF160A4C),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20)),
              border: Border.all(
                color: Color.fromARGB(255, 0, 0, 0),
                width: 0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15)),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: 400,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(50, 0, 0, 10),
          child: Text(
            title,
            textAlign: TextAlign.justify,
            style: GoogleFonts.gothicA1(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(50, 0, 50, 0),
          child: Text(
            description,
            textAlign: TextAlign.justify,
            style: GoogleFonts.gothicA1(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildPage(
        imagePath: 'assets/images/onboarding1.png', // 이미지 경로 수정
        title: 'STEP 1. 리스트 확인',
        description:
            '리스트를 위로 끌어올리면 전체 기사가 나타납니다. 정치, 경제, 사회, IT 등을 종합하여 가장 조회수가 높은 상위 20개의 기사가 제공됩니다.',
      ),
      buildPage(
        imagePath: 'assets/images/onboarding2.png', // 이미지 경로 수정
        title: 'STEP 2. 제목 선택',
        description:
            '뉴스 제목을 선택하면 클립보드에 뉴스 링크가 복사됩니다. CHECK 버튼을 클릭하면 모델 추론 페이지로 이동합니다. ',
      ),
      buildPage(
        imagePath: 'assets/images/onboarding3.png', // 이미지 경로 수정
        title: 'STEP 3. 낚시성 기사 판별',
        description:
            '클립보드에 복사한 링크를 입력창에 붙여넣고 확인 버튼을 클릭하면 모델이 낚시성 기사 여부를 판별합니다. 결과는 확률 값으로 표시됩니다.  ',
      ),
    ];

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(unfocusNode),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFF160A4C),
        body: SafeArea(
          top: true,
          child: ListView(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.vertical,
            children: [
              Container(
                width: double.infinity,
                height: 675,
                decoration: BoxDecoration(
                  color: Color(0xFF160A4C),
                ),
                child: Stack(
                  children: [
                    PageView(
                      controller: pageController,
                      scrollDirection: Axis.horizontal,
                      children: pages,
                    ),
                    Align(
                      alignment: AlignmentDirectional(0.80, 0.45),
                      child: DotsIndicator(
                        dotsCount: pages.length,
                        position: currentPage.round(),
                        decorator: DotsDecorator(
                          size: const Size.square(9.0),
                          activeSize: const Size(18.0, 9.0),
                          activeShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          color: Color(0x2BCFEF39),
                          activeColor: Color(0xFFDDE514),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(148, 0, 148, 10),
                    child: Container(
                      width: double.infinity,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () async {
                          await pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        },
                        child: Text(
                          'NEXT',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 100, 66, 255),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(148, 0, 148, 0),
                    child: Container(
                      width: double.infinity,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () async {
                          // NewsScreen 페이지로 이동
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    NewsScreen()), // NewsScreen은 이동하려는 페이지입니다.
                          );
                        },
                        child: Text(
                          'START',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 100, 66, 255),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
