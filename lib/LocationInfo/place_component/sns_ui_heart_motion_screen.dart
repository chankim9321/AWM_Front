import 'package:flutter/material.dart';
import 'sns_ui_heart_provider.dart';
import 'sns_ui_heart_component.dart';
import 'package:provider/provider.dart';

class SnsUIHeartMotionScreen extends StatelessWidget {
  const SnsUIHeartMotionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SnsUIHeartProvider>(
      create: (_) => SnsUIHeartProvider(),
      child: Consumer<SnsUIHeartProvider>(builder: (context, state, child) {
        return Scaffold(
            appBar: AppBar(title: Text('SNS Heart Motion')),
            body: snsUIHeartComponent(
                context: context,
                isHeart: state.isHeart,
                isShowHeart: state.isShowHeart,
                imageIndex: 26,
                onHeartTap: () => state.onDoubleTap()));
      }),
    );
  }
}
