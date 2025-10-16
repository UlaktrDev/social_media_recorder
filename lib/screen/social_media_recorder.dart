library social_media_recorder;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:social_media_recorder/provider/sound_record_notifier.dart';
import 'package:social_media_recorder/widgets/lock_record.dart';
import 'package:social_media_recorder/widgets/show_counter.dart';
import 'package:social_media_recorder/widgets/show_mic_with_text.dart';
import 'package:social_media_recorder/widgets/sound_recorder_when_locked_design.dart';

import '../audio_encoder_type.dart';

class SocialMediaRecorder extends StatefulWidget {
  /// use it for change back ground of cancel
  final Color? cancelTextBackGroundColor;

  /// function return the recording sound file and the time
  final Function(File soundFile, Duration time, List<int> waveForm)
      sendRequestFunction;

  /// function called when start recording
  final Function()? startRecording;

  /// function called when stop recording, return the recording time (even if time < 1)
  final Function(String time)? stopRecording;

  final Function()? pauseRecording;

  final Function()? resumeRecording;

  final Function()? deleteRecording;

  /// recording Icon That pressesd to start record
  final Widget recordIcon;

  /// recording Icon when user locked the record
  final Widget? recordIconWhenLockedRecord;

  /// use to change the backGround Icon when user recording sound
  final Color? recordIconBackGroundColor;

  /// use to change the Icon backGround color when user locked the record
  final Color? recordIconWhenLockBackGroundColor;

  /// use to change all recording widget color
  final Color? backGroundColor;

  /// use to change the counter style
  final TextStyle? counterTextStyle;

  /// text to know user should drag in the left to cancel record
  final String? slideToCancelText;

  /// use to change slide to cancel textstyle
  final TextStyle? slideToCancelTextStyle;

  /// this text show when lock record and to tell user should press in this text to cancel recod
  final String? cancelText;

  /// use to change cancel text style
  final TextStyle? cancelTextStyle;

  /// put you file directory storage path if you didn't pass it take deafult path
  final String? storeSoundRecoringPath;

  /// Chose the encode type
  final AudioEncoderType encode;

  /// use if you want change the raduis of un record
  final BorderRadius? radius;

  // use to change the counter back ground color
  final Color? counterBackGroundColor;

  // use to change lock icon to design you need it
  final Widget? lockButton;

  // use it to change send button when user lock the record
  final Widget? sendButtonIcon;

  // this function called when cancel record function

  // use to set max record time in second
  final int? maxRecordTimeInSecond;

  // use to change full package Height
  final double fullRecordPackageHeight;

  final double initRecordPackageWidth;

  final double? fullRecordPackageWidth;

  final Decoration? soundRecorderWhenLockedDecoration;

  final double? soundRecorderWhenLockedWidth;

  final EdgeInsetsGeometry? soundRecorderWhenLockedMargin;

  final double? counterWidth;

  final EdgeInsetsGeometry? borderPadding;

  final Widget? micCounterWidget;

  final double? heightLockRecord;

  final Duration durationLockRecordAnimatedPadding;

  final Duration animatedOpacityLockRecord;

  final Color? backGroundColorLockRecord;

  final Widget? lockedIconLockRecord;

  final Widget? unLockedIconLockRecord;

  final BorderRadiusGeometry? borderRadiusLockRecord;

  final EdgeInsetsGeometry? counterPadding;

  final Function()? microphoneRequestPermission;

  final bool autoRequestPermission;

  final EdgeInsetsGeometry? slideToCancelPadding;

  final int waveCount;

  final RecordConfig? recordConfig;

  final Decoration? decoration;

  final Widget? pauseWidget;

  final Widget? deleteWidget;

  final double? pauseBottomPositioned;

  final double? pauseRightPositioned;

  final Decoration? resumeDecoration;

  final Color? pauseHighlightColor;

  final Color? pauseSplashColor;

  final Color? pauseBackGroundColor;

  final Color? pauseIconColor;

  final Color? pauseBorderColor;

