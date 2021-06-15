// 🎯 Dart imports:
import 'dart:async';
import 'dart:ui';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_funding_choices/flutter_funding_choices.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:get/get.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:package_info/package_info.dart' deferred as package_info;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' deferred as html;
import 'package:universal_io/io.dart';

// 🌎 Project imports:
import 'package:flybis/constants/const.dart';
import 'package:flybis/constants/function.dart';
import 'package:flybis/constants/theme.dart';
import 'package:flybis/global.dart';
import 'package:flybis/models/bell_model.dart';
import 'package:flybis/models/user_model.dart';
import 'package:flybis/plugins/image_network/image_network.dart';
import 'package:flybis/services/auth_service.dart';
import 'package:flybis/services/flybis_service.dart';
import 'package:flybis/services/messaging_service.dart';
import 'package:flybis/services/user_service.dart';
import 'package:flybis/translation.dart';
import 'package:flybis/views/bell_view.dart' deferred as bell_view;
import 'package:flybis/views/camera_view.dart' deferred as camera_view;
import 'package:flybis/views/chat_view.dart' deferred as chat_view;
import 'package:flybis/views/login_view.dart' deferred as login_view;
import 'package:flybis/views/profile_view.dart' deferred as profile_view;
import 'package:flybis/views/search_view.dart' deferred as search_view;
import 'package:flybis/views/timeline_view.dart' deferred as timeline_view;
import 'package:flybis/widgets/icon_button_text_hover_widget.dart';
import 'package:flybis/widgets/utils_widget.dart' deferred as utils_widget;

import 'package:flybis/views/introduction_view.dart'
    deferred as introduction_view;
import 'package:flybis/views/profile_create_view.dart'
    deferred as profile_create_view;

import 'package:day_night_switcher/day_night_switcher.dart'
    deferred as day_night_switcher;

Future<bool> loadLibraries() async {
  await login_view.loadLibrary();

  await utils_widget.loadLibrary();

  await html.loadLibrary();
  await package_info.loadLibrary();
  await day_night_switcher.loadLibrary();

  return true;
}

Future<bool> timelineLoadLibrary() async {
  await timeline_view.loadLibrary();

  return true;
}

Future<bool> bellLoadLibrary() async {
  await bell_view.loadLibrary();

  return true;
}

Future<bool> cameraLoadLibrary() async {
  await camera_view.loadLibrary();

  return true;
}

Future<bool> profileLoadLibrary() async {
  await profile_view.loadLibrary();

  return true;
}

Future<bool> chatLoadLibrary() async {
  await chat_view.loadLibrary();

  return true;
}

Future<bool> searchLoadLibrary() async {
  await search_view.loadLibrary();

  return true;
}

// Auth
StreamSubscription? streamuser;

// RemoteConfig
late RemoteConfig remoteConfig;

// Google API's
GooglePlayServicesAvailability? availability;

// PageView
PageController pageController = PageController();

List<Widget> pageButtonsWeb = [
  IconButtonTextHoverWidget(
    icon: pages[0].icon,
    label: 'timeline'.tr,
    onPressed: () => onTap(0),
    style: TextButton.styleFrom(
      primary: Colors.white,
    ),
  ),
  IconButtonTextHoverWidget(
    icon: pages[1].icon,
    label: 'bell'.tr,
    onPressed: () => onTap(1),
    style: TextButton.styleFrom(
      primary: Colors.white,
    ),
  ),
  IconButtonTextHoverWidget(
    icon: pages[2].icon,
    label: 'camera'.tr,
    onPressed: () => onTap(2),
    style: TextButton.styleFrom(
      primary: Colors.white,
    ),
  ),
  IconButtonTextHoverWidget(
    icon: pages[3].icon,
    label: 'profile'.tr,
    onPressed: () => onTap(3),
    style: TextButton.styleFrom(
      primary: Colors.white,
    ),
  ),
  IconButtonTextHoverWidget(
    icon: pages[4].icon,
    label: 'chat'.tr,
    onPressed: () => onTap(4),
    style: TextButton.styleFrom(
      primary: Colors.white,
    ),
  ),
  IconButtonTextHoverWidget(
    icon: pages[5].icon,
    label: 'search'.tr,
    onPressed: () => onTap(5),
    style: TextButton.styleFrom(
      primary: Colors.white,
    ),
  ),
];

void onTap(int pageIndex) {
  switchPage(pageIndex);
}

