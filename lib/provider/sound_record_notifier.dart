import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:social_media_recorder/audio_encoder_type.dart';
import 'package:vibration/vibration.dart';
import 'package:vibration/vibration_presets.dart';

enum SoundRecordStatusEnum {
  initial,
  recording,
  paused,
  resumed,
}

class SoundRecordNotifier extends ChangeNotifier {
  int _counter = 0;
  int _localCounterForMaxRecordTime = 0;
  GlobalKey key = GlobalKey();
  int? maxRecordTime;
  final List<double> _amplitudeTimeline = [];
  AudioPlayer audioPlayer = AudioPlayer();
  final List<double> _calculatedWaveform = [];
  Timer? _recorderSubscription;

  final OverlayPortalController pauseOverlayPortalController =
      OverlayPortalController();

  SoundRecordStatusEnum status = SoundRecordStatusEnum.initial;

  /// This Timer Just For wait about 1 second until starting record
  Timer? _timer;

  /// This time for counter wait about 1 send to increase counter
  Timer? _timerCounter;

  /// Use last to check where the last draggable in X
  double last = 0;

  /// Used when user enter the needed path
  String initialStorePathRecord = "";

  /// recording mp3 sound Object
  AudioRecorder recordMp3 = AudioRecorder();

  /// recording mp3 sound to check if all permisiion passed
  bool _isAcceptedPermission = false;

  /// used to update state when user draggable to the top state
  double currentButtonHeihtPlace = 0;

  /// used to know if isLocked recording make the object true
  /// else make the object isLocked false
  bool isLocked = false;

  /// when pressed in the recording mic button convert change state to true
  /// else still false
  bool isShow = false;

  /// to show second of recording
  late int second;

  /// to show minute of recording
  late int minute;

  /// to know if pressed the button
  late bool buttonPressed;

  /// used to update space when dragg the button to left
  late double edge;
  late bool loopActive;

  /// store final path where user need store mp3 record
  late bool startRecord;

  /// store the value we draggble to the top
  late double heightPosition;

  /// store status of record if lock change to true else
  /// false
  late bool lockScreenRecord;
  late String mPath;
  late String tempPlaybackPath;

  /// function called when start recording
  Function()? startRecording;
  Function(File soundFile, Duration time, List<int> waveFrom)
      sendRequestFunction;

  /// function called when stop recording, return the recording time (even if time < 1)
  Function(String time)? stopRecording;

  Function()? pauseRecording;

  Function()? resumeRecording;

  late AudioEncoderType encode;

  final int waveCount;

  late RecordConfig? recordConfig;

  final int minWaves;

  final double minWaveHeight;

  final double maxWaveHeight;

  // ignore: sort_constructors_first

  SoundRecordNotifier({
    required this.stopRecording,
    required this.sendRequestFunction,
    required this.pauseRecording,
    required this.resumeRecording,
    required this.startRecording,
    required this.waveCount,
    this.edge = 0.0,
    this.minute = 0,
    this.second = 0,
    this.buttonPressed = false,
    this.loopActive = false,
    this.mPath = '',
    tempPlaybackPath = '',
    this.startRecord = false,
    this.heightPosition = 0,
    this.lockScreenRecord = false,
    this.encode = AudioEncoderType.AAC,
    this.maxRecordTime,
    this.recordConfig = const RecordConfig(),
    this.minWaves = 32,
    this.minWaveHeight = 4.0,
    this.maxWaveHeight = 4.0,
  });

  /// To increase counter after 1 sencond
  void _mapCounterGenerater() {
    _timerCounter = Timer(const Duration(seconds: 1), () {
      _increaseCounterWhilePressed();
      if (buttonPressed) _mapCounterGenerater();
    });
  }

  List<double> get calculatedWaveform => _calculatedWaveform;

  int maxWaveCount(BuildContext context) =>
      (MediaQuery.sizeOf(context).width - 224) ~/ 4;

