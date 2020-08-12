import 'package:flutter/foundation.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flybis/const.dart';
import 'package:flybis/plugins/format.dart';
import 'package:flybis/plugins/image_network/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import 'package:flybis/models/User.dart';
import 'package:flybis/pages/App.dart';
import 'package:flybis/pages/App/Bell.dart';
import 'package:flybis/services/Admob.dart';
import 'package:flybis/widgets/Utils.dart';
import 'package:flybis/widgets/Progress.dart';
import 'package:flybis/widgets/PostWidget.dart';

import 'package:async/async.dart';

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatefulWidget {
  final Color pageColor;

  SearchPage({this.pageColor});

  @override
  SearchState createState() => SearchState();
}

class SearchState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin<SearchPage> {
  bool isLoad = false;

  TextEditingController searchController = TextEditingController();
  Stream<QuerySnapshot> searchResultsFuture;

  handleSearch(String query) async {
    Stream<QuerySnapshot> usersByDisplayName = usersRef
        .where('displayName', isGreaterThanOrEqualTo: query)
        .snapshots();

    Stream<QuerySnapshot> usersByUsername =
        usersRef.where('username', isGreaterThanOrEqualTo: query).snapshots();
    if (mounted) {
      setState(() {
        searchResultsFuture = StreamGroup.merge([
          usersByUsername,
          //usersByUsernameLowercase,
          usersByDisplayName,
          //usersByDisplayNameLowercase,
        ]);
      });
    }
  }

  clearSearch() {
    searchController.clear();
  }

  AppBar buildSearchField() {
    return AppBar(
      elevation: 0,
      backgroundColor: widget.pageColor,
      title: TextFormField(
        style: TextStyle(color: Colors.white),
        controller: searchController,
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: 'Buscar...',
          hintStyle: TextStyle(color: Colors.white),
          fillColor: Colors.white,
          focusColor: Colors.white,
          hoverColor: Colors.white,
          border: InputBorder.none,
          filled: false,
          prefixIcon: Icon(FeatherIcons.search, color: Colors.white),
          suffixIcon: IconButton(
            icon: Icon(FeatherIcons.x, color: Colors.white),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  Widget buildNoContent() {
    //final Orientation orientation = MediaQuery.of(context).orientation;

    return StreamBuilder(
      stream: postsRef.snapshots(),
      builder: (context, snapshot) {
        Future.delayed(Duration(seconds: 1)).then((_) {
          if (mounted) {
            setState(() {
              isLoad = true;
            });
          }
        });

        if (!snapshot.hasData || !isLoad) {
          return circularProgress(
            color: widget.pageColor,
          );
        } else {
          if (snapshot.data.documents.length == 0) {
            return Admob(
              type: NativeAdmobType.banner,
              height: 100,
              color: widget.pageColor,
            ); //infoText('Nenhum resultado encontrado');
          }

          List<PostWidget> posts = [];

          snapshot.data.documents.forEach((doc) {
            doc.forEach((docs) {
              print(docs.id);
            });
          });

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return posts[index];
            },
            shrinkWrap: true,
          );
        }
      },
    );
  }

  buildSearchResults() {
    return StreamBuilder(
        stream: searchResultsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }

          if (snapshot.data.documents.length == 0) {
            return infoText('Nenhum resultado encontrado');
          }

          List<UserResult> searchResults = [];

          snapshot.data.documents.forEach((doc) {
            UserResult searchResult;

            User user = User.fromDocument(doc);
            searchResult = UserResult(
              user: user,
              pageColor: widget.pageColor,
            );

            searchResults.add(searchResult);
          });

          return ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              return searchResults[index];
            },
            //children: searchResults,
          );
        });
  }

  @override
  bool get wantKeepAlive => !kIsWeb ? true : false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor:
          Colors.white, //Theme.of(context).primaryColor.withOpacity(0.8),
      appBar: buildSearchField(),
      body:
          searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;
  final Widget child;
  final Color pageColor;
  UserResult({this.user, this.child, this.pageColor});

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      return Container(
        color: Colors.white, //Theme.of(context).primaryColor.withOpacity(0.7),
        child: Column(
          children: <Widget>[
            Divider(height: 1),
            GestureDetector(
              onTap: () => showProfile(
                context,
                profileId: user.uid,
                pageColor: pageColor,
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: ImageNetwork.cachedNetworkImageProvider(
                      user.photoUrl != null ? user.photoUrl : ''),
                  backgroundColor: avatarBackground,
                ),
                title: Row(children: <Widget>[
                  Text(
                    '@' + user.username,
                    style: TextStyle(color: Colors.blue),
                  ),
                  Spacer(),
                  Text(
                    '#${formatCompactNumber(user.followers)}',
                    style: TextStyle(color: Colors.blue),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 5),
                  ),
                  /*Text(user.following.toString(),
                      style: TextStyle(color: Colors.blue),),*/
                ]),
                subtitle: Row(
                  children: <Widget>[
                    Text(
                      user.displayName,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return child;
    }
  }
}
