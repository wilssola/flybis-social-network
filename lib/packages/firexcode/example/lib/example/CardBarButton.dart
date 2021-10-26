import 'package:firexcode/firexcode.dart';

class ExampleCardBarButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return <Widget>[
      CardBarButton(
        onTap: () {},
        color: Colors.black,
        eleavation: 10,
        shadowColor: Colors.black,
        title: Icons.android.xIconTile(color: Colors.white, size: 30),
        subtitle: 'Zeeshan'.xTextColorWhite(),
      ).toCenter(),
      20.0.sizedHeight(),
      CardBarButton(
        onTap: () {},
        color: Colors.red,
        title: Icons.android.xIconTile(color: Colors.white, size: 30),
        subtitle: 'Zeeshan'.xTextColorWhite(),
      ).toCenter(),
    ].xColumnCC().xScaffold(
        backgroundColor: Colors.white,
        appBar: 'CardBarButton'.xTextColorBlack().xAppBar(
              brightness: Brightness.light,
              centerTitle: true,
              backgroundColor: Colors.white,
            ));
  }
}
