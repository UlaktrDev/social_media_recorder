library social_media_recorder;

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:social_media_recorder/provider/sound_record_notifier.dart';
import 'package:social_media_recorder/widgets/show_counter.dart';

// ignore: must_be_immutable
class SoundRecorderWhenLockedDesign extends StatelessWidget {
  final double fullRecordPackageHeight;
  final SoundRecordNotifier soundRecordNotifier;
  final String? cancelText;
  final Function sendRequestFunction;
  final Function(String time)? stopRecording;
  final Widget? recordIconWhenLockedRecord;
  final TextStyle? cancelTextStyle;
  final TextStyle? counterTextStyle;
  final Color recordIconWhenLockBackGroundColor;
  final Color? counterBackGroundColor;
  final Color? cancelTextBackGroundColor;
  final Widget? sendButtonIcon;
  final Decoration? soundRecorderWhenLockedDecoration;
  final double? soundRecorderWhenLockedWidth;
  final double? counterWidth;
  final EdgeInsetsGeometry? soundRecorderWhenLockedMargin;
  final Widget? micCounterWidget;
  final EdgeInsetsGeometry? counterPadding;
  final Widget? pauseWidget;
  final Widget? deleteWidget;

  // ignore: sort_constructors_first
  const SoundRecorderWhenLockedDesign({
    Key? key,
    required this.fullRecordPackageHeight,
    required this.sendButtonIcon,
    required this.soundRecordNotifier,
    required this.cancelText,
    required this.sendRequestFunction,
    this.stopRecording,
    required this.recordIconWhenLockedRecord,
    required this.cancelTextStyle,
    required this.counterTextStyle,
    required this.recordIconWhenLockBackGroundColor,
    required this.counterBackGroundColor,
    required this.cancelTextBackGroundColor,
    this.soundRecorderWhenLockedDecoration,
    this.soundRecorderWhenLockedWidth,
    this.soundRecorderWhenLockedMargin,
    this.counterWidth,
    this.micCounterWidget,
    this.counterPadding,
    this.pauseWidget,
    this.deleteWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: fullRecordPackageHeight + 60,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          if (soundRecordNotifier.status == SoundRecordStatusEnum.paused) ...[
            Row(
              children: [
                InkWell(
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  onTap: () async {
                    soundRecordNotifier.isShow = false;
                    soundRecordNotifier.finishRecording();
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(600),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                      width: fullRecordPackageHeight,
                      height: fullRecordPackageHeight,
                      child: Container(
                        color: recordIconWhenLockBackGroundColor,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.send,
                            textDirection: TextDirection.ltr,
                            size: 20,
                            color: Colors.grey.shade200,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: fullRecordPackageHeight,
                  width: MediaQuery.sizeOf(context).width - 128,
                  decoration: soundRecorderWhenLockedDecoration ??
                      BoxDecoration(
                        color:
                            cancelTextBackGroundColor ?? Colors.grey.shade100,
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                  margin: soundRecorderWhenLockedMargin,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: counterPadding ?? EdgeInsets.zero,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              soundRecordNotifier.second
                                  .toString()
                                  .padLeft(2, '0'),
                              style: counterTextStyle ??
                                  const TextStyle(color: Colors.black),
                            ),
                            Text(
                              " : ",
                              style: counterTextStyle,
                            ),
                            Text(
                              soundRecordNotifier.minute
                                  .toString()
                                  .padLeft(2, '0'),
                              style: counterTextStyle ??
                                  const TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      StreamBuilder(
                        stream: StreamGroup.merge([
                          soundRecordNotifier.audioPlayer.positionStream
                              .asBroadcastStream(),
                          soundRecordNotifier.audioPlayer.playerStateStream
                              .asBroadcastStream(),
                        ]),
                        builder: (context, snapshot) {
                          final maxPosition = soundRecordNotifier
                                  .audioPlayer.duration?.inMilliseconds
                                  .toDouble() ??
                              1.0;
                          var currentPosition = soundRecordNotifier
                              .audioPlayer.position.inMilliseconds
                              .toDouble();
                          if (currentPosition > maxPosition) {
                            currentPosition = maxPosition;
                          }

                          final wavePosition = (currentPosition / maxPosition) *
                              soundRecordNotifier.calculateWaveCountAuto(
                                minWaves: 32,
                                maxWaves:
                                    soundRecordNotifier.maxWaveCount(context),
                                durationInSeconds: soundRecordNotifier.second +
                                    (soundRecordNotifier.minute * 60),
                              );
                          return Row(
                            children: List.generate(
                              soundRecordNotifier.calculatedWaveform.length,
                              (index) {
                                return _waveItemBuilder(
                                  index: index,
                                  waveHeight: soundRecordNotifier
                                      .calculatedWaveform[index],
                                  wavePosition: wavePosition,
                                );
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    soundRecordNotifier.resetEdgePadding();
                  },
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: deleteWidget ??
                        const Icon(
                          Icons.delete_outline,
                          size: 18,
                        ),
                  ),
                ),
              ],
            ),
          ] else
            Container(
              width: soundRecorderWhenLockedWidth ??
                  MediaQuery.of(context).size.width,
              height: fullRecordPackageHeight,
              decoration: soundRecorderWhenLockedDecoration ??
                  BoxDecoration(
                    color: cancelTextBackGroundColor ?? Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
              margin: soundRecorderWhenLockedMargin,
              child: InkWell(
                onTap: () {
                  if (soundRecordNotifier.status ==
                      SoundRecordStatusEnum.paused) {
                    return;
                  }
                  soundRecordNotifier.isShow = false;
                  soundRecordNotifier.resetEdgePadding();
                },
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                focusColor: Colors.transparent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () async {
                        soundRecordNotifier.isShow = false;
                        soundRecordNotifier.finishRecording();
                      },
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      child: Transform.scale(
                        scale: 1.2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(600),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeIn,
                            width: fullRecordPackageHeight,
                            height: fullRecordPackageHeight,
                            child: Container(
                              color: recordIconWhenLockBackGroundColor,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: recordIconWhenLockedRecord ??
                                    sendButtonIcon ??
                                    Icon(
                                      Icons.send,
                                      textDirection: TextDirection.ltr,
                                      size: 20,
                                      color: (soundRecordNotifier.buttonPressed)
                                          ? Colors.grey.shade200
                                          : Colors.black,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                                hoverColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                onTap: () {
                                  soundRecordNotifier.isShow = false;
                                  String _time =
                                      soundRecordNotifier.minute.toString() +
                                          ":" +
                                          soundRecordNotifier.second.toString();
                                  if (stopRecording != null) {
                                    stopRecording!(_time);
                                  }
                                  soundRecordNotifier.resetEdgePadding();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    cancelText ?? "",
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.clip,
                                    style: cancelTextStyle ??
                                        const TextStyle(
                                          color: Colors.black,
                                        ),
                                  ),
                                )),
                          ),
                          ShowCounter(
                            soundRecorderState: soundRecordNotifier,
                            counterTextStyle: counterTextStyle,
                            counterBackGroundColor: counterBackGroundColor,
                            counterHeight: fullRecordPackageHeight,
                            counterWidth: counterWidth,
                            borderPadding: soundRecorderWhenLockedMargin,
                            micCounterWidget: micCounterWidget,
                            counterPadding: counterPadding,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            top: 0,
            right: 8,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTapDown: (_) async {
                  await soundRecordNotifier.handlePauseOrResumeAudio(
                    context: context,
                  );
                },
                child: pauseWidget ??
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Icon(
                        soundRecordNotifier.status ==
                                SoundRecordStatusEnum.paused
                            ? Icons.mic_outlined
                            : Icons.pause,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _waveItemBuilder({
    required int index,
    required double waveHeight,
    required double wavePosition,
    Color? activeColor,
    Color? inActiveColor,
  }) {
    return Container(
      height: waveHeight,
      width: 2,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(
        horizontal: 1,
      ),
      decoration: BoxDecoration(
        color: index < wavePosition
            ? activeColor ?? Colors.blue
            : inActiveColor ?? Colors.grey,
        borderRadius: BorderRadius.circular(
          64,
        ),
      ),
    );
  }
}
