import 'package:firexcode/firexcode.dart';

class ExampleText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return <Widget>[
      'Text all parm'.text(),
      5.0.sizedHeight(),
      Textmaterial(
        text: 'Textmaterial()',
        fontsize: 20,
      ),
      5.0.sizedHeight(),
      '.xText()'.xText(fontsize: 20),
      5.0.sizedHeight(),
      '.xTextColorBlack()'.xTextColorBlack(fontsize: 20),
      5.0.sizedHeight(),
      '.xTextColorCyan()'.xTextColorCyan(fontsize: 20),
      5.0.sizedHeight(),
      '.xTextColoramber()'.xTextColorAmber(fontsize: 20),
      5.0.sizedHeight(),
      '.xTextColordeepOrange()'.xTextColorDeepOrange(fontsize: 20),
      5.0.sizedHeight(),
      '.xTextColorblue()'.xTextColorBlue(fontsize: 20),
      5.0.sizedHeight(),
      '.xTextColorgreen()'.xTextColorGreen(fontsize: 20),
      5.0.sizedHeight(),
      '.xTextColorlightBlue()'.xTextColorlightBlue(fontsize: 20),
      5.0.sizedHeight(),
      '.xTextColorindigo()'.xTextColorIndigo(fontsize: 20),
      5.0.sizedHeight(),
      '.xTextColorpink()'.xTextColorPink(fontsize: 20),
      5.0.sizedHeight(),
      '.xTextColorteal()'.xTextColorTeal(fontsize: 20).toAlign(),
    ].xColumnSS().xap(value: 20.0).xScaffold(
        backgroundColor: Colors.white,
        appBar: 'Demo Text'.xTextColorBlack().xAppBar(
              brightness: Brightness.light,
              centerTitle: true,
              backgroundColor: Colors.white,
            ));
  }
}
