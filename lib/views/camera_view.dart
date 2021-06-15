// Dart

// 🎯 Dart imports:
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// 📦 Package imports:
import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/functions.dart';
import 'package:detectable_text_field/widgets/detectable_text_field.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_better_camera/camera.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as image;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:photofilters/photofilters.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

// 🌎 Project imports:
import 'package:flybis/constants/const.dart';
import 'package:flybis/global.dart';
import 'package:flybis/models/post_model.dart';
import 'package:flybis/plugins/image_network/image_network.dart';
import 'package:flybis/services/messaging_service.dart';
import 'package:flybis/services/post_service.dart';
import 'package:flybis/widgets/utils_widget.dart' as utils_widget;
import 'package:flybis/widgets/video_editor_widget.dart';
import 'package:flybis/widgets/video_widget.dart';

class CameraView extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  final String pageId = 'Camera';
  final Color? pageColor;
  final bool pageHeaderWeb;

  CameraView({
    required this.scaffoldKey,
    this.pageColor,
    this.pageHeaderWeb = false,
  });

  @override
  CameraViewState createState() => CameraViewState();
}

class CameraViewState extends State<CameraView>
    with AutomaticKeepAliveClientMixin<CameraView> {
  List<PickedFile?> files = [];

  late String imagePath;
  late String videoPath;
  String? contentType;
  bool isUploading = false;

  String? postId;
  TextEditingController captionControler = TextEditingController();
  TextEditingController locationControler = TextEditingController();

  bool cameraIsInitialized = false;
  late int indexCamera;
  Color? cameraIconColor;
  bool hasCamera = false;
  bool enableFlash = false;
  List<CameraDescription>? cameras;
  CameraController? cameraController;

  late VideoPlayerController videoPlayerController;

  final thumbWidth = 100;
  final thumbHeight = 150;
  //List<VideoInfo> _videos = <VideoInfo>[];
  bool _imagePickerActive = false;
  bool _processing = false;
  bool _canceled = false;
  double _progress = 0.0;
  int _videoDuration = 0;
  String _processPhase = '';
  final bool _debugMode = false;

  Widget _getProgressBar() {
    return Container(
      padding: EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 30.0),
            child: Text(_processPhase),
          ),
          LinearProgressIndicator(
            value: _progress,
          ),
        ],
      ),
    );
  }

  void _onUploadProgress(TaskSnapshot event) {
    if (event.state == TaskState.running) {
      final double progress = event.bytesTransferred / event.totalBytes;

      logger.i('_onUploadProgress: $progress');

      EasyLoading.showProgress(
        0.5, //min((event.bytesTransferred / event.totalBytes * 100), 100),
        status: 'Uploading...',
      );

      MessagingService()
          .showProgressNotification(event.bytesTransferred, event.totalBytes);
    }
  }

  @override
  void initState() {
    if (!kIsWeb) {
      initCamera();
      //initFFmpegService();
    }

    super.initState();
  }

  void initCamera() {
    availableCameras().then((List<CameraDescription> availableCameras) {
      cameras = availableCameras;

      if (cameras!.length > 0) {
        if (mounted) {
          setState(() {
            indexCamera = 0;
          });
        }

        initCameraController(cameras![indexCamera]);

        print('Has ${cameras!.length.toString()} Cameras Availables');
      } else {
        print('No Cameras Availables');
      }
    }).catchError((error) {
      print(error);
    });

    if (cameraController != null) {
      cameraController!.initialize().then((_) {
        if (mounted) {
          setState(() {
            cameraController = cameraController;
          });
        }
      });
    }
  }

  Future initCameraController(CameraDescription cameraDescription) async {
    if (cameraController != null) {
      setState(() {
        cameraIsInitialized = false;
      });

      await cameraController!.dispose();
    }

    setState(() {
      cameraController = CameraController(
        cameraDescription,
        ResolutionPreset.high,
      );
    });

    // If the controller is updated then update the UI.
    cameraController!.addListener(() {
      if (cameraController!.value.hasError) {
        print('Camera Error ${cameraController!.value.errorDescription}');
      }

      if (cameraController!.value.isInitialized!) {
        setState(() {
          cameraIsInitialized = true;
        });
      }
    });

    try {
      await cameraController!.initialize();
    } on CameraException catch (error) {
      print(error);
    }
  }

  Widget cameraToggle() {
    if (cameras == null || cameras!.isEmpty) {
      return Spacer();
    }

    CameraDescription selectedCamera = cameras![indexCamera];
    CameraLensDirection? lensDirection = selectedCamera.lensDirection;

    return Container(
      child: Align(
        alignment: Alignment.centerLeft,
        child: FlatButton.icon(
          onPressed: onSwitchCamera,
          icon: Icon(
            getCameraLensIcon(lensDirection),
            color: Colors.white,
          ),
          label: Text(
            lensDirection
                    .toString()
                    .substring(lensDirection.toString().indexOf('.') + 1)[0]
                    .toUpperCase() +
                lensDirection
                    .toString()
                    .substring(lensDirection.toString().indexOf('.') + 1)
                    .substring(1),
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget cameraFlash() {
    if (cameras == null || cameras!.isEmpty) {
      return Spacer();
    }

    return Container(
      child: Align(
        alignment: Alignment.centerRight,
        child: FlatButton.icon(
          onPressed: () {
            //TorchCompat.turnOn();
          }, //onFlash,
          icon: Icon(
            Icons.wb_sunny,
            color: Colors.white,
          ),
          label: Text(
            'Lanterna',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget cameraGallery() {
    if (cameras == null || cameras!.isEmpty) {
      return Spacer();
    }

    return galleryButton();
  }

  Widget galleryButton() {
    if (!kIsWeb) {
      return Container(
        child: Align(
          alignment: Alignment.centerRight,
          child: FlatButton.icon(
            onPressed: gallerySelect,
            icon: Icon(
              Icons.image,
              color: Colors.white,
            ),
            label: Text(
              'Galeria',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: Card(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: gallerySelect,
              child: Container(
                padding: EdgeInsets.all(25),
                height: 275,
                child: Icon(
                  Icons.cloud,
                  color: Theme.of(context).iconTheme.color,
                  size: 225,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  setUuid() {
    postId = Uuid().v4();
  }

  Widget cameraButton() {
    return GestureDetector(
      child: Icon(
        Icons.camera,
        size: 100,
        color: cameraIconColor != null ? cameraIconColor : Colors.white,
      ),
      onTap: () => onCaptureImage(context),
      onLongPress: () => startCaptureVideo(),
      onLongPressUp: () => stopCaptureVideo(context),
    );
  }

  IconData getCameraLensIcon(CameraLensDirection? direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_rear;
      case CameraLensDirection.front:
        return Icons.camera_front;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        return Icons.device_unknown;
    }
  }

  void onSwitchCamera() {
    indexCamera = indexCamera < cameras!.length - 1 ? indexCamera + 1 : 0;

    CameraDescription selectedCamera = cameras![indexCamera];

    initCameraController(selectedCamera);
  }

  void onFlash() {
    if (mounted) {
      setState(() {
        if (enableFlash) {
          //TorchCompat.turnOff();
          enableFlash = false;
        } else if (!enableFlash) {
          //TorchCompat.turnOn();
          enableFlash = true;
        }
      });
    }
  }

  void onCaptureImage(context) async {
    setUuid();

    try {
      imagePath = (await getTemporaryDirectory()).path + '/$postId.jpg';
      await cameraController!.takePicture(imagePath);

      contentType = 'image';
      setState(() {
        this.files.add(PickedFile(imagePath));
      });
    } catch (error) {
      print(error);
    }
  }

  void startCaptureVideo() async {
    setUuid();

    try {
      videoPath = (await getTemporaryDirectory()).path + '/$postId.mp4';
      await cameraController!.startVideoRecording(videoPath);

      cameraIconColor = Colors.red;
    } catch (error) {
      print(error);
    }
  }

  void stopCaptureVideo(context) async {
    try {
      await cameraController!.stopVideoRecording();

      cameraIconColor = Colors.white;

      contentType = 'video';

      if (mounted) {
        setState(() {
          this.files.add(PickedFile(videoPath));
        });
      }

      videoPlayerController = VideoPlayerController.file(File(videoPath))
        ..initialize();
      videoPlayerController.setLooping(true);
      videoPlayerController.play();
    } catch (error) {
      print(error);
    }
  }

  @override
  void dispose() {
    super.dispose();

    if (!kIsWeb) {
      cameraController?.dispose();
      //TorchCompat.dispose();
    }
  }

  galleryVideo() async {
    setUuid();

    Navigator.pop(context);

    PickedFile? file =
        await ImagePicker().getVideo(source: ImageSource.gallery);

    if (mounted) {
      setState(() {
        this.contentType = 'video';
        this.files.add(file);
      });
    }
  }

  galleryImage() async {
    setUuid();

    Navigator.pop(context);

    PickedFile? file =
        await ImagePicker().getImage(source: ImageSource.gallery);

    if (mounted) {
      setState(() {
        this.contentType = 'image';
        this.files.add(file);
      });
    }
  }

  gallerySelect() {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Row(
            children: <Widget>[
              Icon(Icons.image),
              Padding(padding: EdgeInsets.all(5)),
              Text('Galeria'),
            ],
          ),
          children: <Widget>[
            SimpleDialogOption(
              child: Row(
                children: <Widget>[
                  Icon(Icons.camera),
                  Padding(padding: EdgeInsets.all(5)),
                  Text('Imagem'),
                ],
              ),
              onPressed: galleryImage,
            ),
            SimpleDialogOption(
              child: Row(
                children: <Widget>[
                  Icon(Icons.videocam),
                  Padding(padding: EdgeInsets.all(5)),
                  Text('Vídeo'),
                ],
              ),
              onPressed: galleryVideo,
            ),
            SimpleDialogOption(
              child: Row(
                children: <Widget>[
                  Icon(Icons.clear),
                  Padding(padding: EdgeInsets.all(5)),
                  Text('Cancelar'),
                ],
              ),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  Future<String> uploadFile(PickedFile file) async {
    late UploadTask uploadTask;

    Uint8List fileData = await file.readAsBytes();

    if (contentType == 'image') {
      try {
        uploadTask = storage
            .child(flybisUserOwner!.uid! + '/posts/images/$postId/$postId.jpg')
            .putData(
              fileData,
              SettableMetadata(contentType: 'image/jpeg'),
            );
      } catch (error) {
        print('Image upload error: $error');
      }
    } else if (contentType == 'video') {
      try {
        uploadTask = storage
            .child(flybisUserOwner!.uid! + '/posts/videos/$postId/$postId.mp4')
            .putData(
              fileData,
              SettableMetadata(contentType: 'video/mp4'),
            );
      } catch (error) {
        print('Video upload error: $error');
      }
    }

    uploadTask.snapshotEvents.listen(_onUploadProgress);

    TaskSnapshot storageSnap = await uploadTask;
    String downloadUrl = await storageSnap.ref.getDownloadURL();

    return downloadUrl;
  }

  Future filterImage(BuildContext context) async {
    var fileName = files[0]!.path.split('/').last;
    var imageDecode =
        image.decodeImage(File(files[0]!.path).readAsBytesSync())!;
    imageDecode = image.copyResize(imageDecode, width: 600);

    Map? imagefile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoFilterSelector(
          title: Text('Photo Filter Example'),
          image: imageDecode,
          filters: presetFiltersList,
          filename: fileName,
          loader: Center(child: CircularProgressIndicator()),
          fit: BoxFit.contain,
          //backgroundColor: widget.pageColor,
        ),
      ),
    );

    if (imagefile != null && imagefile.containsKey('image_filtered')) {
      if (mounted) {
        setState(() {
          files[0] = PickedFile((imagefile['image_filtered'] as File).path);
        });
      }
    }
  }

  getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];

    String formatedAdress;
    if (placemark.locality!.length > 0 && placemark.country!.length > 0) {
      formatedAdress = '${placemark.locality}, ${placemark.country}';
    } else if (placemark.locality!.length > 0) {
      formatedAdress = '${placemark.locality}';
    } else if (placemark.country!.length > 0) {
      formatedAdress = '${placemark.country}';
    } else {
      formatedAdress = 'Desconhecido';
    }

    locationControler.text = formatedAdress;
  }

  void createPostInFirestore({
    String? contentUrl,
    String? postTitle,
    String? postLocation,
    required String postDescription,
  }) {
    FlybisPost post = FlybisPost(
      // User
      userId: flybisUserOwner!.uid,
      // Post
      postId: postId,
      postTitle: postTitle,
      postLocation: postLocation,
      postDescription: postDescription,
      postContents: [
        FlybisPostContent(contentUrl: contentUrl, contentType: contentType)
      ],
      postTags: extractDetections(postDescription, hashTagRegExp),
      postMentions: extractDetections(postDescription, atSignRegExp),
    );

    PostService().setPost(post);
  }

  void post() async {
    if (mounted) {
      setState(() {
        isUploading = true;
      });
    }

    String contentUrl;

    contentUrl = await uploadFile(files[0]!);

    createPostInFirestore(
      contentUrl: contentUrl,
      postLocation: locationControler.text,
      postDescription: captionControler.text,
    );

    captionControler.clear();
    locationControler.clear();

    if (mounted) {
      setState(() {
        files = [];
        isUploading = false;
        postId = Uuid().v4();
      });
    }
  }

  void compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;

    image.Image imageFile =
        image.decodeImage(File(files[0]!.path).readAsBytesSync())!;

    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(image.encodeJpg(imageFile, quality: 85));

    if (mounted) {
      setState(() {
        //file = compressedImageFile;
      });
    }
  }

  void clearImage() {
    if (mounted) {
      setState(() {
        files = [];
      });
    }
  }

  Scaffold camera(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: appBar() as PreferredSizeWidget?,
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: AspectRatio(
              aspectRatio: cameraController!.value.aspectRatio,
              child: CameraPreview(
                cameraController!,
              ),
            ),
          ),
          Positioned(
            bottom: orientation == Orientation.portrait ? 25 : null,
            top: orientation == Orientation.portrait ? null : 25,
            left: orientation == Orientation.portrait ? 15 : null,
            right: orientation == Orientation.portrait ? null : 15,
            child: cameraToggle(),
          ),
          Positioned(
            bottom: orientation == Orientation.portrait ? 25 : 0,
            top: orientation == Orientation.portrait ? null : 0,
            left: orientation == Orientation.portrait ? 0 : null,
            right: orientation == Orientation.portrait ? 0 : 15,
            child: cameraButton(),
          ),
          Positioned(
            top: 25,
            right: 15,
            child: cameraFlash(),
          ),
          Positioned(
            bottom: 25,
            right: 15,
            child: cameraGallery(),
          ),
        ],
      ),
    );
  }

  Widget appBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(0),
      child: AppBar(
        backgroundColor: widget.pageColor,
      ),
    );
  }

  Scaffold webScreen() {
    return Scaffold(
      appBar: utils_widget.UtilsWidget().header(
        context,
        titleText: 'Câmera',
        pageColor: widget.pageColor,
        scaffoldKey: widget.scaffoldKey,
        pageHeaderWeb: widget.pageHeaderWeb,
      ),
      body: Center(
        child: Container(
          child: galleryButton(),
        ),
      ),
    );
  }

  Scaffold postForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.pageColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: clearImage,
        ),
        title: Text('Caption Post'),
        actions: <Widget>[
          FlatButton(
            child: Text('Post'),
            onPressed: isUploading ? null : () => post(),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                child: contentType == 'image'
                    ? AspectRatio(
                        aspectRatio: MediaQuery.of(context).size.width /
                            (MediaQuery.of(context).size.height * 0.5),
                        child: Stack(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: !kIsWeb
                                      ? Image.file(File(files[0]!.path)).image
                                      : Image.network(files[0]!.path).image,
                                ),
                              ),
                            ),
                            !kIsWeb
                                ? Positioned(
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      width: 200.0,
                                      height: 100.0,
                                      alignment: Alignment.center,
                                      child: RaisedButton.icon(
                                        color: Colors.blue,
                                        icon: Icon(
                                          Icons.remove_red_eye,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          'Aplicar Filtros',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        onPressed: () {
                                          filterImage(context);
                                        },
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.zero,
                                  ),
                          ],
                        ),
                      )
                    : (contentType == 'video'
                        ? Stack(
                            children: <Widget>[
                              VideoWidget(
                                type: kIsWeb
                                    ? VideoSourceType.url
                                    : VideoSourceType.file,
                                source: files[0]!.path,
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                child: Container(
                                  width: 200.0,
                                  height: 100.0,
                                  alignment: Alignment.center,
                                  child: RaisedButton.icon(
                                    color: Colors.blue,
                                    icon: Icon(
                                      Icons.remove_red_eye,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      'Editar Vídeo',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    onPressed: () {
                                      Get.to(VideoEditor(
                                          file: File(files[0]!.path)));
                                    },
                                  ),
                                ),
                              )
                            ],
                          )
                        : Text('')),
              ),
              isUploading
                  ? utils_widget.UtilsWidget().linearProgress(context)
                  : Padding(padding: EdgeInsets.zero),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: ImageNetwork.cachedNetworkImageProvider(
                flybisUserOwner!.photoUrl!,
              ),
            ),
            title: DetectableTextField(
              maxLines: 5,
              showCursor: true,
              controller: captionControler,
              detectionRegExp: hashTagAtSignUrlRegExp,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Write a caption',
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.pin_drop,
                color: Theme.of(context).iconTheme.color, size: 35),
            title: Row(
              children: <Widget>[
                Container(
                  width: 190,
                  child: TextField(
                    controller: locationControler,
                    decoration: InputDecoration(
                      hintText: 'Where was this photo taken ?',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Spacer(),
                !kIsWeb
                    ? RaisedButton.icon(
                        color: Colors.blue,
                        icon: Icon(
                          Icons.pin_drop,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Get Now',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            15,
                          ),
                        ),
                        onPressed: getUserLocation,
                      )
                    : Padding(
                        padding: EdgeInsets.zero,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => !kIsWeb ? false : false;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (files.length == 0) {
      if (!kIsWeb) {
        // Test camera return first
        //return camera();

        if (cameraController != null && cameraIsInitialized) {
          return camera(context);
        } else {
          return Scaffold(
            appBar: appBar() as PreferredSizeWidget?,
            body: Container(color: Colors.black),
          );
        }
      } else {
        return webScreen();
      }
    } else {
      return postForm();
    }
  }
}
