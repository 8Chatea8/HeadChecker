import 'package:flutter/material.dart';
import 'app_bar.dart';
import 'news_screen.dart';
import 'headchecker.dart';
import 'bottom_navigation_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'onboarding.dart';

const Color primaryButtonColor = Color.fromARGB(255, 52, 45, 255);

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 1) {
        _navigateToScreen(NewsScreen());
      } else if (index == 2) {
        _navigateToScreen(HeadChecker());
      }
    });
  }

  void _navigateToScreen(Widget screen) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
        backgroundColor: colorScheme.onPrimaryContainer,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/images/nope1_anime.json',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      frameRate: FrameRate(60),
                      repeat: true,
                      animate: true,
                    ),
                  ],
                ),
              ),
              Text(
                '낚시성 기사 OUT!',
                style: GoogleFonts.blackHanSans(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 28,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'Mahimahi Aiffel Online Core',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 44),
                child: ElevatedButton(
                  onPressed: () {
                    _navigateToScreen(OnBoarding());
                  },
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all<Color>(primaryButtonColor),
                  ),
                  child: Text(
                    '시작하기',
                    style: GoogleFonts.gothicA1(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
