import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ButtonListenComponent extends StatefulWidget {
  final bool small;
  final void Function(String value) onChange;
  final void Function() onError;
  const ButtonListenComponent({super.key, this.small = false, required this.onChange, required this.onError});

  @override
  State<ButtonListenComponent> createState() => _ButtonListenComponentState();
}

class _ButtonListenComponentState extends State<ButtonListenComponent> {
  var _isPressed = false;
  final _speechToText = SpeechToText();
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _onPressed() async {
    if(_speechEnabled) {
      await _speechToText.listen(onResult: _onSpeechResult);
      setState(() {
        _isPressed = true;
      });
    } else {
      widget.onError();
    }
  }

  void _onReleased() async {
    setState(() {
      _isPressed = false;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    await _speechToText.stop();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if(!_isPressed) {
      widget.onChange(result.recognizedWords);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if(_isPressed) {
            _onReleased();
          } else {
            _onPressed();
          }
        },
        child: !widget.small
        ? AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 100.0,
            height: 100.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isPressed ? Colors.blue : Theme.of(context).focusColor, // Cambia el color al presionar
              boxShadow: [
                BoxShadow(
                  color: _isPressed ? Colors.blueAccent : Colors.blue[900]!.withOpacity(0.5), // Agrega una sombra al presionar
                  spreadRadius: 5,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Icon(!_isPressed ? Icons.settings_voice_rounded : Icons.check_rounded, color: Colors.white, size: 60),
            ),
          )
        : Container(
            decoration: BoxDecoration(
              color: !_isPressed ? Colors.white10 : Colors.blue.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(!_isPressed ? Icons.settings_voice_rounded : Icons.check_rounded, color: Colors.white),
              ],
            ),
          ),
      );
  }
}