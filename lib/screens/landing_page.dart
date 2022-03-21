import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tflite_audio/tflite_audio.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final isRecording = ValueNotifier<bool>(false);
  Stream<Map<dynamic, dynamic>>? result;
  final String model = 'assets/model/google_teach_machine_model.tflite';
  final String label = 'assets/model/google_teach_machine_label.txt';
  final String inputType = 'rawAudio';
  final int sampleRate = 44100;
  final int bufferSize = 22016;
  bool livePlaying = false;
  final bool outputRawScores = false;
  final int numOfInferences = 5;
  final bool isAsset = true;
  String emotion = 'Background Noise';

  @override
  void initState() {
    super.initState();
    TfliteAudio.loadModel(
      inputType: inputType,
      outputRawScores: outputRawScores,
      model: model,
      label: label,
    );
  }

  void getResult() {
    result = TfliteAudio.startAudioRecognition(
      sampleRate: sampleRate,
      bufferSize: bufferSize,
      numOfInferences: numOfInferences,
    );
    result?.listen((event) {
      setState(() {
        emotion = event["recognitionResult"].toString();
        emotion = emotion.substring(2, emotion.length);
      });
      debugPrint(
          "Recognition Result: " + event["recognitionResult"].toString());
    }).onDone(() => isRecording.value = false);
  }

  Widget inferenceTimeWidget(String result) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text(
        result,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    border: Border.all(
                      color: Colors.transparent,
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Flexible(
                    child: Text(
                      emotion,
                      style: TextStyle(
                        color: isRecording.value ? Colors.white : Colors.grey,
                        fontSize: MediaQuery.textScaleFactorOf(context) * 48,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Spacer(),
                isRecording.value
                    ? Lottie.asset('assets/lottie/recording.json')
                    : Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          border: Border.all(
                            color: Colors.transparent,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                      ),
                const Spacer(),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: ValueListenableBuilder(
          valueListenable: isRecording,
          builder: (context, value, widget) {
            if (value == false) {
              return FloatingActionButton(
                onPressed: () {
                  isRecording.value = true;
                  setState(() {
                    getResult();
                  });
                },
                backgroundColor: Colors.green,
                child: const Icon(Icons.play_arrow),
              );
            } else {
              return FloatingActionButton(
                onPressed: () {
                  debugPrint('Audio Recognition Stopped');
                  TfliteAudio.stopAudioRecognition();
                  setState(() {
                    isRecording.value = false;
                  });
                },
                backgroundColor: Colors.red,
                child: const Icon(Icons.pause),
              );
            }
          },
        ),
      ),
    );
  }
}