  // ignore: sort_constructors_first
  const SocialMediaRecorder({
    this.microphoneRequestPermission,
    this.sendButtonIcon,
    this.waveCount = 40,
    this.initRecordPackageWidth = 40,
    this.fullRecordPackageHeight = 50,
    this.fullRecordPackageWidth,
    this.maxRecordTimeInSecond,
    this.storeSoundRecoringPath = "",
    required this.sendRequestFunction,
    this.startRecording,
    this.stopRecording,
    required this.recordIcon,
    this.lockButton,
    this.counterBackGroundColor,
    this.recordIconWhenLockedRecord,
    this.recordIconBackGroundColor = Colors.blue,
    this.recordIconWhenLockBackGroundColor = Colors.blue,
    this.backGroundColor,
    this.cancelTextStyle,
    this.counterTextStyle,
    this.slideToCancelTextStyle,
    this.slideToCancelText = " Slide to Cancel >",
    this.cancelText = "Cancel",
    this.encode = AudioEncoderType.AAC,
    this.cancelTextBackGroundColor,
    this.radius,
    this.soundRecorderWhenLockedDecoration,
    this.soundRecorderWhenLockedWidth,
    this.counterWidth,
    this.borderPadding,
    this.micCounterWidget,
    this.durationLockRecordAnimatedPadding = const Duration(seconds: 1),
    this.animatedOpacityLockRecord = const Duration(milliseconds: 500),
    this.backGroundColorLockRecord,
    this.lockedIconLockRecord,
    this.unLockedIconLockRecord,
    this.borderRadiusLockRecord,
    this.heightLockRecord,
    this.counterPadding,
    this.soundRecorderWhenLockedMargin,
    this.autoRequestPermission = false,
    this.slideToCancelPadding,
    this.recordConfig,
    this.decoration,
    this.pauseWidget,
    this.deleteWidget,
    this.pauseBottomPositioned,
    this.pauseRightPositioned,
    this.resumeDecoration,
    this.pauseRecording,
    this.resumeRecording,
    this.deleteRecording,
    this.pauseHighlightColor,
    this.pauseSplashColor,
    this.pauseBackGroundColor,
    this.pauseIconColor,
    this.pauseBorderColor,
    Key? key,
  }) : super(key: key);

  @override
  _SocialMediaRecorder createState() => _SocialMediaRecorder();
}

