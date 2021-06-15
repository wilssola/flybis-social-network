// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:flybis/constants/const.dart';
import 'package:flybis/global.dart';
import 'package:flybis/models/bell_model.dart';
import 'package:flybis/services/admob_service.dart' deferred as admob_service;
import 'package:flybis/services/bell_service.dart';
import 'package:flybis/widgets/bell_widget.dart';
import 'package:flybis/widgets/utils_widget.dart' as utils_widget;

Future<bool> loadLibraries() async {
  await admob_service.loadLibrary();

  return true;
}

class BellView extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  static const String pageId = 'Bell';
  final Color pageColor;
  final bool pageHeaderWeb;

  BellView({
    Key? key,
    required this.scaffoldKey,
    required this.pageColor,
    this.pageHeaderWeb = false,
  }) : super(key: key);

  @override
  _BellViewState createState() => _BellViewState();
}

class _BellViewState extends State<BellView> {
  //with AutomaticKeepAliveClientMixin<BellView> {
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
    if (scrollController!.offset >= scrollController!.position.maxScrollExtent &&
        !scrollController!.position.outOfRange) {
      setState(() {
        limit = limit + 5;
      });
    }

    if (scrollController!.offset <= scrollController!.position.minScrollExtent &&
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

  bool isLoaded = false;

  @override
  void initState() {
    scrollInit();

    super.initState();
  }

  Widget streamBell() {
    return StreamBuilder(
      stream: BellService().streamBells(flybisUserOwner!.uid, limit),
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

        List<BellWidget> bells = [];

        if (snapshot.hasData) {
          snapshot.data!.forEach((FlybisBell flybisBell) {
            bells.add(
              BellWidget(
                flybisBell: flybisBell,
                pageColor: widget.pageColor,
              ),
            );
          });
        }

        if (bells.isEmpty) {
          Widget infoWidget = utils_widget.UtilsWidget()
              .infoText('Nenhuma notificação encontrada');

          Widget admobWidget = admob_service.AdmobService().showAdmob(
            pageId: BellView.pageId,
            pageColor: widget.pageColor,
          );

          return Column(
            //shrinkWrap: true,
            //physics: NeverScrollableScrollPhysics(),
            children: [
              kNotIsWebOrScreenLittle(context)
                  ? infoWidget
                  : Card(child: infoWidget),
              kNotIsWebOrScreenLittle(context)
                  ? admobWidget
                  : Card(child: admobWidget),
            ],
          );
        }

        Widget admobWidget = admob_service.AdmobService().showAdmob(
          pageId: BellView.pageId,
          pageColor: widget.pageColor,
          margin: EdgeInsets.only(top: 15),
        );

        return Column(
          //shrinkWrap: true,
          //physics: NeverScrollableScrollPhysics(),
          children: [
            kNotIsWebOrScreenLittle(context)
                ? admobWidget
                : Card(child: admobWidget),
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
  //bool get wantKeepAlive => !kIsWeb ? true : false;

  @override
  Widget build(BuildContext context) {
    //super.build(context);

    return FutureBuilder(
      future: loadLibraries(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text('');
        }

        return Scaffold(
          appBar: utils_widget.UtilsWidget().header(
            context,
            scaffoldKey: widget.scaffoldKey,
            titleText: 'bell'.tr,
            pageColor: widget.pageColor,
            pageHeaderWeb: widget.pageHeaderWeb,
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
