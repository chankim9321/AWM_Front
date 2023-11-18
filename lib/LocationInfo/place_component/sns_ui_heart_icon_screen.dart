import 'package:flutter/material.dart';
import 'sns_ui_heart_component.dart';
import 'sns_ui_heart_provider.dart';
import 'package:provider/provider.dart';

class SnsUIHeartIconScreen extends StatelessWidget {
  const SnsUIHeartIconScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SnsUIHeartProvider>(
      create: (_) => SnsUIHeartProvider(),
      child: Consumer<SnsUIHeartProvider>(builder: (context, state, child) {
        return snsUIHeartComponent(
          context: context,
          isHeart: state.isHeart,
          imageIndex: 204,
          onHeartTap: () => state.onHeartTap());
      }),
    );
  }
}
