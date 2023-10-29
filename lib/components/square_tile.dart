import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SquareTile extends StatelessWidget {
  final String imagePath;
  final double height;
  final Function()? onTap;
  final String notice;

  const SquareTile({
    super.key,
    required this.imagePath,
    required this.height,
    required this.onTap,
    required this.notice
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(left: 15, right: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(30),
          color: Colors.grey[300],
        ),
        // child: SvgPicture.asset(
        //   imagePath,
        //   height: height,
        // ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              imagePath,
              height: height,
            ),
            SizedBox(width: 5,),
            Text(notice)
          ],
        ),
      ),
    );
  }
}