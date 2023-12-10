import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'package:mapdesign_flutter/LoginPage/introduction_page_2.dart';
import 'package:mapdesign_flutter/LoginPage/introduction_page_3.dart';
import 'package:mapdesign_flutter/LoginPage/login_page.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mapdesign_flutter/LoginPage/introduction_page_1.dart';
import 'package:mapdesign_flutter/Screen/google_map_screen.dart';


class LoginModule extends StatefulWidget {
  const LoginModule({Key? key}) : super(key: key);

  @override
  State<LoginModule> createState() => _LoginModuleState();
}

class _LoginModuleState extends State<LoginModule> {
  final CarouselController _carouselController = CarouselController();
  int _current = 0;
  late List<Widget> widgetList;
  String? token;
  bool? isLogined;
  Future<void> _setToken() async {
    token = await SecureStorage().readSecureData('token');
  }
  Future<void> _checkLogined() async {
    if(token != null){
      isLogined = true;
    }
    else {
      isLogined = false;
    }
  }
  Future<void> _init() async{
    await _setToken();
    await _checkLogined();
    if(isLogined!){
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Test()));
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widgetList = [
      // scaffold pages
      IntroductionFirstPage(setLastPage: _setLastPage),
      IntroductionSecondPage(setLastPage: _setLastPage,),
      IntroductionThirdPage(setLastPage: _setLastPage),
      LoginPage(),
    ];
    _init();
  }
  // skip 버튼을 눌렀을 때 마지막 페이지로 이동
  void _setLastPage(){
    setState(() {
      _current = 3;
    });
    _carouselController.jumpToPage(3);
  }
  void onPageChange(index){
    setState(() {
      _current = index;
    });
  }
  Widget sliderWidget() {
    return CarouselSlider(
      carouselController: _carouselController,
      items: widgetList,
      options: CarouselOptions(
          height: MediaQuery.of(context).size.height,
          autoPlay: false,
          enlargeCenterPage: true,
          viewportFraction: 0.9,
          aspectRatio: 2.0,
          initialPage: 0,
          enableInfiniteScroll: false,
          scrollDirection: Axis.horizontal,
          pageSnapping: true,
          onPageChanged: (index, reason) {
            onPageChange(index);
          }),
    );
  }

  Widget sliderIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widgetList.length, (index) {
        return Container(
          width: 8.0,
          height: 8.0,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _current == index ? Colors.blueAccent : Colors.grey),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        colorFilter: ColorFilter.mode(
          Colors.black.withOpacity(0.5),
          BlendMode.darken,
        ),
        fit: BoxFit.cover,
        image: AssetImage('asset/flutter_asset/find_path.png'),
      )),
      child: Column(
        children: [
          Expanded(child: sliderWidget()),
          SafeArea(top: false, child: sliderIndicator()),
        ],
      ),
    );
  }
}
