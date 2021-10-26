import 'package:firexcode/firexcode.dart';

double value = 200.0;

class ExampleFlexible extends StatefulWidget {
  @override
  _ExampleFlexibleState createState() => _ExampleFlexibleState();
}

class _ExampleFlexibleState extends State<ExampleFlexible> {
  @override
  Widget build(BuildContext context) {
    var menu = <Widget>[
      XCustomStatic(
        onTap: () {},
        rounded: 10.0,
        padding: EdgeInsets.all(20.0),
        bgColor: Colors.black,
        spaceHeight: 10.0,
        // title: "Text".text(),
        value: '105.0'.xH2Text(color: Colors.white),
        child: Icons.ac_unit
            .xIcon(color: Colors.black, size: 25.0)
            .xCircleAvatar(backgroundColor: Colors.white, radius: 30.0),
      ).xFlexableRes(350.0 <= value),
      20.0.sizedHeight(),
      XCustomStatic(
        onTap: () {},
        rounded: 10.0,
        padding: EdgeInsets.all(20.0),
        bgColor: Colors.black,
        spaceHeight: 10.0,
        // title: "Text".text(),
        value: '105.0'.xH2Text(color: Colors.white),
        child: Icons.ac_unit
            .xIcon(color: Colors.black, size: 25.0)
            .xCircleAvatar(backgroundColor: Colors.white, radius: 30.0),
      ).xFlexableRes(350.0 <= value),
      20.0.sizedHeight(),
      XCustomStatic(
        onTap: () {},
        rounded: 10.0,
        padding: EdgeInsets.all(20.0),
        bgColor: Colors.black,
        spaceHeight: 10.0,
        // title: "Text".text(),
        value: '105.0'.xH2Text(color: Colors.white),
        child: Icons.ac_unit
            .xIcon(color: Colors.black, size: 25.0)
            .xCircleAvatar(backgroundColor: Colors.white, radius: 30.0),
      ).xFlexableRes(350.0 <= value)
    ];
    return <Widget>[
      350.0 <= value
          ? menu.xRowSSB().xap(value: 20.0).fadeIn()
          : menu.xColumn().fadeInLeft().xContainer(
                width: value,
              ),
      Slider(
          value: value,
          max: 500.0,
          onChanged: (v) {
            setState(() {
              value = v;
            });
          })
    ].xColumnCC().xScaffold(
        backgroundColor: Colors.white,
        appBar: 'Column & Row Responsive'.xTextColorBlack().xAppBar(
              brightness: Brightness.light,
              centerTitle: true,
              backgroundColor: Colors.white,
            ));
  }
}
