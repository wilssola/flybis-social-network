import 'package:firexcode/firexcode.dart';

class ExampleH extends StatefulWidget {
  @override
  _ExampleHState createState() => _ExampleHState();
}

class _ExampleHState extends State<ExampleH> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: 'H1 to H6'.xTextColorBlack(),
      ),
      body: <Widget>[
        H1(
          text: 'H1 Widget',
          color: Colors.black,
        ).xContainer().toCenter(),
        'H1'.xH1Text(color: Colors.black),
        H2(
          text: 'H2 Widget',
          color: Colors.black,
        ).xContainer().toCenter(),
        'H2'.xH2Text(color: Colors.black),
        H2(
          text: 'H2 Widget',
          color: Colors.black,
        ).xContainer().toCenter(),
        'H2'.xH2Text(color: Colors.black),
        H3(
          text: 'H3 Widget',
          color: Colors.black,
        ).xContainer().toCenter(),
        'H3'.xH3Text(color: Colors.black),
        H4(
          text: 'H4 Widget',
          color: Colors.black,
        ).xContainer().toCenter(),
        'H4'.xH4Text(color: Colors.black),
        H5(
          text: 'H5 Widget',
          color: Colors.black,
        ).xContainer().toCenter(),
        'H5'.xH5Text(color: Colors.black),
        H6(
          text: 'H6 Widget',
          color: Colors.black,
        ).xContainer().toCenter(),
        'H6'.xH6Text(color: Colors.black),
      ].xColumnCC(),
    );
  }
}
