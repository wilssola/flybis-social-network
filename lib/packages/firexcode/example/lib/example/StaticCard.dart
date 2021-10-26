import 'package:firexcode/firexcode.dart';

class ExampleStaticCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return <Widget>[
      XStaticCard(
              onTap: () {},
              rounded: 10.0,
              padding: EdgeInsets.all(20.0),
              blurRadius: 12.0,
              shadowColor: Colors.red,
              icon: Icons.ac_unit,
              title: 'Text'.text(),
              value: '105.0'.xH1Text(color: Colors.black),
              cicleColor: Colors.red)
          .toCenter(),
      30.0.sizedHeight(),
      XCustomStatic(
        onTap: () {},
        rounded: 10.0,
        padding: EdgeInsets.all(20.0),
        bgColor: Color(0xFF3d6dfe),
        spaceHeight: 10.0,
        title: 'Text'.text(style: TextStyle(color: Colors.white)),
        value: '105.0'.xH1Text(color: Colors.white),
        child: Icons.ac_unit
            .xIcon(color: Colors.blue)
            .xCircleAvatar(backgroundColor: Colors.white, radius: 25.0),
      ).toCenter(),
      10.0.sizedHeight(),
      XCustomStatic(
        onTap: () {},
        rounded: 10.0,
        padding: EdgeInsets.all(20.0),
        bgColor: Colors.black,
        spaceHeight: 10.0,
        // title: 'Text'.text(),
        value: '105.0'.xH2Text(color: Colors.white),
        child: Icons.ac_unit
            .xIcon(color: Colors.black, size: 25.0)
            .xCircleAvatar(backgroundColor: Colors.white, radius: 30.0),
      ).toCenter(),
    ].xColumnCC().xScaffold(
        backgroundColor: Colors.white,
        appBar: 'StaticCard'.xTextColorBlack().xAppBar(
              brightness: Brightness.light,
              centerTitle: true,
              backgroundColor: Colors.white,
            ));
  }
}
