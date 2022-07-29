// 🎯 Dart imports:
import 'dart:async';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// 📦 Package imports:
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_funding_choices/flutter_funding_choices.dart';
import 'package:get/get.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:universal_io/io.dart';
import 'package:universal_html/html.dart' deferred as html;
import 'package:package_info_plus/package_info_plus.dart'
    deferred as package_info_plus;
import 'package:day_night_switcher/day_night_switcher.dart'
    deferred as day_night_switcher;

// 🌎 Project imports:
import 'package:flybis/core/values/const.dart';
import 'package:flybis/core/values/function.dart';
import 'package:flybis/core/themes/theme.dart';
import 'package:flybis/global.dart';
import 'package:flybis/app/data/models/bell_model.dart';
import 'package:flybis/plugins/image_network/image_network.dart';
import 'package:flybis/app/data/providers/auth_provider.dart';
import 'package:flybis/app/data/services/flybis_service.dart';
import 'package:flybis/app/data/providers/messaging_provider.dart';
import 'package:flybis/app/data/services/user_service.dart';
import 'package:flybis/translation.dart';
import 'package:flybis/app/views/login_view.dart' deferred as login_view;
import 'package:flybis/app/views/introduction_view.dart'
    deferred as introduction_view;
import 'package:flybis/app/views/profile_create_view.dart'
    deferred as profile_create_view;
import 'package:flybis/app/views/timeline_view.dart' deferred as timeline_view;
import 'package:flybis/app/views/bell_view.dart' deferred as bell_view;
import 'package:flybis/app/views/camera_view.dart' deferred as camera_view;
import 'package:flybis/app/views/profile_view.dart' deferred as profile_view;
import 'package:flybis/app/views/chat_view.dart' deferred as chat_view;
import 'package:flybis/app/views/search_view.dart' deferred as search_view;
import 'package:flybis/app/widgets/utils_widget.dart' deferred as utils_widget;
import 'package:flybis/app/widgets/icon_button_text_hover_widget.dart';

Future<bool> loadLibraries() async {
  await html.loadLibrary();
  await package_info_plus.loadLibrary();
  await day_night_switcher.loadLibrary();

  await login_view.loadLibrary();
  await utils_widget.loadLibrary();

  return true;
}

Future<bool> timelineViewLoadLibrary() async {
  await timeline_view.loadLibrary();
  return true;
}

Future<bool> bellViewLoadLibrary() async {
  await bell_view.loadLibrary();
  return true;
}

Future<bool> cameraViewLoadLibrary() async {
  await camera_view.loadLibrary();
  return true;
}

Future<bool> profileViewLoadLibrary() async {
  await profile_view.loadLibrary();
  return true;
}

Future<bool> chatViewLoadLibrary() async {
  await chat_view.loadLibrary();
  return true;
}

Future<bool> searchViewLoadLibrary() async {
  await search_view.loadLibrary();
  return true;
}

// RemoteConfig
late FirebaseRemoteConfig remoteConfig;

// Google API's
late GooglePlayServicesAvailability availability;

// PageView
PageController pageController = PageController();

final List<Widget> pageButtonsWeb = [
  IconButtonTextHoverWidget(
    icon: pages[0].icon,
    label: 'timeline'.tr,
    onPressed: () => onTap(0),
    style: TextButton.styleFrom(primary: Colors.white),
  ),
  IconButtonTextHoverWidget(
    icon: pages[1].icon,
    label: 'bell'.tr,
    onPressed: () => onTap(1),
    style: TextButton.styleFrom(primary: Colors.white),
  ),
  IconButtonTextHoverWidget(
    icon: pages[2].icon,
    label: 'camera'.tr,
    onPressed: () => onTap(2),
    style: TextButton.styleFrom(primary: Colors.white),
  ),
  IconButtonTextHoverWidget(
    icon: pages[3].icon,
    label: 'profile'.tr,
    onPressed: () => onTap(3),
    style: TextButton.styleFrom(primary: Colors.white),
  ),
  IconButtonTextHoverWidget(
    icon: pages[4].icon,
    label: 'chat'.tr,
    onPressed: () => onTap(4),
    style: TextButton.styleFrom(primary: Colors.white),
  ),
  IconButtonTextHoverWidget(
    icon: pages[5].icon,
    label: 'search'.tr,
    onPressed: () => onTap(5),
    style: TextButton.styleFrom(primary: Colors.white),
  ),
];

void onTap(int pageIndex) {
  switchPage(pageIndex);
}

