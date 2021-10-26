import 'package:firexcode/firexcode.dart';

class ExampleGradientCardBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return <Widget>[
      XGradientCardBanner(
              gradient: [Colors.orange, Colors.pink].xLGrepeated(
                  begin: Alignment.topLeft, end: Alignment.bottomLeft),
              shadowColor: Colors.pink,
              blurRadius: 5.0,
              title: 'Bonus'.xH2Text(),
              subTitle:
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore'
                      .xTextColorWhite(),
              button: 'know more'.xTextColorWhite().cardBannerButton(
                  onTap: () {}, rounded: 5.0, buttonColor: Colors.black))
          .xap(value: 20.0),
      20.0.sizedHeight(),
      XGradientCardBanner(
        gradient: [Colors.cyan, Colors.indigo].xLGrepeated(
          begin: Alignment.topLeft,
          end: Alignment(0.7, 0.0),
        ),
        shadowColor: Colors.blue,
        blurRadius: 5.0,
        title: 'Bonus'.xH2Text(),
        subTitle:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore'
                .xTextColorWhite()
                .xExpandableText(
                    expand: 'More details'.xTextColorWhite(),
                    unexpand: 'Less details'.xTextColorWhite(),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start),
      )
          .animation(configMap: XAnimationType.fadeIn, autoPlay: true)
          .xlrp(l: 20.0, r: 20.0),
      20.0.sizedHeight(),
      XGradientCardBanner(
              onTap: () {},
              spreadRadius: 0.2,
              rightSideChild: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 35,
                child: Icon(
                  Icons.ac_unit,
                  size: 30,
                ),
              ),
              rounded: 10,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment(
                    0.8, 0.0), // 10% of the width, so there are ten blinds.
                colors: [
                  Colors.deepPurple,
                  Colors.purple,
                ], // whitish to gray
                tileMode:
                    TileMode.repeated, // repeats the gradient over the canvas
              ),
              shadowColor: Colors.blue,
              blurRadius: 5.0,
              title: 'Bonus'.xH2Text(),
              subTitle:
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore'
                      .xTextColorWhite(),
              button:
                  'know more'.xTextColorWhite().cardBannerButton(onTap: () {}))
          .animation(configMap: XAnimationType.fadeIn, autoPlay: true)
          .xap(value: 20.0),
    ].xListView().xScaffold(
        backgroundColor: Colors.white,
        appBar: 'XGradientCardBanner'.xTextColorBlack().xAppBar(
              brightness: Brightness.light,
              centerTitle: true,
              backgroundColor: Colors.white,
            ));
  }
}
