import 'package:firexcode/firexcode.dart';

class ExampleCardListTile extends StatefulWidget {
  @override
  _ExampleCardListTileState createState() => _ExampleCardListTileState();
}

class _ExampleCardListTileState extends State<ExampleCardListTile> {
  bool isActive = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: 'XCardListTile'.xTextColorBlack(),
        brightness: Brightness.light,
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: <Widget>[
        XCardListTile(
          trailing: '10min ago'.xTextColorWhite(),
          leading: Icons.add.xListTileIcon(color: Colors.white),
          color: Colors.red,
          title: 'Test'.xTextColorWhite(),
          subTitle: 'Material-X package '.xTextColorWhite(),
          width: 500,
          onTap: () {},
        ),
        20.0.sizedHeight(),
        XCardListTile(
          color: Color(0xFF3D6dfe),
          title: 'Test'.xTextColorWhite(),
          subTitle: 'Material-X package '.xTextColorWhite(),
          width: 500,
          onTap: () {},
        ),
        20.0.sizedHeight(),
        XCardListTile(
          leading: 'z'
              .xText(fontWeight: FontWeight.bold)
              .xCircleAvatar(backgroundColor: Colors.white),
          rounded: 20,
          color: Colors.orange,
          title: 'Test'.xTextColorWhite(),
          subTitle: 'Material-X package '.xTextColorWhite(),
          width: 500,
          onTap: () {},
        ),
        20.0.sizedHeight(),
        XCardListTile(
          color: Colors.yellow,
          title: 'Test'.xTextColorWhite(),
          subTitle: 'Material-X package '.xTextColorWhite(),
          width: 500,
          image:
              'https://image.freepik.com/free-psd/tropical-foliage-background_53876-91352.jpg'
                  .decorationINToCover(),
          onTap: () {},
        ),
        20.0.sizedHeight(),
        XCardListTile(
          leading: Icons.fullscreen.xListTileIcon(color: Colors.white),
          color: Colors.green,
          title: 'Test'.xTextColorWhite(),
          subTitle: 'Material-X package '.xTextColorWhite(),
          width: 500,
          image:
              'https://image.freepik.com/free-vector/realistic-dark-tropical-leaves-background_52683-30656.jpg'
                  .decorationINToCover(),
          onTap: () {},
        ),
      ].xColumnCC().xap(value: 10.0),
    );
  }
}