void switchPage(int pageIndex) {
  if (!kIsWeb) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 150),
      curve: Curves.bounceInOut,
    );
  } else {
    pageController.jumpToPage(pageIndex);
  }

  checkPage(pageIndex);
}

void checkPage(int pageIndex) {
  if (pageIndex == 2) {
    setPortraitOrientations();
  } else {
    setAllOrientations();
  }
}

class App extends StatefulWidget {
  final Auth auth = new Auth();

  final int page;

  App({
    this.page = 0,
  });

  @override
  _AppState createState() => _AppState(pageIndex: page);
}

class _AppState extends State<App> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoad = false;
  bool isAuth = false;
  bool isAuthOffline = false;
  bool isDarkModeEnabled = false;

  int? pageIndex = 0;

  String? selectedLang = Translation.langs.first;

  UserService userService = UserService();

  _AppState({this.pageIndex});

  @override
  void initState() {
    pageController = PageController(initialPage: widget.page);

    if (mounted) {
      setState(() {
        this.pageIndex = widget.page;
      });
    }

    getDarkMode();

    if (!kIsWeb) {
      setRemoteConfig();

      checkGoogleApiAvailability();

      checkAdmobConsent();
    }

    getUserAuth();

    super.initState();
  }

  Future<void> load() async {
    if (!isLoad) {
      final int ms = 1000;

      print('Waiting $ms milliseconds to load page');

      await Future.delayed(new Duration(milliseconds: ms));

      if (mounted) {
        setState(() {
          isLoad = true;
        });
      }

      print('Page loaded');
    }
  }

  void checkAdmobConsent() async {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      ConsentInformation consentInfo =
          await FlutterFundingChoices.requestConsentInformation();
      if (consentInfo.isConsentFormAvailable &&
          (consentInfo.consentStatus == ConsentStatus.REQUIRED_ANDROID ||
              consentInfo.consentStatus == ConsentStatus.REQUIRED_IOS)) {
        // You can check the result by calling `FlutterFundingChoices.requestConsentInformation()`
        await FlutterFundingChoices.showConsentForm();
      }
    });
  }

  void checkGoogleApiAvailability() async {
    availability = await GoogleApiAvailability.instance
        .checkGooglePlayServicesAvailability(true);
  }

  void getDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? darkMode = prefs.getBool('darkMode');

    bool darkBrightness =
        SchedulerBinding.instance!.window.platformBrightness == Brightness.dark;

    Get.changeTheme(
      darkMode != null
          ? darkMode
              ? darkTheme
              : theme
          : darkBrightness
              ? darkTheme
              : theme,
    );

    isDarkModeEnabled = darkMode != null ? darkMode : darkBrightness;
  }

  void setDarkMode(isDarkModeEnabled) async {
    if (mounted) {
      setState(() {
        this.isDarkModeEnabled = isDarkModeEnabled;
      });
    }

    Get.changeTheme(!isDarkModeEnabled ? theme : darkTheme);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', isDarkModeEnabled);
  }

  void setRemoteConfig() async {
    remoteConfig = RemoteConfig.instance;

    await remoteConfig.fetch();
    await remoteConfig.activate();
    await remoteConfig.fetchAndActivate();
  }

  Future<Map<String, dynamic>> showProfileCreateView(String uid) async {
    await profile_create_view.loadLibrary();

    final Map<String, dynamic> result = await (Get.to(
      profile_create_view.ProfileCreateView(
        uid: uid,
      ),
    ) as FutureOr<Map<String, dynamic>>);

    logger.i('showProfileCreateView: ' + result['username']);

    return result;
  }

  Future<void> showIntroductionView() async {
    await introduction_view.loadLibrary();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => introduction_view.IntroductionView(),
      ),
    );
  }

  void getUserAuth() async {
    flybisUserOwner = await widget.auth.getUserOffline();

    auth.setLanguageCode('pt');

    auth.userChanges().listen((User? user) async {
      if (user == null) {
        if (mounted) {
          setState(() {
            isAuth = false;
          });
        }

        print('User not authenticated');
      } else {
        await userService.configureUserFirestore(
          user.uid,
          user.email,
          () async => await showProfileCreateView(user.uid),
          () async => await showIntroductionView(),
        );

        if (mounted) {
          setState(() {
            isAuth = true;
          });
        }

        print('User authenticated');

        await configureAgoraIo();

        if (!user.emailVerified) {
          await user.sendEmailVerification();
        }

        if (!kIsWeb) {
          await userService.configureUserPresence(user.uid);
          await MessagingService().configureMessaging(user.uid);
        }
      }
    });

    await load();
  }

  void configuraPageNotifications(Map<String, dynamic> message) {
    final FlybisBellData data = FlybisBellData.fromMap(message['data']);

    switch (data.bell.bellMode) {
      case 'message':
        break;
      case 'comment':
        break;
      case 'like':
        break;
      case 'follow':
        break;
      case 'friend':
        break;
      default:
        break;
    }
  }

  Future<void> configureAgoraIo() async {
    final HttpsCallable callableAgora = functions.httpsCallable(
      'getAgoraSignalingToken',
    );

    final HttpsCallableResult result = await callableAgora.call();

    agoraIoToken = result.data['token'];

    print('AgoraIo: ' + agoraIoToken!);
  }

  void onPageChanged(int pageIndex) {
    if (mounted) {
      setState(() {
        this.pageIndex = pageIndex;
      });
    }

    checkPage(pageIndex);
  }

  void aboutButton() async {
    late var packageInfo;

    if (!kIsWeb) {
      packageInfo = await package_info.PackageInfo.fromPlatform();
    }

    String minimumPostDuration = '';

    List<Map<String, dynamic>?> query = await (FlybisService()
        .streamMinimumPostDurations() as FutureOr<List<Map<String, dynamic>?>>);

    if (query[0] != null) {
      minimumPostDuration = Timestamp.fromMillisecondsSinceEpoch(
        query[0]!['minimumPostDuration'],
      ).toString();
    }

    showAboutDialog(
      context: context,
      applicationIcon: Container(
        width: 100,
        height: 100,
        margin: EdgeInsets.only(left: 0, top: 0, right: 10, bottom: 25),
        child: ImageNetwork.cachedNetworkImage(
          imageUrl: 'https://flybis.net/assets/flybis-icon.jpg',
        ),
      ),
      applicationVersion: !kIsWeb
          ? Platform.isAndroid
              ? ('Android ' + packageInfo.version)
              : ('IOS ' + packageInfo.version)
          : html.window.navigator.userAgent.toLowerCase().indexOf('electron') ==
                  -1
              ? 'Web'
              : 'Electron',
      children: [
        utils_widget.UtilsWidget().selectableText(
          'ID: ' +
              (!kIsWeb
                  ? packageInfo.packageName
                  : html.window.location.hostname!),
        ),
        utils_widget.UtilsWidget().selectableText(
          'MPD: ' + minimumPostDuration.toString(),
        )
      ],
    );
  }

  BottomNavigationBarItem barItem(
    Color backgroundColor,
    IconData icon,
  ) {
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: Theme.of(context).iconTheme.color,
      ),
      activeIcon: Icon(
        icon,
        color: backgroundColor,
      ),
      label: '',
    );
  }

  Widget drawer() {
    return StreamBuilder(
      stream: userService.streamUser(flybisUserOwner!.uid),
      builder: (BuildContext context, AsyncSnapshot<FlybisUser> snapshot) {
        if (!snapshot.hasData) {
          return Text('');
        }

        FlybisUser user = snapshot.data!;

        return Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: kAvatarBackground,
                    backgroundImage: ImageNetwork.cachedNetworkImageProvider(
                      user.photoUrl!,
                    ),
                  ),
                  title: Text(
                    '@${user.username}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    user.displayName!,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  color: pageColors[pageIndex!],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Configurações'),
                    ),
                    ListTile(
                      leading: Icon(Icons.info),
                      title: Text('Sobre'),
                      onTap: aboutButton,
                    ),
                    ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Sair'),
                      onTap: () => widget.auth.signOut(context),
                    ),
                    Container(
                      child: DropdownButton(
                        icon: Icon(Icons.arrow_drop_down),
                        value: selectedLang,
                        items: Translation.langs.map((String lang) {
                          return DropdownMenuItem(
                            value: lang,
                            child: Text(lang),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          // Updates dropdown selected value
                          setState(() => selectedLang = value);
                          // Gets language and changes the locale
                          Translation().changeLocale(value);
                        },
                      ),
                    ),
                    Container(
                      child: day_night_switcher.DayNightSwitcher(
                        isDarkModeEnabled: isDarkModeEnabled,
                        onStateChanged: setDarkMode,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget body() {
    List<Widget> pages = [
      FutureBuilder(
        future: timelineLoadLibrary(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text('');
          }

          return timeline_view.TimelineView(
            scaffoldKey: scaffoldKey,
            pageColor: pageColors[0],
            pageHeaderWeb: true,
          );
        },
      ),
      FutureBuilder(
        future: bellLoadLibrary(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text('');
          }

          return bell_view.BellView(
            scaffoldKey: scaffoldKey,
            pageColor: pageColors[1],
            pageHeaderWeb: true,
          );
        },
      ),
      FutureBuilder(
        future: cameraLoadLibrary(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text('');
          }

          return camera_view.CameraView(
            scaffoldKey: scaffoldKey,
            pageColor: pageColors[2],
            pageHeaderWeb: true,
          );
        },
      ),
      FutureBuilder(
        future: profileLoadLibrary(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text('');
          }

          return profile_view.ProfileView(
            scaffoldKey: scaffoldKey,
            pageColor: pageColors[3],
            pageHeaderWeb: true,
            uid: flybisUserOwner!.uid,
          );
        },
      ),
      FutureBuilder(
        future: chatLoadLibrary(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text('');
          }

          return chat_view.ChatView(
            scaffoldKey: scaffoldKey,
            pageColor: pageColors[4],
            pageHeaderWeb: true,
          );
        },
      ),
      FutureBuilder(
        future: searchLoadLibrary(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text('');
          }

          return search_view.SearchView(
            pageColor: pageColors[5],
            pageHeaderWeb: true,
          );
        },
      ),
    ];

    if (kIsWeb) {
      //return pages[widget.page];
    }

    return PageView(
      children: <Widget>[
        pages[0],
        pages[1],
        pages[2],
        pages[3],
        pages[4],
        pages[5],
      ],
      controller: pageController,
      onPageChanged: onPageChanged,
      scrollDirection: Axis.horizontal,
      physics:
          !kIsWeb ? AlwaysScrollableScrollPhysics() : ClampingScrollPhysics(),
    );
  }

  Widget app(BuildContext context) {
    return Scaffold(
      primary: true,
      key: scaffoldKey,
      drawer: kNotIsWebOrScreenLittle(context) ? drawer() : null,
      body: Stack(
        children: [
          Align(
            alignment: kNotIsWebOrScreenLittle(context)
                ? Alignment.center
                : Alignment.centerRight,
            child: Container(
              width: !kNotIsWebOrScreenLittle(context)
                  ? kWebBodyWidth(context)
                  : MediaQuery.of(context).size.width,
              child: body(),
            ),
          ),
          !kNotIsWebOrScreenLittle(context)
              ? Container(
                  width: kWebDrawerWidth,
                  child: drawer(),
                )
              : Padding(
                  padding: EdgeInsets.zero,
                ),
        ],
      ),
      bottomNavigationBar: !kIsWeb || (kIsWeb && kScreenLittle(context))
          ? SnakeNavigationBar.color(
              ///configuration for SnakeNavigationBar.color
              snakeViewColor: Colors.black,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.blueGrey,

              ///configuration for SnakeNavigationBar.gradient
              //snakeViewGradient: selectedGradient,
              //selectedItemGradient: snakeShape == SnakeShape.indicator ? selectedGradient : null,
              //unselectedItemGradient: unselectedGradient,

              onTap: onTap,
              elevation: 8,
              currentIndex: pageIndex!,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: [
                barItem(pages[0].color, pages[0].iconData),
                barItem(pages[1].color, pages[1].iconData),
                barItem(pages[2].color, pages[2].iconData),
                barItem(pages[3].color, pages[3].iconData),
                barItem(pages[4].color, pages[4].iconData),
                barItem(pages[5].color, pages[5].iconData),
              ],
            )
          /*? BottomNavigationBar(
              currentIndex: pageIndex!,
              onTap: onTap,
              iconSize: 25,
              elevation: 8,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              type: BottomNavigationBarType.fixed,
              mouseCursor: SystemMouseCursors.click,
              items: [
                barItem(pages[0].color, pages[0].iconData),
                barItem(pages[1].color, pages[1].iconData),
                barItem(pages[2].color, pages[2].iconData),
                barItem(pages[3].color, pages[3].iconData),
                barItem(pages[4].color, pages[4].iconData),
                barItem(pages[5].color, pages[5].iconData),
              ],
            )*/
          : null,
    );
  }

  @override
  void dispose() {
    pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadLibraries(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (!snapshot.hasData) {
          return Text('');
        }

        if (isLoad) {
          if (isAuth || isAuthOffline) {
            return app(context);
          } else {
            return login_view.LoginView(pageColors: pageColors);
          }
        } else {
          return utils_widget.UtilsWidget().centerCircularProgress(context);
        }
      },
    );
  }
}
