import 'package:firexcode/firexcode.dart';
import 'dart:math' as math;

class ExampleAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'Demo XMaterialApp'.xTextColorWhite(),
      ),
      body: <Widget>[
        'FadeIn'
            .xH1Text(color: Colors.black)
            .xContainer(padding: EdgeInsets.only(top: 20, left: 30)),
        20.0.sizedHeight(),
        'FadeIn'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .fadeIn(),
        'FadeIn Left'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .fadeInLeft(),
        'FadeIn Right'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .fadeInRight(),
        'FadeIn Down'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .fadeInDown(),
        'FadeIn Up'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .fadeInUp(),
        'FadeIn UpBig'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .fadeInUpBig(),
        'FadeIn DownBig'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .fadeInDownBig(),
        'FadeIn LeftBig'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .fadeInLeftBig(),
        'FadeIn RightBig'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .fadeInLeftBig(),
        'FadeOut'
            .xH1Text(color: Colors.black)
            .xContainer(padding: EdgeInsets.only(top: 20, left: 30)),
        20.0.sizedHeight(),
        'FadeOut'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .fadeOut(),
        'FadeOut Left'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .fadeOutLeft(),
        'FadeOut Right'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .fadeOutRight(),
        'FadeOut Down'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .fadeOutDown(),
        'FadeOut Up'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .fadeOutUp(),
        'FadeOut UpBig'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .fadeOutUpBig(),
        'FadeOut DownBig'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .fadeOutDownBig(),
        'FadeOut LeftBig'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .fadeOutLeftBig(),
        'FadeOut RightBig'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .fadeOutLeftBig(),
        'BounceIn'
            .xH1Text(color: Colors.black)
            .xContainer(padding: EdgeInsets.only(top: 20, left: 30)),
        'bounceIn Left'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .bounceInLeft(),
        'bounceIn Right'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .bounceInRight(),
        'bounceIn Down'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .bounceInDown(),
        'bounceIn Up'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .bounceInUp(),
        20.0.sizedHeight(),
        'Elasticin'
            .xH1Text(color: Colors.black)
            .xContainer(padding: EdgeInsets.only(top: 20, left: 30)),
        'elasticIn'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .elasticIn(),
        'elasticIn Left'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .elasticInLeft(),
        'elasticIn Right'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .elasticInRight(),
        'elasticIn Down'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .elasticInDown(),
        'elasticIn Up'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .elasticInUp(),
        20.0.sizedHeight(),
        'SlideIn'
            .xH1Text(color: Colors.black)
            .xContainer(padding: EdgeInsets.only(top: 20, left: 30)),
        'slideIn Left'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .slideInLeft(),
        'slideIn Right'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .slideInRight(),
        'slideIn Down'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .slideInDown(),
        'slideIn Up'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .slideInUp(),
        20.0.sizedHeight(),
        'Flipin'
            .xH1Text(color: Colors.black)
            .xContainer(padding: EdgeInsets.only(top: 20, left: 30)),
        'flipInY'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .flipInY(),
        'flipInX'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .flipInX(),
        'Zoom'
            .xH1Text(color: Colors.black)
            .xContainer(padding: EdgeInsets.only(top: 20, left: 30)),
        'ZoomIn'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .zoomIn(),
        'ZoomOut'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .zoomOut(),
        'SpecialIn'
            .xH1Text(color: Colors.black)
            .xContainer(padding: EdgeInsets.only(top: 20, left: 30)),
        'jelloIn'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .jelloIn(),
        'Attention Seeker'
            .xH1Text(color: Colors.black)
            .xContainer(padding: EdgeInsets.only(top: 20, left: 30)),
        'Bounce'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .bounce(),
        'Flash'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .flash(),
        'Pulse'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .pulse(),
        'Swing'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .swing(),
        'Spin'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .spin(),
        'Spin Perfect'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .spinPerfect(),
        'Dance'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .dance(),
        'Roulette'
            .xTextColorWhite(fontsize: 30)
            .xContainer(
                color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                        .withOpacity(1.0),
                margin: EdgeInsets.all(20))
            .roulette(),
      ].xListView(),
    );
  }
}
