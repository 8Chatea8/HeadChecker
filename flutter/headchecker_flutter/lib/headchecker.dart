import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';

import 'app_bar.dart';
import 'bottom_navigation_bar.dart';
import 'home_screen.dart';
import 'news_screen.dart';

class HeadChecker extends StatefulWidget {
  @override
  _HeadCheckerState createState() => _HeadCheckerState();
}

class _HeadCheckerState extends State<HeadChecker>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController urlTextController = TextEditingController();
  final FocusNode unfocusNode = FocusNode();
  late final AnimationController _lottieController;

  @override
  void initState() {
    _lottieController = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    urlTextController.dispose();
    super.dispose();
  }

  String newsHeadline = "     여기에 뉴스 헤드라인이 표시됩니다.";
  double modelInference = 0.0;

  int _currentIndex = 2;

  Future<void> sendRequest(String url) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/inference'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'link': url}),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        newsHeadline = data['error'] ?? data['title'] ?? "오류 발생";
        modelInference = double.tryParse(data['inference'].toString()) ?? 0.0;
      });
    } catch (e) {
      setState(() {
        newsHeadline = "오류 발생: $e";
        modelInference = 0.0;
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else if (index == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NewsScreen()),
        );
      }
    });
  }

  Widget _buildInputField(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(80),
          color: Colors.grey[200],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: Icon(
                color: colorScheme.outline,
                Icons.search,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 14, 0),
                child: TextFormField(
                  controller: urlTextController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.grey[200],
                    hintText: 'News URL...',
                    suffixIcon: GestureDetector(
                      onTap: () {
                        urlTextController.clear();
                      },
                      child: Icon(
                        color: colorScheme.outline,
                        Icons.clear,
                      ),
                    ),
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckButton(ColorScheme colorScheme) {
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 25, 110),
              child: ElevatedButton(
                onPressed: () {
                  final url = urlTextController.text;
                  sendRequest(url);
                  _lottieController.forward();
                  _lottieController.repeat();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 52, 45, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80),
                  ),
                ),
                child: Text(
                  '확인',
                  style: GoogleFonts.montserrat(
                    color: colorScheme.onPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          top: -70,
          child: Lottie.asset(
            'assets/images/barchart.json',
            controller: _lottieController,
            onLoaded: (composition) {
              _lottieController.duration = composition.duration;
              _lottieController.stop();
            },
            width: 280,
            height: 250,
            fit: BoxFit.cover,
            frameRate: FrameRate(60),
            animate: true,
            repeat: true,
          ),
        ),
      ],
    );
  }

  Widget _buildNewsDisplay(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: colorScheme.secondary,
            blurRadius: 0,
            spreadRadius: 0,
            offset: Offset(0, 0),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border.all(
          color: colorScheme.outline,
          width: 0,
        ),
        color: Colors.grey[200],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              "$newsHeadline",
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.gothicA1(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(
            indent: 20,
            endIndent: 20,
            color: Color.fromARGB(40, 12, 12, 12),
            thickness: 1.0,
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.center,
              child: CircularPercentIndicator(
                radius: 100.0,
                lineWidth: 20.0,
                animation: true,
                percent: modelInference,
                center: Text(
                  "${(modelInference * 100).toStringAsFixed(1)}%",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 35.0,
                    color: Colors.black,
                  ),
                ),
                footer: Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Text(
                    "위 기사는 ${(modelInference * 100).toStringAsFixed(1)}%의 확률로 낚시성 기사입니다.",
                    style: GoogleFonts.gothicA1(
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                      fontSize: 15.0,
                    ),
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Color.fromARGB(255, 228, 7, 7),
                backgroundColor: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(unfocusNode),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: colorScheme.onPrimaryContainer,
        appBar: CustomAppBar(),
        body: SingleChildScrollView(
          child: SafeArea(
            top: true,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildInputField(colorScheme),
                _buildCheckButton(colorScheme),
                _buildNewsDisplay(colorScheme),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}
