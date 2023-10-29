import 'dart:ui';

class AppColors {
  static final AppColors _instance = AppColors._internal();

  static AppColors get instance => _instance;

  late Color whiteGrey;
  late Color blue;
  late Color skyBlue;
  late Color white;
  late Color red;

  AppColors._internal() {
    whiteGrey = Color(0xFFDFE4F2);
    blue = Color(0xFF044BD9);
    skyBlue = Color(0xFF235FD9);
    white = Color(0xFFF0F2F2);
    red = Color(0xFFF20505);
  }
}