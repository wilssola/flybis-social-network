import 'package:firexcode/firexcode.dart';

class ExampleBlogTile extends StatefulWidget {
  @override
  _ExampleBlogTileState createState() => _ExampleBlogTileState();
}

class _ExampleBlogTileState extends State<ExampleBlogTile> {
  @override
  Widget build(BuildContext context) {
    return <Widget>[
      XBlogTile(
        tileOnTap: () {},
        backSideBackgroundColor: Colors.grey[100],
        cardElevation: 5,
        imageHeight: 200,
        onTap: () {},
        backrounded: 10,
        shape: BorderRadius.circular(10).xShapeBorder(),
        leading: 'Z'
            .xTextColorWhite()
            .xCircleAvatar(backgroundColor: Colors.black, radius: 25),
        title: 'Image Editor Pro'.xTextColorBlack(),
        subTitle: 'Goto PubDev Check'.xText(),
        trailing: '10 min ago'.xText(),
        image:
            'https://user-images.githubusercontent.com/55942632/77652902-fedd9980-6f94-11ea-96d5-d31657590893.png'
                .decorationINToCover(),
      ),
      XBlogTile(
        rounded: 10,
        color: Color(0xFFff1632),
        tileOnTap: () {},
        backSideBackgroundColor: Colors.grey[100],
        cardElevation: 5,
        imageHeight: 200,
        onTap: () {},
        backrounded: 10,
        shape: BorderRadius.circular(10).xShapeBorder(),
        leading: 'Z'
            .xTextColorWhite()
            .xCircleAvatar(backgroundColor: Colors.white, radius: 25),
        title: 'Image Editor Pro'.xTextColorWhite(),
        subTitle: 'Goto PubDev Check'.xText(color: Colors.grey[50]),
        trailing: '10 min ago'.xText(
          color: Colors.white,
        ),
        image:
            'https://user-images.githubusercontent.com/45489310/78457255-b9d4f980-765d-11ea-8d17-78bb21297de6.png'
                .decorationINToCover(),
      ),
      XBlogTile(
        color: Colors.orange,
        tileOnTap: () {},
        backSideBackgroundColor: Colors.grey[100],
        cardElevation: 5,
        imageHeight: 200,
        onTap: () {},
        backrounded: 10,
        shape: BorderRadius.circular(10).xShapeBorder(),
        leading: 'Z'
            .xText(fontWeight: FontWeight.bold, color: Colors.black)
            .xCircleAvatar(backgroundColor: Colors.white, radius: 25),
        title: 'Image Editor Pro'.xTextColorWhite(),
        subTitle: 'Goto PubDev Check'.xText(color: Colors.grey[50]),
        trailing: '10 min ago'.xText(
          color: Colors.white,
        ),
        image:
            'https://user-images.githubusercontent.com/55942632/77652902-fedd9980-6f94-11ea-96d5-d31657590893.png'
                .decorationINToCover(),
      ),
    ].xListView().xap(value: 10.0).xScaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            brightness: Brightness.light,
            centerTitle: true,
            backgroundColor: Colors.white,
            title: 'BlogTile '.xTextColorBlack(),
          ),
        );
  }
}
