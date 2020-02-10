import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flybis/plugins/image_network/image_network.dart';

class ViewPhoto extends StatelessWidget {
  final String url;
  final Color pageColor;

  ViewPhoto({Key key, @required this.url, @required this.pageColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text("Imagem"),
        elevation: 0,
        centerTitle: true,
        backgroundColor: pageColor,
      ),
      body: ViewPhotoScreen(url: url),
    );
  }
}

class ViewPhotoScreen extends StatefulWidget {
  final String url;

  ViewPhotoScreen({Key key, @required this.url}) : super(key: key);

  @override
  State createState() => new ViewPhotoScreenState(url: url);
}

class ViewPhotoScreenState extends State<ViewPhotoScreen> {
  final String url;

  ViewPhotoScreenState({Key key, @required this.url});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PhotoView(
        imageProvider: ImageNetwork.cachedNetworkImageProvider(url),
      ),
    );
  }
}
