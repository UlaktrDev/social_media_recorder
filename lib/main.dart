import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:social_media_recorder/audio_encoder_type.dart';
import 'package:social_media_recorder/screen/social_media_recorder.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowMaterialGrid: false,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 140, left: 4, right: 20),
          child: Align(
            alignment: Alignment.centerRight,
            child: SocialMediaRecorder(
              autoRequestPermission: true,
              // maxRecordTimeInSecond: 5,
              microphoneRequestPermission: () async {
                // function called when you need to request the permission
                await Permission.microphone.request();
                await Permission.manageExternalStorage.request();
                await Permission.storage.request();
              },
              recordIcon: const Icon(
                Icons.keyboard_voice_outlined,
                color: Colors.blue,
              ),
              soundRecorderWhenLockedWidth: 350,
              startRecording: () {
                // function called when start recording
              },
              stopRecording: (_time) {
                // function called when stop recording, return the recording time
              },
              sendRequestFunction: (soundFile, _time, waveFrom) {
                debugPrint(
                  "the current path is ${soundFile.path} and the time is $_time seconds and waveFrom is $waveFrom",
                );
              },
              encode: AudioEncoderType.AAC,
              // storeSoundRecoringPath: "/storage/emulated/0/new_record_sound",
            ),
          ),
        ),
      ),
    );
  }
}
