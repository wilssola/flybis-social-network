import 'package:flybis/plugins/image_network/image_network.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget cachedNetworkImage(String mediaUrl) {
  return ImageNetwork.cachedNetworkImage(
    imageUrl: mediaUrl != null ? mediaUrl : "",
    fit: BoxFit.cover,
    placeholder: (context, url) => Padding(
      child: CircularProgressIndicator(),
      padding: EdgeInsets.all(20),
    ),
    errorWidget: (context, url, error) => Icon(
      Icons.error,
    ),
  );
}