class _SocialMediaRecorder extends State<SocialMediaRecorder>
    with WidgetsBindingObserver {
  late SoundRecordNotifier soundRecordNotifier;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    soundRecordNotifier = SoundRecordNotifier(
      maxRecordTime: widget.maxRecordTimeInSecond,
      startRecording: widget.startRecording ?? () {},
      stopRecording: widget.stopRecording ?? (String x) {},
      sendRequestFunction: widget.sendRequestFunction,
      waveCount: widget.waveCount,
      recordConfig: widget.recordConfig,
      pauseRecording: widget.pauseRecording,
      resumeRecording: widget.resumeRecording,
    );

    soundRecordNotifier.initialStorePathRecord =
        widget.storeSoundRecoringPath ?? "";
    soundRecordNotifier.isShow = false;
    if (widget.autoRequestPermission) {
      soundRecordNotifier.voidInitialSound();
    }

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    soundRecordNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      soundRecordNotifier.didChangeAppLifecycleState(
        state: state,
        context: context,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    soundRecordNotifier.maxRecordTime = widget.maxRecordTimeInSecond;
    soundRecordNotifier.startRecording = widget.startRecording ?? () {};
    soundRecordNotifier.stopRecording = widget.stopRecording ?? (String x) {};
    soundRecordNotifier.sendRequestFunction = widget.sendRequestFunction;
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => soundRecordNotifier),
        ],
        child: Consumer<SoundRecordNotifier>(
          builder: (context, value, _) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: makeBody(value),
            );
          },
        ));
  }

  Widget makeBody(SoundRecordNotifier state) {
    return SizedBox(
      height: widget.fullRecordPackageHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onVerticalDragUpdate: (scrollUpdate) {
              state.updateScrollVerticalValue(scrollUpdate.globalPosition);
            },
            onHorizontalDragUpdate: (scrollEnd) {
              state.updateScrollHorizontalValue(
                scrollEnd.globalPosition,
                context,
              );
            },
            onHorizontalDragEnd: (x) {
              if (state.buttonPressed && !state.isLocked) {
                state.finishRecording();
              }
            },
            child: recordVoice(state),
          )
        ],
      ),
    );
  }

  Widget recordVoice(SoundRecordNotifier state) {
    if (state.lockScreenRecord == true) {
      return SoundRecorderWhenLockedDesign(
        cancelText: widget.cancelText,

        fullRecordPackageHeight: widget.fullRecordPackageHeight,
        // cancelRecordFunction: widget.cacnelRecording ?? () {},
        sendButtonIcon: widget.sendButtonIcon,
        cancelTextBackGroundColor: widget.cancelTextBackGroundColor,
        cancelTextStyle: widget.cancelTextStyle,
        counterBackGroundColor: widget.counterBackGroundColor,
        recordIconWhenLockBackGroundColor:
            widget.recordIconWhenLockBackGroundColor ?? Colors.blue,
        counterTextStyle: widget.counterTextStyle,
        recordIconWhenLockedRecord: widget.recordIconWhenLockedRecord,
        sendRequestFunction: widget.sendRequestFunction,
        soundRecordNotifier: state,
        stopRecording: widget.stopRecording,
        soundRecorderWhenLockedWidth: widget.soundRecorderWhenLockedWidth,
        soundRecorderWhenLockedDecoration:
            widget.soundRecorderWhenLockedDecoration,
        soundRecorderWhenLockedMargin: widget.soundRecorderWhenLockedMargin,
        counterWidth: widget.counterWidth,
        micCounterWidget: widget.micCounterWidget,
        counterPadding: widget.counterPadding,
        pauseWidget: widget.pauseWidget,
        deleteWidget: widget.deleteWidget,
        pauseBottomPositioned: widget.pauseBottomPositioned,
        pauseRightPositioned: widget.pauseRightPositioned,
        resumeDecoration: widget.resumeDecoration,
        pauseHighlightColor: widget.pauseHighlightColor,
        pauseSplashColor: widget.pauseSplashColor,
        pauseBackGroundColor: widget.pauseBackGroundColor,
        pauseIconColor: widget.pauseIconColor,
        pauseBorderColor: widget.pauseBorderColor,
        deleteRecording: widget.deleteRecording,
      );
    }

    return Listener(
      onPointerDown: (details) async {
        state.vibrationPresetAlarm();
        final currentStatus = await state.currentStatusPermission();
        if (currentStatus != PermissionStatus.granted) {
          widget.microphoneRequestPermission?.call();
          return;
        }
        state.setNewInitialDraggableHeight(details.position.dy);
        state.resetEdgePadding();

        state.record(
          startRecord: widget.startRecording,
        );
      },
      onPointerUp: (details) async {
        if (!state.isLocked) {
          state.finishRecording();
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: soundRecordNotifier.isShow ? 0 : 300),
        height: widget.fullRecordPackageHeight,
        width: (soundRecordNotifier.isShow)
            ? widget.soundRecorderWhenLockedWidth ??
                MediaQuery.of(context).size.width
            : widget.initRecordPackageWidth,
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(right: state.edge),
                child: Container(
                  decoration: soundRecordNotifier.isShow
                      ? widget.decoration
                      : BoxDecoration(
                          borderRadius: soundRecordNotifier.isShow
                              ? BorderRadius.circular(12)
                              : widget.radius != null &&
                                      !soundRecordNotifier.isShow
                                  ? widget.radius
                                  : BorderRadius.circular(0),
                          color: widget.backGroundColor ?? Colors.transparent,
                        ),
                  child: Stack(
                    children: [
                      Center(
                        child: ShowMicWithText(
                          initRecordPackageWidth: widget.initRecordPackageWidth,
                          counterBackGroundColor: widget.counterBackGroundColor,
                          backGroundColor: widget.recordIconBackGroundColor,
                          fullRecordPackageHeight:
                              widget.fullRecordPackageHeight,
                          recordIcon: widget.recordIcon,
                          shouldShowText: soundRecordNotifier.isShow,
                          soundRecorderState: state,
                          slideToCancelTextStyle: widget.slideToCancelTextStyle,
                          slideToCancelText: widget.slideToCancelText,
                          slideToCancelPadding: widget.slideToCancelPadding,
                        ),
                      ),
                      if (soundRecordNotifier.isShow)
                        ShowCounter(
                          counterBackGroundColor: widget.counterBackGroundColor,
                          soundRecorderState: state,
                          counterHeight: widget.fullRecordPackageHeight,
                          counterTextStyle: widget.counterTextStyle,
                          counterWidth: widget.counterWidth,
                          borderPadding: widget.borderPadding,
                          micCounterWidget: widget.micCounterWidget,
                          counterPadding: widget.counterPadding,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: widget.heightLockRecord ?? 60,
              child: LockRecord(
                soundRecorderState: state,
                lockIcon: widget.lockButton,
                backGroundColorLockRecord: widget.backGroundColorLockRecord,
                durationLockRecordAnimatedPadding:
                    widget.durationLockRecordAnimatedPadding,
                animatedOpacityLockRecord: widget.animatedOpacityLockRecord,
                borderRadiusLockRecord: widget.borderRadiusLockRecord,
                lockedIconLockRecord: widget.lockedIconLockRecord,
                unLockedIconLockRecord: widget.unLockedIconLockRecord,
              ),
            )
          ],
        ),
      ),
    );
  }
}
