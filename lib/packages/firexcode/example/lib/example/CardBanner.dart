import 'package:firexcode/firexcode.dart';

class ExampleCardBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return <Widget>[
      XCardBanner(
        onTap: () {},
        margin: EdgeInsets.all(20),
        rounded: 10,
        color: Colors.black,
        shadowColor: Colors.blue,
        blurRadius: 5.0,
        title: 'Bonus'.xH2Text(),
        subTitle:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore'
                .xTextColorWhite()
                .xExpandableText(
                    expand: 'More details'.xTextColorWhite(),
                    unexpand: 'Less details'.xTextColorWhite(),
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start),
      ).fadeIn().toCenter(),
      XCardBanner(
        rightSideChild: Icons.add
            .xIcons()
            .xCircleAvatar(radius: 35, backgroundColor: Colors.white),
        onTap: () {},
        margin: EdgeInsets.all(20),
        rounded: 10,
        color: Color(0xFF3d6dfe),
        shadowColor: Colors.blue,
        blurRadius: 5.0,
        title: 'Bonus'.xH2Text(),
        subTitle:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore'
                .xTextColorWhite()
                .xExpandableText(
                    expand: 'More details'.xTextColorWhite(),
                    unexpand: 'Less details'.xTextColorWhite(),
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start),
      ).fadeIn().toCenter(),
      XCardBanner(
        rightSideChild:
            'https://raw.githubusercontent.com/zeeshux7860/firexcode/master/example/logo.png'
                .xImageNetwork()
                .xap(value: 10.0)
                .xCircleAvatar(radius: 35, backgroundColor: Colors.white),
        onTap: () {},
        margin: EdgeInsets.all(20),
        rounded: 10,
        color: Colors.orange,
        shadowColor: Colors.blue,
        blurRadius: 5.0,
        title: 'Bonus'.xH2Text(),
        subTitle:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore'
                .xTextColorWhite(),
        button: 'Know More'.xTextColorBlack().cardBannerButton(
            buttonColor: Colors.white, onTap: () {}, rounded: 5),
      ).fadeIn().toCenter(),
    ].xListView().xScaffold(
        backgroundColor: Colors.white,
        appBar: 'XCardBanner'.xTextColorBlack().xAppBar(
              brightness: Brightness.light,
              centerTitle: true,
              backgroundColor: Colors.white,
            ));
  }
}
