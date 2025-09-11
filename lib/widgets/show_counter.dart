library social_media_recorder;

import 'package:flutter/material.dart';
import 'package:social_media_recorder/provider/sound_record_notifier.dart';

/// Used this class to show counter and mic Icon
class ShowCounter extends StatelessWidget {
  final SoundRecordNotifier soundRecorderState;
  final TextStyle? counterTextStyle;
  final Color? counterBackGroundColor;
  final double counterHeight;
  final double? counterWidth;
  final EdgeInsetsGeometry? borderPadding;
  final EdgeInsetsGeometry? counterPadding;
  final Widget? micCounterWidget;

  // ignore: sort_constructors_first
  const ShowCounter({
    required this.soundRecorderState,
    required this.counterHeight,
    Key? key,
    this.counterTextStyle,
    required this.counterBackGroundColor,
    this.counterWidth,
    this.borderPadding,
    this.micCounterWidget,
    this.counterPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: counterHeight,
        color: counterBackGroundColor ?? Colors.transparent,
        padding: borderPadding ?? const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: counterPadding ?? EdgeInsets.zero,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    soundRecorderState.second.toString().padLeft(2, '0'),
                    style: counterTextStyle ??
                        const TextStyle(color: Colors.black),
                  ),
                  Text(
                    " : ",
                    style: counterTextStyle,
                  ),
                  Text(
                    soundRecorderState.minute.toString().padLeft(2, '0'),
                    style: counterTextStyle ??
                        const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(seconds: 1),
              opacity: soundRecorderState.second % 2 == 0 ? 1 : 0,
              child: micCounterWidget ??
                  const Icon(
                    Icons.mic,
                    color: Colors.red,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