  Future<void> finishRecording() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (buttonPressed) {
      if (second > 1 || minute > 0) {
        String path = mPath;
        Duration _time = Duration(minutes: minute, seconds: second);
        final step = _amplitudeTimeline.length < waveCount
            ? 1
            : (_amplitudeTimeline.length / waveCount).round();
        final waveform = <int>[];
        for (var i = 0; i < _amplitudeTimeline.length; i += step) {
          waveform.add((_amplitudeTimeline[i] / 100 * 1024).round());
        }
        sendRequestFunction(File.fromUri(Uri(path: path)), _time, waveform);
        stopRecording!(minute.toString() + ":" + second.toString());
        _recorderSubscription?.cancel();
        resetEdgePadding();
        status = SoundRecordStatusEnum.initial;

        return;
      }
    }
    stopRecording!('');
    resetEdgePadding();
    status = SoundRecordStatusEnum.initial;
  }

  /// used to reset all value to initial value when end the record
  resetEdgePadding() async {
    if (_initWidth == -33) {
      RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
      Offset position = box.localToGlobal(Offset.zero);
      _initWidth = position.dx;
    }
    _localCounterForMaxRecordTime = 0;
    isLocked = false;
    edge = 0;
    buttonPressed = false;
    second = 0;
    minute = 0;
    isShow = false;
    key = GlobalKey();
    heightPosition = 0;
    lockScreenRecord = false;
    _amplitudeTimeline.clear();
    _calculatedWaveform.clear();
    mPath = '';
    status = SoundRecordStatusEnum.initial;
    if (_timer != null) _timer!.cancel();
    if (_timerCounter != null) _timerCounter!.cancel();
    if (audioPlayer.playing) {
      await audioPlayer.stop();
    }
    try {
      final value = await recordMp3.isRecording();

      if (value == true) {
        recordMp3.stop().then((x) {
          recordMp3 = AudioRecorder();
        }).onError((error, stackTrace) {
          debugPrint('Error stopping recording: $error');
          stopRecording!('');
        });
      }
    } catch (e) {
      debugPrint('Error checking recording status: $e');
      stopRecording!('');
    }
    notifyListeners();
  }

  String _getSoundExtention() {
    if (encode == AudioEncoderType.AAC ||
        encode == AudioEncoderType.AAC_LD ||
        encode == AudioEncoderType.AAC_HE ||
        encode == AudioEncoderType.OPUS) {
      return ".m4a";
    } else {
      return ".3gp";
    }
  }

  /// used to get the current store path
  Future<String> getFilePath() async {
    String _sdPath = "";
    Directory tempDir = await getTemporaryDirectory();
    _sdPath =
        initialStorePathRecord.isEmpty ? tempDir.path : initialStorePathRecord;
    var d = Directory(_sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    DateTime now = DateTime.now();
    String convertedDateTime =
        "${_counter.toString()}${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    // print("the current data is $convertedDateTime");
    _counter++;
    String storagePath =
        _sdPath + "/" + convertedDateTime + _getSoundExtention();
    mPath = storagePath;
    return storagePath;
  }

  /// used to change the draggable to top value
  setNewInitialDraggableHeight(double newValue) {
    currentButtonHeihtPlace = newValue;
  }

  double _initWidth = -33;

  updateScrollVerticalValue(Offset currentValue) {
    /// take the diffrent between the origin and the current
    /// draggable to the top place
    double hightValue = currentButtonHeihtPlace - currentValue.dy;

    /// if reached to the max draggable value in the top
    if (hightValue >= 50) {
      isLocked = true;
      lockScreenRecord = true;
      hightValue = 50;
    }
    if (hightValue < 0) hightValue = 0;
    heightPosition = hightValue;
    lockScreenRecord = isLocked;

    if (lockScreenRecord) {
      pauseOverlayPortalController.show();
    }
    notifyListeners();
  }

  /// used to change the draggable to top value
  /// or To The X vertical
  /// and update this value in screen
  updateScrollHorizontalValue(Offset currentValue, BuildContext context) async {
    if (buttonPressed == true) {
      final x = currentValue;

      updateScrollVerticalValue(currentValue);

      /// this operation for update X oriantation
      /// draggable to the left or right place
      try {
        RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
        Offset position = box.localToGlobal(Offset.zero);
        if (position.dx <= MediaQuery.of(context).size.width * 0.6) {
          String _time = minute.toString() + ":" + second.toString();
          if (stopRecording != null) {
            stopRecording!(_time);
            _recorderSubscription?.cancel();
          }
          resetEdgePadding();
        } else if (x.dx >= MediaQuery.of(context).size.width) {
          edge = 0;
          edge = 0;
        } else {
          edge = (_initWidth - x.dx) > 0 ? (_initWidth - x.dx) : 0;

          // if (x.dx <= MediaQuery.of(context).size.width * 0.5) {}
          // if (last < x.dx) {
          //   edge = edge -= x.dx / 200;
          //   if (edge < 0) {
          //     edge = 0;
          //   }
          // } else if (last > x.dx) {
          //   edge = edge += x.dx / 200;
          // }
          // last = x.dx;
        }
        // ignore: empty_catches
      } catch (e) {}
      notifyListeners();
    }
  }

  /// this function to manage counter value
  /// when reached to 60 sec
  /// reset the sec and increase the min by 1
  _increaseCounterWhilePressed() async {
    if (status == SoundRecordStatusEnum.paused) {
      return;
    }
    if (loopActive) {
      return;
    }

    loopActive = true;
    if (maxRecordTime != null) {
      if (_localCounterForMaxRecordTime >= maxRecordTime!) {
        loopActive = false;
        finishRecording();
      }
      _localCounterForMaxRecordTime++;
    }
    second = second + 1;
    buttonPressed = buttonPressed;
    if (second == 60) {
      second = 0;
      minute = minute + 1;
    }

    notifyListeners();
    loopActive = false;
    notifyListeners();
  }

  /// this function to start record voice
  record({
    Function()? startRecord,
  }) async {
    isShow = true;

    try {
      buttonPressed = true;
      status = SoundRecordStatusEnum.recording;
      String recordFilePath = await getFilePath();
      if (_timer != null) {
        _timer?.cancel();
      }

      _recorderSubscription?.cancel();
      _recorderSubscription =
          Timer.periodic(const Duration(milliseconds: 100), (_) async {
        try {
          final amplitude = await recordMp3.getAmplitude();
          var value = 100 + amplitude.current * 2;
          value = value < 1 ? 1 : value;
          _amplitudeTimeline.add(value);
        } catch (e) {
          debugPrint('Error getting amplitude: $e');
          rethrow;
        }
      });
      _timer = Timer(const Duration(milliseconds: 100), () async {
        try {
          await recordMp3.start(
            recordConfig ?? const RecordConfig(),
            path: recordFilePath,
          );
        } catch (e) {
          debugPrint('Error starting recording: $e');
          rethrow;
        }
      });

      if (startRecord != null) {
        startRecord();
      }

      _mapCounterGenerater();
      notifyListeners();
    } catch (e) {
      debugPrint('Error starting recording: $e');
      stopRecording!('');
    }
    notifyListeners();
  }

  Future<PermissionStatus> currentStatusPermission() async {
    final status = await Permission.microphone.status;
    return status;
  }

  /// to check permission
  voidInitialSound() async {
    // if (Platform.isIOS) _isAcceptedPermission = true;

    if (_isAcceptedPermission) return;

    startRecord = false;
    final status = await Permission.microphone.status;
    if (status.isGranted) {
      final result = await Permission.storage.request();
      if (result.isGranted) {
        _isAcceptedPermission = true;
      }
    }
  }

  Future<void> vibrationPresetAlarm() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(preset: VibrationPreset.singleShortBuzz);
    }
  }

  void didChangeAppLifecycleState({
    required AppLifecycleState state,
    required BuildContext context,
  }) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      if (buttonPressed || isLocked) {
        handlePauseOrResumeAudio(
          context: context,
        );
      }
    }
  }

  Future<void> handlePauseOrResumeAudio({
    required BuildContext context,
  }) async {
    if (status == SoundRecordStatusEnum.recording) {
      await handlePauseAudio(context: context);
    }
  }

  Future<void> handlePauseAudio({
    required BuildContext context,
  }) async {
    if (status != SoundRecordStatusEnum.recording) return;
    final step = _amplitudeTimeline.length < waveCount
        ? 1
        : (_amplitudeTimeline.length / waveCount).round();
    final waveform = <int>[];
    for (var i = 0; i < _amplitudeTimeline.length; i += step) {
      waveform.add((_amplitudeTimeline[i] / 100 * 1024).round());
    }

    pauseRecording?.call();
    final waveForm = calculateWaveForm(
          eventWaveForm: waveform,
          waveCount: calculateWaveCountAuto(
            minWaves: minWaves,
            maxWaves: maxWaveCount(context),
            durationInSeconds: (minute * 60) + second,
          ),
        ) ??
        [];

    final waveFromHeight = calculateWaveHeight(
      waveform: waveForm,
      minHeight: minWaveHeight,
      maxHeight: maxWaveHeight,
    );

    if (waveform.isNotEmpty) {
      _calculatedWaveform.clear();
      _calculatedWaveform.addAll(waveFromHeight);
    }
    try {
      final finalPath = await recordMp3.stop();

      final audio = audioPlayer = AudioPlayer();

      await audio.setFilePath(finalPath ?? mPath);

      pauseOverlayPortalController.hide();

      status = SoundRecordStatusEnum.paused;
    } catch (e) {
      debugPrint('Error pausing recording: $e');
    }
    // Schedule notifyListeners for next frame to avoid widget tree lock
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void handlePlayOrPausePreviewAudio() {
    if (audioPlayer.isAtEndPosition == true) {
      audioPlayer.seek(Duration.zero);
    } else if (audioPlayer.playing == true) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
    // Schedule notifyListeners for next frame to avoid widget tree lock
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  int calculateWaveCountAuto({
    required int minWaves,
    required int maxWaves,
    required int durationInSeconds,
  }) {
    final double progress =
        min(1.0, (durationInSeconds - 30) / 90); // 0-1 over 30-120s
    final int rangeStart = (minWaves + (maxWaves - minWaves) * 0.7).round();
    final int rangeSize = ((maxWaves - minWaves) * 0.3).round();
    return (rangeStart + rangeSize * progress).round();
  }

  List<int>? calculateWaveForm({
    required List<int>? eventWaveForm,
    required int waveCount,
  }) {
    // Handle edge cases
    if (eventWaveForm == null || eventWaveForm.isEmpty || waveCount <= 0) {
      return null;
    }
    if (waveCount == 1) return [eventWaveForm[eventWaveForm.length ~/ 2]];
    // If we need more data points than we have, generate fake data by repeating the waveform
    if (waveCount > eventWaveForm.length) {
      final List<int> result = [];
      for (int i = 0; i < waveCount; i++) {
        // Cycle through the original waveform to generate fake data
        final int value = eventWaveForm[i % eventWaveForm.length];
        result.add(value);
      }

      // Apply value clamping
      return result.map((i) => i == 0 ? 1 : (i > 1024 ? 1024 : i)).toList();
    }

    // Use interpolation-based sampling instead of insert/remove loops
    final List<int> result = [];
    final double step = (eventWaveForm.length - 1) / (waveCount - 1);

    for (int i = 0; i < waveCount; i++) {
      final double exactIndex = i * step;
      final int lowerIndex = exactIndex.floor();
      final int upperIndex =
          (lowerIndex + 1).clamp(0, eventWaveForm.length - 1);

      int sampledValue;
      if (lowerIndex == upperIndex) {
        sampledValue = eventWaveForm[lowerIndex];
      } else {
        final double fraction = exactIndex - lowerIndex;
        final double interpolated = eventWaveForm[lowerIndex] * (1 - fraction) +
            eventWaveForm[upperIndex] * fraction;
        sampledValue = interpolated.round();
      }

      result.add(sampledValue);
    }

    // Apply the same value clamping as the original function
    return result.map((i) => i == 0 ? 1 : (i > 1024 ? 1024 : i)).toList();
  }

  List<double> calculateWaveHeight({
    required List<int> waveform,
    required double minHeight, // B
    required double maxHeight, // A
  }) {
    if (waveform.isEmpty) return [];

    final int rawMax = waveform.reduce((a, b) => a > b ? a : b);
    final int rawMin = waveform.reduce((a, b) => a < b ? a : b);

    // Avoid division by zero
    if (rawMax == rawMin) {
      return List<double>.filled(waveform.length, (maxHeight + minHeight) / 2);
    }

    return waveform.map((x) {
      final t = (x - rawMin) / (rawMax - rawMin);
      return minHeight + t * (maxHeight - minHeight);
    }).toList();
  }

  @override
  dispose() {
    // Cancel all timers and subscriptions
    _recorderSubscription?.cancel();
    _timer?.cancel();
    _timerCounter?.cancel();

    // Stop and dispose audio player
    audioPlayer.stop();
    audioPlayer.dispose();

    // Cancel recording
    recordMp3.cancel();

    // Call super.dispose() last to clean up ChangeNotifier
    super.dispose();
  }
}

extension AudioPlayExtension on AudioPlayer {
  bool get isAtEndPosition {
    final duration = this.duration;
    if (duration == null) return true;
    return position >= duration;
  }
}
