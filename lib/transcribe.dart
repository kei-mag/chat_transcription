import 'package:chat_transcription/main.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class TranscriptionPage extends StatefulWidget {
  const TranscriptionPage(this.speechToText, {super.key});

  final stt.SpeechToText speechToText;

  @override
  State<StatefulWidget> createState() => _TranscriptionPageState();
}

class _TranscriptionPageState extends State<TranscriptionPage> {
  String _currentRecognizedWords = "";
  final List<Text> _speechHistory = [];

  @override
  void initState() {
    super.initState();
    _startRepeatedlyListening();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: widget.speechToText.isListening
            ? Text("会話を聞き取り中・・・")
            : Text("聞き取り一時停止中・・・（右下のボタンで再開）"),
      ),
      body: Container(
        margin: EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("【文字起こしの内容】",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                // padding: EdgeInsets.all(25),
                reverse: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: 1.2,
                  children: [
                        const Text("ここに会話が文字起こしされていきます...",
                            style: TextStyle(color: Colors.black38)),
                        const Text("")
                      ] +
                      _speechHistory +
                      [
                        Text(
                          _currentRecognizedWords,
                          style:
                              TextStyle(decoration: TextDecoration.underline),
                        )
                      ],
                ),
              ),
            ),
            Divider(),
            FilledButton(
                onPressed: () {
                  _stopListening();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Text("会話を終わる"))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.speechToText.isListening
            ? _stopListening
            : _startRepeatedlyListening,
        child: widget.speechToText.isListening
            ? Icon(Icons.stop_circle)
            : Icon(Icons.play_circle),
      ),
    );
  }

  void _startRepeatedlyListening() async {
    if (widget.speechToText.isNotListening) {
      _currentRecognizedWords = "";
      await widget.speechToText.listen(
        pauseFor: Duration(minutes: 1),
        listenOptions: stt.SpeechListenOptions(
            autoPunctuation: true, listenMode: stt.ListenMode.dictation),
        onResult: (result) {
          _currentRecognizedWords = result.recognizedWords;
          if (result.finalResult) {
            setState(() => _speechHistory.add(Text(result.recognizedWords)));
            _currentRecognizedWords = "";
            _startRepeatedlyListening();
          } else {
            setState(() {});
          }
        },
      );
    }
    setState(() {});
  }

  void _stopListening() async {
    await widget.speechToText.stop();
    _currentRecognizedWords = "";
    setState(() {});
  }
}
