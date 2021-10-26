import 'package:firexcode/firexcode.dart';

class ExampleCardGradientListTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return <Widget>[
      XCardListTileGradient(
              trailing: '10min ago'.xTextColorWhite(),
              blurRadius: 20,
              rounded: 10,
              width: 500,
              leading: Icons.ac_unit.xListTileIcon(color: Colors.white),
              title: 'Testing'.xTextColorWhite(),
              subTitle: 'Lorem Ipsum is simply '.xTextColorWhite(),
              onTap: () {},
              shadowColor: Colors.red,
              gradient: [
                Colors.deepPurple,
                Colors.cyan
              ].xLGrepeated(begin: Alignment.topLeft, end: Alignment.topRight))
          .xap(value: 20.0),
      XCardListTileGradient(
              rounded: 10.0,
              leading: Icons.ac_unit.xListTileIcon(color: Colors.white),
              title: 'Testing'.xTextColorWhite(),
              subTitle: 'Lorem Ipsum is simply dummy text of the printing'
                  .xTextColorWhite(),
              gradient: [Colors.pink, Colors.deepOrange].xLGrepeated(
                  begin: Alignment.topLeft, end: Alignment.bottomRight))
          .xap(value: 20.0),
      XCardListTileGradient(
              leading: Icons.ac_unit.xListTileIcon(color: Colors.white),
              title: 'Testing'.xTextColorWhite(),
              subTitle:
                  "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
                      .xTextColorWhite(),
              gradient: [Colors.red, Colors.pink].xLGrepeated(
                  begin: Alignment.topLeft, end: Alignment.bottomRight))
          .xap(value: 20.0),
    ].xListView().xScaffold(
        backgroundColor: Colors.white,
        appBar: 'XCardListTileGradient'.xTextColorBlack().xAppBar(
              brightness: Brightness.light,
              centerTitle: true,
              backgroundColor: Colors.white,
            ));
  }
}
