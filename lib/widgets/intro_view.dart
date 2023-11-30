import 'package:flutter/material.dart';

import '../models/intro_model.dart';

class IntroView extends StatelessWidget {
  final IntroModel introModel;
  const IntroView({Key? key, required this.introModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        flex: 8,
        child: Center(
            child: SizedBox(
                width: MediaQuery.of(context).size.width - 120,
                child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.asset(
                      introModel.assetsImage,
                      fit: BoxFit.fill,
                    )))),
      ),
      Expanded(
        child: Text(introModel.titleText,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            )),
      ),
      const Expanded(flex: 1, child: SizedBox()),
    ]);
  }
}
