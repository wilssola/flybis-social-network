// 🎯 Dart imports:
import 'dart:math';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:octo_image/octo_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

// 🌎 Project imports:
import 'package:flybis/constants/const.dart';
import 'package:flybis/plugins/image_network/image_network.dart';
import 'package:flybis/services/api_service.dart';

class UtilsWidget {
  PreferredSizeWidget header(
    BuildContext context, {
    GlobalKey<ScaffoldState> scaffoldKey,
    String titleText = '',
    Color pageColor = Colors.red,
    bool pageHeaderWeb = false,
    bool removeBackButton = false,
  }) {
    bool isAppTitle = titleText.length == 0;

    return AppBar(
      centerTitle: false,
      iconTheme: IconThemeData(color: Colors.white),
      automaticallyImplyLeading: !removeBackButton,
      backgroundColor: pageColor,
      leading: scaffoldKey != null && (kNotIsWebOrScreenLittle(context))
          ? Builder(
              builder: (context) => IconButton(
                icon: Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
                onPressed: () => scaffoldKey.currentState.openDrawer(),
              ),
            )
          : null,
      title: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 25),
            child: Text(
              isAppTitle ? 'FLYBIS' : titleText,
              style: TextStyle(
                color: Colors.white,
                fontFamily: isAppTitle ? 'Nexa' : 'roboto',
                fontSize: isAppTitle ? 30.0 : 20.0,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Spacer(),
          (kNotIsWebOrScreenLittle(context) || !pageHeaderWeb)
              ? Padding(padding: EdgeInsets.zero)
              : Container(
                  height: 50.0,
                  width: MediaQuery.of(context).size.width > 1080
                      ? 600
                      : MediaQuery.of(context).size.width > 720
                          ? 400
                          : 0,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      children: [], //pageButtonsWeb,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget logoText(List<Color> pageColors) {
    List<Color> localPageColors = pageColors;
    //localPageColors..shuffle();

    return ColorizeAnimatedTextKit(
      onTap: () {
        print('Tap Event');
      },
      text: [
        'FLYBIS',
      ],
      repeatForever: true,
      isRepeatingAnimation: true,
      totalRepeatCount: 10,
      speed: Duration(milliseconds: 2500),
      pause: Duration(milliseconds: 1),
      colors: pageColors,
      textStyle: TextStyle(fontSize: 85.0, fontFamily: 'Nexa'),
      textAlign: TextAlign.center,
    );

    if (!kIsWeb) {
      return RichText(
        text: TextSpan(
          style: TextStyle(fontFamily: 'Nexa', fontSize: 75.0),
          children: <TextSpan>[
            TextSpan(text: 'F', style: TextStyle(color: pageColors[0])),
            TextSpan(text: 'L', style: TextStyle(color: pageColors[1])),
            TextSpan(text: 'Y', style: TextStyle(color: pageColors[2])),
            TextSpan(text: 'B', style: TextStyle(color: pageColors[3])),
            TextSpan(text: 'I', style: TextStyle(color: pageColors[4])),
            TextSpan(text: 'S', style: TextStyle(color: pageColors[5])),
          ],
        ),
      );
    } else {
      return Text(
        'FLYBIS',
        style: TextStyle(
          fontFamily: 'Nexa',
          fontSize: 75.0,
          color: pageColors[Random().nextInt(pageColors.length)],
        ),
      );
    }
  }

  Widget adaptiveImage(BuildContext context, String url, String blurHash,
      {BoxFit fit = BoxFit.cover}) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth:
            !kIsWeb ? MediaQuery.of(context).size.width : widthWeb(context),
        maxWidth:
            !kIsWeb ? MediaQuery.of(context).size.width : widthWeb(context),
        minHeight:
            !kIsWeb ? MediaQuery.of(context).size.width : widthWeb(context),
        maxHeight:
            !kIsWeb ? MediaQuery.of(context).size.width : widthWeb(context),
      ),
      child: OctoImage(
        image: ImageNetwork.cachedNetworkImageProvider(url != null ? url : ''),
        placeholderBuilder: OctoPlaceholder.blurHash(blurHash),
        errorBuilder: OctoError.icon(color: Colors.red),
        fit: fit,
      ),
      /*ImageNetwork.cachedNetworkImage(
        imageUrl: contentUrl != null ? contentUrl : '',
        fit: fit,
        placeholder: (context, url) => Padding(
          child: circularProgress(
            context,
          ),
          padding: EdgeInsets.all(17.5),
        ),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),*/
    );
  }

  Widget adaptiveVideo(context, controller) {
    return ClipRect(
      child: Container(
        child: Transform.scale(
          scale: (controller.value.aspectRatio) /
              (MediaQuery.of(context).size.aspectRatio * 1.2),
          child: Center(
            child: AspectRatio(
              aspectRatio: MediaQuery.of(context).size.width /
                  (MediaQuery.of(context).size.width * 0.825),
              child: VideoPlayer(controller),
            ),
          ),
        ),
      ),
    );
  }

