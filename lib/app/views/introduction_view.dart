// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:introduction_screen/introduction_screen.dart';

// 🌎 Project imports:
import 'package:flybis/app/data/models/flybis_model.dart';
import 'package:flybis/plugins/image_network/mobile.dart';
import 'package:flybis/app/data/services/flybis_service.dart';

// Firestore

class IntroductionView extends StatefulWidget {
  const IntroductionView();

  @override
  _IntroductionViewState createState() => _IntroductionViewState();
}

class _IntroductionViewState extends State<IntroductionView> {
  _IntroductionViewState();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FlybisService().streamIntroductions(),
      builder: (BuildContext context,
          AsyncSnapshot<List<FlybisIntroduction>> snapshot) {
        if (!snapshot.hasData) {
          return const Text('');
        }

        List<PageViewModel> pages = [];

        for (var page in snapshot.data!) {
            pages.add(
              PageViewModel(
                title: page.title,
                body: page.body,
                image: ImageNetwork.cachedNetworkImage(imageUrl: page.image),
              ),
            );
          }

        if (pages.isEmpty) {
          Navigator.pop(context);
        }

        return IntroductionScreen(
          pages: pages,
          done: const Text("Done"),
          onDone: () {
            Navigator.pop(context);
          },
          next: const Text("Next"),
          showNextButton: true,
          skip: const Text("Skip"),
          showSkipButton: true,
        );
      },
    );
  }
}