void switchPage(int pageIndex) {
  if (!kIsWeb) {
    pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 150),
      curve: Curves.bounceInOut,
    );
  } else {
    pageController.jumpToPage(pageIndex);
  }

  checkPage(pageIndex);
  setPage(pageIndex);
}

void checkPage(int pageIndex) {
  if (pageIndex == 2) {
    setPortraitOrientations();
  } else {
    setAllOrientations();
  }
}

void setPage(int pageIndex) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('pageIndex', pageIndex);
}

class App extends StatefulWidget {
  const App({
    Key? key,
    this.pageIndex = 0,
  }) : super(key: key);

  final int pageIndex;

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoad = false;
  bool isAuth = false;
  bool isAuthOffline = false;
  bool isDarkModeEnabled = false;

  int pageIndex = 0;
  String selectedLang = Translation.langs.first;

  final AuthProvider _auth = AuthProvider.instance;
  final UserService userService = UserService();

  @override
  void initState() {
    pageController = PageController(initialPage: widget.pageIndex);

    setPageIndex(widget.pageIndex);

    getPage();

    getDarkMode();

    if (!kIsWeb) {
      setRemoteConfig();

      checkGoogleApiAvailability();

      checkAdmobConsent();
    }

    getUserAuth();

    super.initState();
  }

  void setPageIndex(int pageIndex) {
    if (mounted) {
      setState(() {
        this.pageIndex = pageIndex;
      });
    }
  }

  void getPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? pageIndex = prefs.getInt('pageIndex');

