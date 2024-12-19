import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class WaitTool extends StatelessWidget {
  const WaitTool({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: Center(
        child: SpinKitThreeInOut(
          color: Theme.of(context).primaryColor,
          size: 30.0,
        ),
      ),
    );
  }
}