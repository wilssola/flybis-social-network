// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flybis/app/widgets/ad_widget.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:flybis/core/values/const.dart';
import 'package:flybis/global.dart';
import 'package:flybis/app/data/models/bell_model.dart';
import 'package:flybis/app/data/services/bell_service.dart'
    deferred as bell_service;
import 'package:flybis/app/widgets/bell_widget.dart' deferred as bell_widget;
import 'package:flybis/app/widgets/utils_widget.dart' deferred as utils_widget;

Future<bool> loadLibraries() async {
  await bell_service.loadLibrary();
  await bell_widget.loadLibrary();
  await utils_widget.loadLibrary();

  return true;
}

class BellView extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  final Color pageColor;
  final bool pageHeader;

  static const String pageId = 'Bell';

  BellView({
    Key? key,
    required this.scaffoldKey,
    required this.pageColor,
    this.pageHeader = false,
  }) : super(key: key);

  @override
  _BellViewState createState() => _BellViewState();
}

class _BellViewState extends State<BellView>
    with AutomaticKeepAliveClientMixin<BellView> {
  // Scroll
  bool toUpButton = false;
  bool showToUpButton = false;
  int limit = 0;
  int oldLimit = 0;
  ScrollController? scrollController;

  scrollInit() {
    scrollController = ScrollController();
    scrollController!.addListener(scrollListener);
  }

  scrollListener() {
    if (scrollController!.offset >=
            scrollController!.position.maxScrollExtent &&
        !scrollController!.position.outOfRange) {
      setState(() {
        limit = limit + 5;
      });
    }

    if (scrollController!.offset <=
            scrollController!.position.minScrollExtent &&
        !scrollController!.position.outOfRange) {
      setState(() {
        limit = 0;
      });
    }

    if (kIsWeb && !kScreenLittle(context)) {
      listenScrollToUp();
    }
  }

  scrollToUp() {
    hideScrollToUpButton();

    scrollController!.jumpTo(1.0);

    setState(() {
      limit = 0;
    });
  }

  listenScrollToUp() {
    if (scrollController!.offset > scrollController!.position.minScrollExtent) {
      setState(() {
        toUpButton = true;
        showToUpButton = true;
      });
    } else {
      hideScrollToUpButton();
    }
  }

  hideScrollToUpButton() {
    setState(() {
      toUpButton = false;
    });

    Future.delayed(Duration(milliseconds: 500)).then((value) {
      setState(() {
        showToUpButton = false;
      });
    });
  }
  // Scroll - End

  @override
  void initState() {
    scrollInit();

    super.initState();
  }

  Widget streamBell() {
    return StreamBuilder(
      stream:
          bell_service.BellService().streamBells(flybisUserOwner!.uid, limit),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<FlybisBell>> snapshot,
      ) {
        if (!snapshot.hasData &&
            snapshot.connectionState == ConnectionState.waiting) {
          return utils_widget.UtilsWidget().scaffoldCenterCircularProgress(
            context,
            color: widget.pageColor,
          );
        }

        List<Widget> bells = [];

        if (snapshot.hasData) {
          snapshot.data!.forEach((FlybisBell flybisBell) {
            bells.add(
              bell_widget.BellWidget(
                flybisBell: flybisBell,
                pageColor: widget.pageColor,
              ),
            );
          });
        }

        if (bells.isEmpty) {
          Widget info = utils_widget.UtilsWidget()
              .infoText('Nenhuma notificação encontrada');

          Widget ad = AdWidget(
            pageId: BellView.pageId,
            pageColor: widget.pageColor,
          );

          return Column(
            children: [
              kNotIsWebOrScreenLittle(context) ? info : Card(child: info),
              kNotIsWebOrScreenLittle(context) ? ad : Card(child: ad),
            ],
          );
        }

        Widget ad = AdWidget(
          pageId: BellView.pageId,
          pageColor: widget.pageColor,
          margin: EdgeInsets.only(top: 15),
        );

        return Column(
          children: [
            kNotIsWebOrScreenLittle(context) ? ad : Card(child: ad),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: bells.length,
              itemBuilder: (BuildContext context, int index) {
                return kNotIsWebOrScreenLittle(context)
                    ? bells[index]
                    : Card(child: bells[index]);
              },
            ),
          ],
        );
      },
    );
  }

  Widget bell() {
    return ListView(
      controller: scrollController,
      children: [
        !kIsWeb
            ? streamBell()
            : utils_widget.UtilsWidget().webBody(context, child: streamBell()),
      ],
    );
  }

  @override
  bool get wantKeepAlive => !kIsWeb ? true : false;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder(
      future: loadLibraries(),
      builder: (
        BuildContext context,
        AsyncSnapshot<bool> snapshot,
      ) {
        if (!snapshot.hasData) {
          return Text('');
        }

        return Scaffold(
          appBar: utils_widget.UtilsWidget().header(
            context,
            scaffoldKey: widget.scaffoldKey,
            titleText: 'bell'.tr,
            pageColor: widget.pageColor,
            pageHeader: widget.pageHeader,
          ),
          body: !kIsWeb
              ? bell()
              : Scrollbar(
                  isAlwaysShown: true,
                  showTrackOnHover: true,
                  controller: scrollController,
                  child: bell(),
                ),
          floatingActionButton: !kNotIsWebOrScreenLittle(context)
              ? utils_widget.UtilsWidget().floatingButtonUp(
                  showToUpButton,
                  toUpButton,
                  Icons.arrow_upward,
                  widget.pageColor,
                  scrollToUp,
                  BellView.pageId,
                )
              : null,
        );
      },
    );
  }
}