    if (pageIndex != null) {
      setPageIndex(pageIndex);
    }
  }

  Future<void> load() async {
    if (!isLoad) {
      const int ms = 1000;

      print('Waiting $ms milliseconds to load page');

      await Future.delayed(const Duration(milliseconds: ms));

      if (mounted) {
        setState(() {
          isLoad = true;
        });
      }

      print('Page loaded');
    }
  }

  void checkAdmobConsent() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
        SchedulerBinding.instance.window.platformBrightness == Brightness.dark;

    Get.changeTheme(
      darkMode != null
          ? darkMode
              ? darkTheme
              : theme
          : darkBrightness
              ? darkTheme
              : theme,
    );

    isDarkModeEnabled = darkMode ?? darkBrightness;
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
      profile_create_view.ProfileCreateView(uid: uid),
    ) as FutureOr<Map<String, dynamic>>);

    logger.i('showProfileCreateView: ${result['username']}');

    return result;
  }

  Future<void> showIntroductionView() async {
    await introduction_view.loadLibrary();

    await Get.to(introduction_view.IntroductionView());

    logger.i('showIntroductionView');
  }

  void showAbout() async {
    final packageInfo = await package_info_plus.PackageInfo.fromPlatform();

    final String id =
        !kIsWeb ? packageInfo.packageName : html.window.location.hostname!;
    final String mobileVersion = Platform.isAndroid
        ? ('Android ' + packageInfo.version)
        : ('IOS ' + packageInfo.version);
    final String webVersion =
        !html.window.navigator.userAgent.toLowerCase().contains('electron')
            ? 'Web'
            : 'Electron';
    final String version = !kIsWeb ? mobileVersion : webVersion;

    final List<Map<String, dynamic>>? query =
        await FlybisService().streamMinimumPostDurations();
    final DateFormat mpdFormat = DateFormat('hh:mm:ss');
    final String minimumPostDuration = mpdFormat.format(
      DateTime.fromMillisecondsSinceEpoch(query![0]['minimumPostDuration']),
    );

    showAboutDialog(
      context: context,
      applicationIcon: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(left: 0, top: 0, right: 10, bottom: 25),
        child: ImageNetwork.cachedNetworkImage(
          imageUrl: 'https://flybis.net/assets/flybis_icon.png',
        ),
      ),
      applicationVersion: version,
      children: [
        utils_widget.UtilsWidget().selectableText('id: ' + id),
        utils_widget.UtilsWidget().selectableText(
          'minimumPostDuration: ' + minimumPostDuration,
        )
      ],
    );
  }

  void getUserAuth() async {
    flybisUserOwner = await _auth.getUserOffline();

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
          user.email!,
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
          await MessagingProvider.instance.configureMessaging(user.uid);
        }
      }
    });

    await load();
  }

  Future<void> configureAgoraIo() async {
    final HttpsCallable callableAgora = functions.httpsCallable(
      'getAgoraSignalingToken',
    );

    final HttpsCallableResult result = await callableAgora.call();

    agoraIoToken = result.data['token'];

    print('AgoraIo: ' + agoraIoToken);
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

  void onPageChanged(int pageIndex) {
    setPageIndex(pageIndex);

    checkPage(pageIndex);
  }

  Drawer drawer() {
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
                  flybisUserOwner!.photoUrl!,
                ),
              ),
              title: Text(
                '@${flybisUserOwner!.username}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                flybisUserOwner!.displayName!,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: pageColors[pageIndex],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              children: <Widget>[
                const ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Configurações'),
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Sobre'),
                  onTap: showAbout,
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Sair'),
                  onTap: () => _auth.signOut(context),
                ),
                DropdownButton(
                  icon: const Icon(Icons.arrow_drop_down),
                  value: selectedLang,
                  items: Translation.langs.map((String lang) {
                    return DropdownMenuItem(
                      value: lang,
                      child: Text(lang),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    // Updates dropdown selected value
                    setState(() => selectedLang = value!);
                    // Gets language and changes the locale
                    Translation().changeLocale(value);
                  },
                ),
                day_night_switcher.DayNightSwitcher(
                  isDarkModeEnabled: isDarkModeEnabled,
                  onStateChanged: setDarkMode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget body() {
    List<Widget> pages = [
      FutureBuilder(
        future: timelineViewLoadLibrary(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return const Text('');
          }

          return timeline_view.TimelineView(
            scaffoldKey: scaffoldKey,
            pageColor: pageColors[0],
            pageHeader: true,
          );
        },
      ),
      FutureBuilder(
        future: bellViewLoadLibrary(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return const Text('');
          }

          return bell_view.BellView(
            scaffoldKey: scaffoldKey,
            pageColor: pageColors[1],
            pageHeader: true,
          );
        },
      ),
      FutureBuilder(
        future: cameraViewLoadLibrary(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return const Text('');
          }

          return camera_view.CameraView(
            scaffoldKey: scaffoldKey,
            pageColor: pageColors[2],
            pageHeader: true,
          );
        },
      ),
      FutureBuilder(
        future: profileViewLoadLibrary(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return const Text('');
          }

          return profile_view.ProfileView(
            scaffoldKey: scaffoldKey,
            pageColor: pageColors[3],
            pageHeader: true,
            uid: flybisUserOwner!.uid,
          );
        },
      ),
      FutureBuilder(
        future: chatViewLoadLibrary(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return const Text('');
          }

          return chat_view.ChatView(
            scaffoldKey: scaffoldKey,
            pageColor: pageColors[4],
            pageHeader: true,
          );
        },
      ),
      FutureBuilder(
        future: searchViewLoadLibrary(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return const Text('');
          }

          return search_view.SearchView(
            pageColor: pageColors[5],
            pageHeader: true,
          );
        },
      ),
    ];

    if (kIsWeb) {
      return pages[widget.pageIndex];
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
      physics: !kIsWeb
          ? const AlwaysScrollableScrollPhysics()
          : const ClampingScrollPhysics(),
    );
  }

  BottomNavigationBar bottom() {
    return BottomNavigationBar(
      currentIndex: pageIndex,
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
        bottomItem(pages[0].color, pages[0].iconData),
        bottomItem(pages[1].color, pages[1].iconData),
        bottomItem(pages[2].color, pages[2].iconData),
        bottomItem(pages[3].color, pages[3].iconData),
        bottomItem(pages[4].color, pages[4].iconData),
        bottomItem(pages[5].color, pages[5].iconData),
      ],
    );
  }

  BottomNavigationBarItem bottomItem(
    Color color,
    IconData icon,
  ) {
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: Theme.of(context).iconTheme.color,
      ),
      activeIcon: Icon(
        icon,
        color: color,
      ),
      label: '',
    );
  }

  Widget app(BuildContext context) {
    final Alignment bodyAlignment = kNotIsWebOrScreenLittle(context)
        ? Alignment.center
        : Alignment.centerRight;
    final double bodyWidth = kNotIsWebOrScreenLittle(context)
        ? MediaQuery.of(context).size.width
        : kWebBodyWidth(context);

    Widget leftDrawer({Widget? child}) => kNotIsWebOrScreenLittle(context)
        ? const Padding(padding: EdgeInsets.zero)
        : SizedBox(width: kWebDrawerWidth, child: child);

    return Scaffold(
      primary: true,
      key: scaffoldKey,
      drawer: kNotIsWebOrScreenLittle(context) ? drawer() : null,
      body: Stack(
        children: [
          Align(
            alignment: bodyAlignment,
            child: SizedBox(
              width: bodyWidth,
              child: body(),
            ),
          ),
          leftDrawer(child: drawer()),
        ],
      ),
      bottomNavigationBar: kNotIsWebOrScreenLittle(context) ? bottom() : null,
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
          return const Text('');
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
