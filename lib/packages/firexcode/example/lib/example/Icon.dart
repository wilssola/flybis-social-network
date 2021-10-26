import 'package:firexcode/firexcode.dart';

class ExampleIcon extends StatefulWidget {
  @override
  _ExampleIconState createState() => _ExampleIconState();
}

class _ExampleIconState extends State<ExampleIcon> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: 'Icon'.xTextColorBlack(),
      ),
      body: <Widget>[
        40.0.sizedHeight(),
        Icons.adb.xIconTile(color: Colors.black, size: 50).toCenter(),
        40.0.sizedHeight(),
        Icons.adb.xListTileIcon(
            height: 100, width: 100, color: Colors.red, size: 50),
        Icons.adb
            .xIconTile(color: Colors.white, size: 30)
            .lableIcon(
                color: Colors.red,
                lable: 'white'.xTextColorWhite(),
                onTap: () {},
                rounded: 15)
            .xap(value: 10)
            .fadeIn()
      ].xColumnCC(),
    );
  }
}
