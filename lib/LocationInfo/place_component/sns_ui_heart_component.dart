import 'package:flutter/material.dart';

Column snsUIHeartComponent({
  required BuildContext context,
  required bool isHeart,
  required Function() onHeartTap,
  bool isShowHeart = false,
  required int imageIndex,
}) {
  return Column(
    children: [
      GestureDetector(
        onDoubleTap: onHeartTap,
        child: SizedBox(
          child: Stack(
            children: [
              SizedBox(
                child: AnimatedSwitcher(
                    switchInCurve: Curves.fastLinearToSlowEaseIn,
                    switchOutCurve: Curves.fastLinearToSlowEaseIn,
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                    child: isShowHeart
                        ? const Icon(
                      Icons.favorite_rounded,
                      key: ValueKey('SHOW_HEART'),
                      size: 80,
                    )
                        : const Icon(
                      Icons.favorite_rounded,
                      size: 0,
                    )),
              )
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Wrap(
              children: [
                GestureDetector(
                  onTap: onHeartTap,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: ((child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    }),
                    child: !isHeart
                        ? const Icon(
                      key: ValueKey('UN_FAVORITE'),
                      Icons.favorite_border_outlined,
                      size: 30,
                    )
                        : const Icon(
                        key: ValueKey('FAVORITE'),
                        Icons.favorite_outlined,
                        color: Colors.red,
                        size: 30),
                  ),
                ),
                const SizedBox(width: 16),
                // const Icon(
                //   Icons.chat_bubble_outline,
                //   size: 30,
                // ),
              ],
            ),
            const Icon(
              Icons.bookmark_border_outlined,
              size: 30,
            ),
          ],
        ),
      )
    ],
  );
}