  Widget infoText(String text) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(15),
        child: selectableText(
          text,
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget listViewContainer(BuildContext context, Widget child) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: child,
    );
  }

  Text usernameText(String username) {
    return Text(
      username.length > 0 ? '@' + username : '',
      style: usernameStyle(),
    );
  }

  TextStyle usernameStyle() {
    return TextStyle(
      color: Colors.blue,
      fontWeight: !kIsWeb ? FontWeight.bold : FontWeight.normal,
    );
  }

  Widget selectableText(
    String content, {
    TextStyle style,
    TextAlign textAlign,
  }) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (keyEvent) {
        // If user presses Cmd + C
        if (keyEvent.physicalKey == PhysicalKeyboardKey.keyC &&
            keyEvent.isMetaPressed) {
          // Copy data to clipboard
          Clipboard.setData(ClipboardData(text: content));
        }
      },
      child: SelectableText(
        content,
        style: style,
        textAlign: textAlign,
      ),
    );
  }

  Widget floatingButtonUp(
    bool showToUpButton,
    bool toUpButton,
    IconData icon,
    Color pageColor,
    Function scrollToUp,
    String tag,
  ) {
    return AnimatedOpacity(
      opacity: showToUpButton && toUpButton ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500),
      child: showToUpButton || toUpButton
          ? FloatingActionButton(
              backgroundColor: pageColor,
              child: Icon(icon, color: Colors.white),
              onPressed: () => scrollToUp,
              heroTag: tag,
            )
          : Padding(padding: EdgeInsets.zero),
    );
  }

  Container linearProgress(
    BuildContext context, {
    Color valueColor = Colors.white,
  }) {
    return Container(
      child: LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation(valueColor),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }

  Container circularProgress(
    BuildContext context, {
    Color color,
  }) {
    return Container(
      alignment: Alignment(0.0, 0.0),
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(
          color != null ? color : Theme.of(context).iconTheme.color,
        ),
      ),
    );
  }

  Container centerCircularProgress(
    BuildContext context, {
    Color color,
    double height,
  }) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      width: MediaQuery.of(context).size.width,
      height: height != null ? height : MediaQuery.of(context).size.height,
      child: circularProgress(
        context,
        color: color != null ? color : Theme.of(context).primaryColor,
      ),
    );
  }

  Container scaffoldCenterCircularProgress(
    BuildContext context, {
    Color color,
  }) {
    double sizeHeight = MediaQuery.of(context).size.height;

    double appBarMaxHeight = Scaffold.of(context).appBarMaxHeight;

    double calc1 = sizeHeight - double.parse(appBarMaxHeight.toString());
    double calc2 = calc1 - kAppBottomBarHeight;

    double height = (kNotIsWebOrScreenLittle(context)) ? calc2 : calc1;

    return centerCircularProgress(context, color: color, height: height);
  }

  Widget formInput(
    GlobalKey<FormState> key,
    Function(String) onSaved,
    String labelText,
    String hintText,
    String minText,
    String maxText,
    int minLength,
    int maxLength, {
    String prefixText = '',
    Function validator,
    TextInputType keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: 25,
        right: 25,
      ),
      child: Container(
        margin: EdgeInsets.only(
          bottom: 15,
        ),
        child: Form(
          key: key,
          //autovalidate: true,
          autovalidateMode: AutovalidateMode.always,
          child: TextFormField(
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            onSaved: onSaved,
            validator: (String value) {
              if (value.trim().length < minLength) {
                return minText;
              } else if (value.trim().length > maxLength) {
                return maxText;
              } else {
                if (validator != null) {
                  validator(value);
                }

                return null;
              }
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
              labelText: labelText,
              labelStyle: TextStyle(fontSize: 15.0),
              hintText: hintText,
              prefixText: prefixText,
            ),
          ),
        ),
      ),
    );
  }

  void snackbarWebMissing() {
    snackbar('Not Available On Web');
  }

  void snackbar(String message) {
    Get.snackbar('Flybis', message);
  }

  Widget webBody(
    BuildContext context, {
    Widget child,
    double multiply = 1,
  }) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: widthWeb(context) * multiply,
        child: child,
      ),
    );
  }

  Widget infoError(String text) {
    return FutureBuilder(
      future: ApiService.instance.getErrorTenor(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return Column(
          children: [
            infoText(text),
            snapshot.hasData
                ? Container(
                    padding: EdgeInsets.only(bottom: 15),
                    child: ImageNetwork.cachedNetworkImage(
                      imageUrl: snapshot.data,
                    ),
                  )
                : Padding(padding: EdgeInsets.zero),
          ],
        );
      },
    );
  }

  Widget shimmer(BuildContext context, {double height}) {
    return SizedBox(
      height: height,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).scaffoldBackgroundColor,
        highlightColor: Colors.grey,
        child: Container(
          height: height,
          margin: EdgeInsets.only(top: 1, bottom: 1),
          padding: EdgeInsets.only(top: 1, bottom: 1),
          color: Colors.grey,
        ),
      ),
    );
  }
}
