import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'headchecker.dart';
import 'home_screen.dart';
import 'app_bar.dart';
import 'bottom_navigation_bar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class NewsItem {
  final String title;
  final String link;
  final String img;
  final String time;

  NewsItem({
    required this.title,
    required this.link,
    required this.img,
    required this.time,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'],
      link: json['link'],
      img: json['img'],
      time: json['time'],
    );
  }
}

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final FocusNode _unfocusNode = FocusNode();
  List<NewsItem> newsItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/news'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

      setState(() {
        newsItems = data.map((item) => NewsItem.fromJson(item)).toList();
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  int _currentIndex = 1;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else if (index == 2) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HeadChecker()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
      child: Scaffold(
        key: GlobalKey<ScaffoldState>(),
        backgroundColor: Colors.grey[200],
        appBar: CustomAppBar(),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.onPrimaryContainer,
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        alignment: AlignmentDirectional(0, -1),
        children: [
          Align(
            alignment: AlignmentDirectional(0.00, -1.00),
            child: Image.asset(
              "assets/images/newspaper04.jpg",
              width: double.infinity,
              height: 340,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 100, 0, 0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Align(
                    alignment: AlignmentDirectional(0.00, 1.00),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 200, 0, 0),
                      child: Container(
                        width: double.infinity,
                        height: 500,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4,
                              color: Colors.grey.withOpacity(0.2),
                              offset: Offset(0, -2),
                            )
                          ],
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(0),
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16, 10, 16, 16),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Korean News Headlines',
                                      style: GoogleFonts.greatVibes(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              isLoading
                                  ? Stack(
                                children: [
                                  Column(
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.fromLTRB(
                                            0, 20, 0, 0),
                                        child: Lottie.asset(
                                          'assets/images/dolphin_anime.json',
                                          width: 180,
                                          height: 180,
                                          fit: BoxFit.cover,
                                          frameRate: FrameRate(60),
                                          repeat: true,
                                          animate: true,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(20.0),
                                        child: Text(
                                            style: GoogleFonts.montserrat(
                                                fontSize: 18,
                                                fontWeight:
                                                FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 8, 8, 94)),
                                            "LOADING"),
                                      )
                                    ],
                                  ),
                                ],
                              )
                                  : _buildNewsList(newsItems),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList(List<NewsItem> newsItems) {
    return Expanded(
      child: ListView.builder(
        itemCount: newsItems.length,
        itemBuilder: (context, index) {
          final newsItem = newsItems[index];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                newsItem.img,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              newsItem.title,
              style: GoogleFonts.gothicA1(
                color: Colors.black,
              ),
            ),
            subtitle: Text(
              newsItem.time,
              textAlign: TextAlign.right,
              style: GoogleFonts.gothicA1(
                color: Color.fromARGB(255, 117, 111, 180),
              ),
            ),
            onTap: () {
              Clipboard.setData(ClipboardData(text: newsItem.link));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Center(
                    child: Text(
                      '뉴스 링크가 클립보드에 복사되었습니다.',
                      style: GoogleFonts.gothicA1(fontSize: 16),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
                  duration: Duration(seconds: 4),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
