import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flybis/plugins/image_network/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import 'package:flybis/models/User.dart';
import 'package:flybis/pages/Home.dart';
import 'package:flybis/pages/Activity.dart';
import 'package:flybis/widgets/Ads.dart';
import 'package:flybis/widgets/Utils.dart';
import 'package:flybis/widgets/Progress.dart';
import 'package:flybis/widgets/PostWidget.dart';

import 'package:async/async.dart';

import 'dart:async';

class Search extends StatefulWidget {
  final Color pageColor;

  Search({this.pageColor});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  bool isLoad = false;

  TextEditingController searchController = TextEditingController();
  Stream<QuerySnapshot> searchResultsFuture;

  handleSearch(String query) async {
    Stream<QuerySnapshot> usersByDisplayName =
        usersRef.where('displayName', isGreaterThanOrEqualTo: query).snapshots();

    Stream<QuerySnapshot> usersByUsername =
        usersRef.where('username', isGreaterThanOrEqualTo: query).snapshots();

    setState(() {
      searchResultsFuture = StreamGroup.merge([
        usersByUsername,
        //usersByUsernameLowercase,
        usersByDisplayName,
        //usersByDisplayNameLowercase,
      ]);
    });
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
            return infoCenterText('Nenhum resultado encontrado');
          }

          List<PostWidget> posts = [];

          snapshot.data.documents.forEach((doc) {
            doc.forEach((docs) {
              print(docs.id);
            });
          });

          if (!kIsWeb) {
            bannerToList(
              posts,
              5,
              PostWidget(
                child: Ads(AdsType.BANNER),
              ),
            );
          }

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
            return infoCenterText('Nenhum resultados encontrado');
          }

          List<UserResult> searchResults = [];

          snapshot.data.documents.forEach((doc) {
            UserResult searchResult;

            User user = User.fromDocument(doc);
            searchResult = UserResult(user: user);

            searchResults.add(searchResult);
          });

          bannerToList(
            searchResults,
            3,
            UserResult(
              child: banner(),
            ),
          );

          return ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              return searchResults[index];
            },
            //children: searchResults,
          );
        });
  }

  get wantKeepAlive => true;
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
  UserResult({this.user, this.child});

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      return Container(
        color: Colors.white, //Theme.of(context).primaryColor.withOpacity(0.7),
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () => showProfile(context, profileId: user.id),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: ImageNetwork.cachedNetworkImageProvider(
                      user.photoUrl != null ? user.photoUrl : ""),
                  backgroundColor: Colors.grey,
                ),
                title: Row(children: <Widget>[
                  Text(
                    "@" + user.username,
                    style: TextStyle(color: Colors.blue),
                  ),
                  Spacer(),
                  Text(
                    user.followers.toString() + " seguidores",
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
            Divider(
              height: 2.0,
              color: Colors.white54,
            ),
          ],
        ),
      );
    } else {
      return child;
    }
  }
}
