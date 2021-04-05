// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:introduction_screen/introduction_screen.dart';

// 🌎 Project imports:
import 'package:flybis/models/flybis_model.dart';
import 'package:flybis/plugins/image_network/mobile.dart';
import 'package:flybis/services/flybis_service.dart';

// Firestore

class IntroductionView extends StatefulWidget {
  IntroductionView();

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
          return Text('');
        }

        List<PageViewModel> pages = [];

        snapshot.data.forEach(
          (FlybisIntroduction page) {
            pages.add(
              PageViewModel(
                title: page.title,
                body: page.body,
                image: ImageNetwork.cachedNetworkImage(imageUrl: page.image),
              ),
            );
          },
        );

        if (pages.isEmpty) {
          Navigator.pop(context);
        }

        return IntroductionScreen(
          pages: pages,
          done: Text("Done"),
          onDone: () {
            Navigator.pop(context);
          },
          next: Text("Next"),
          showNextButton: true,
          skip: Text("Skip"),
          showSkipButton: true,
        );
      },
    );
  }
}
