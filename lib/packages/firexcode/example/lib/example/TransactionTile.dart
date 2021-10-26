import 'package:firexcode/firexcode.dart';

class ExampleTransactionTile extends StatefulWidget {
  @override
  _ExampleTransactionTileState createState() => _ExampleTransactionTileState();
}

class _ExampleTransactionTileState extends State<ExampleTransactionTile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: 'TransactiontTile '.xTextColorBlack(),
      ),
      body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: <Widget>[
            XTransactiontTile(
                    onTap: () {},
                    leading: Icons.book.xListTileIcon(color: Colors.purple),
                    title: 'Zeeshan'.xCardTileTitle(color: Colors.black),
                    subtitle: 'Developr!!'.xTextColorGrey(),
                    trailing1: '+ 1234500.0'.xTextColorBlack(
                        fontsize: 15, fontWeight: FontWeight.bold),
                    middleSpace: 5.0,
                    trailing2: 'sep 15 2019'.xTextColorBlueGrey())
                .fadeInDown(),
            10.0.sizedHeight(),
            XTransactiontTile(
                    onTap: () {},
                    leading: Icons.laptop_mac.xTransactionTileIcon(
                      color: Colors.blue,
                    ),
                    title: 'Apple Mac Laptop'
                        .xCardTileTitle(color: Colors.black, fontsize: 15),
                    subtitle: 'Buy'.xTextColorGrey(),
                    trailing1: '+ 1234500.0'.xTextColorBlack(
                        fontsize: 15, fontWeight: FontWeight.bold),
                    middleSpace: 5.0,
                    trailing2: 'sep 15 2019'.xTextColorBlueGrey())
                .xContainer(color: Colors.white)
                .fadeInLeft(),
            10.0.sizedHeight(),
            XTransactiontTile(
                    onTap: () {},
                    leading:
                        'https://yt3.ggpht.com/a/AGF-l78mULPjAtTZ0U987YPHe5quNFIrNHYlWi9WvA=s900-c-k-c0xffffffff-no-rj-mo'
                            .xCircleNetWorkImage(),
                    title: 'Apple Mac Laptop'
                        .xCardTileTitle(color: Colors.black, fontsize: 15),
                    subtitle: 'Buy'.xTextColorGrey(),
                    trailing1: '+ 1234500.0'.xTextColorBlack(
                        fontsize: 15, fontWeight: FontWeight.bold),
                    middleSpace: 5.0,
                    trailing2: 'sep 15 2019'.xTextColorBlueGrey())
                .xContainer(color: Colors.white)
                .fadeInRight(),
            10.0.sizedHeight(),
            XTransactiontTile(
                    onTap: () {},
                    leading:
                        'https://yt3.ggpht.com/a/AGF-l78mULPjAtTZ0U987YPHe5quNFIrNHYlWi9WvA=s900-c-k-c0xffffffff-no-rj-mo'
                            .xCircleNetWorkImage(),
                    title: 'Apple Mac Laptop'
                        .xCardTileTitle(color: Colors.white, fontsize: 15),
                    subtitle: 'Buy'.xTextColorWhite(),
                    trailing1: '+ 1234500.0'.xTextColorWhite(
                        fontsize: 15, fontWeight: FontWeight.bold),
                    middleSpace: 5.0,
                    trailing2: 'sep 15 2019'.xTextColorWhite())
                .xContainer(color: Color(0xFF3d6dfe))
                .fadeInUp(),
            10.0.sizedHeight(),
            XTransactiontTile(
                    leading:
                        'https://yt3.ggpht.com/a/AGF-l78mULPjAtTZ0U987YPHe5quNFIrNHYlWi9WvA=s900-c-k-c0xffffffff-no-rj-mo'
                            .xCircleNetWorkImage(),
                    title: 'Apple Mac Laptop'
                        .xCardTileTitle(color: Colors.white, fontsize: 15),
                    subtitle: 'Buy'.xTextColorWhite(),
                    trailing1: '+ 1234500.0'.xTextColorWhite(
                        fontsize: 15, fontWeight: FontWeight.bold),
                    middleSpace: 5.0,
                    trailing2: 'sep 15 2019'.xTextColorWhite())
                .xContainer(color: Colors.orange, rounded: 10, onTap: () {})
                .fadeInUp(),
            10.0.sizedHeight(),
            XTransactiontTile(
                    leading:
                        'https://yt3.ggpht.com/a/AGF-l78mULPjAtTZ0U987YPHe5quNFIrNHYlWi9WvA=s900-c-k-c0xffffffff-no-rj-mo'
                            .xCircleNetWorkImage(),
                    title: 'Apple Mac Laptop'
                        .xCardTileTitle(color: Colors.white, fontsize: 15),
                    subtitle: 'Buy'.xTextColorWhite(),
                    trailing1: '+ 1234500.0'.xTextColorWhite(
                        fontsize: 15, fontWeight: FontWeight.bold),
                    middleSpace: 5.0,
                    onTap: () {},
                    trailing2: 'sep 15 2019'.xTextColorWhite())
                .xContainer(
                  color: Colors.red,
                  blurRadius: 12,
                  spreadRadius: 0.5,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.elliptical(50, 50),
                      topLeft: Radius.elliptical(50, 50)),
                  shadowColor: Colors.redAccent,
                )
                .fadeInUp(),
            10.0.sizedHeight(),
            XTransactiontTile(
                    leading:
                        'https://yt3.ggpht.com/a/AGF-l78mULPjAtTZ0U987YPHe5quNFIrNHYlWi9WvA=s900-c-k-c0xffffffff-no-rj-mo'
                            .xCircleNetWorkImage(),
                    title: 'Apple Mac Laptop'
                        .xCardTileTitle(color: Colors.white, fontsize: 15),
                    subtitle: 'Buy'.xTextColorWhite(),
                    trailing1: '+ 1234500.0'.xTextColorWhite(
                        fontsize: 15, fontWeight: FontWeight.bold),
                    middleSpace: 5.0,
                    trailing2: 'sep 15 2019'.xTextColorWhite())
                .xContainer(
                    color: Colors.pink,
                    blurRadius: 12,
                    spreadRadius: 0.5,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.elliptical(100, 50)),
                    shadowColor: Colors.pinkAccent,
                    onTap: () {})
                .fadeInUp(),
            10.0.sizedHeight(),
            XTransactiontTile(
                    leading:
                        'https://yt3.ggpht.com/a/AGF-l78mULPjAtTZ0U987YPHe5quNFIrNHYlWi9WvA=s900-c-k-c0xffffffff-no-rj-mo'
                            .xCircleNetWorkImage(),
                    title: 'Apple Mac Laptop'
                        .xCardTileTitle(color: Colors.white, fontsize: 15),
                    subtitle: 'Buy'.xTextColorWhite(),
                    trailing1: '+ 1234500.0'.xTextColorWhite(
                        fontsize: 15, fontWeight: FontWeight.bold),
                    middleSpace: 5.0,
                    trailing2: 'sep 15 2019'.xTextColorWhite())
                .xContainer(
                    color: Colors.pink,
                    blurRadius: 12,
                    spreadRadius: 0.5,
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.elliptical(100, 50)),
                    shadowColor: Colors.pinkAccent,
                    onTap: () {})
                .fadeInUp(),
            10.0.sizedHeight(),
          ].xListView()),
    );
  }
}
