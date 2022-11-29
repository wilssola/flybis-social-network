// Dart

// 🎯 Dart imports:
import 'dart:io';
import 'dart:typed_data';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/functions.dart';
import 'package:detectable_text_field/widgets/detectable_text_field.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_better_camera/camera.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flybis/app/widgets/utils_widget.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as image;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photofilters/photofilters.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

// 🌎 Project imports:
import 'package:flybis/core/values/const.dart';
import 'package:flybis/global.dart';
import 'package:flybis/app/data/models/post_model.dart';
import 'package:flybis/plugins/image_network/image_network.dart';
import 'package:flybis/app/data/providers/messaging_provider.dart';
import 'package:flybis/app/data/services/post_service.dart';
import 'package:flybis/app/widgets/utils_widget.dart' as utils_widget;
import 'package:flybis/app/widgets/video_editor_widget.dart';
import 'package:flybis/app/widgets/video_widget.dart';

enum CameraFileType { image, video }

class CameraView extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  final String pageId = 'Camera';
  final Color? pageColor;
  final bool pageHeader;

  const CameraView({
    required this.scaffoldKey,
    this.pageColor,
    this.pageHeader = false,
  });

  @override
  CameraViewState createState() => CameraViewState();
}

class CameraViewState extends State<CameraView>
    with AutomaticKeepAliveClientMixin<CameraView> {
  List<XFile?> files = [];

  late String imagePath;
  late String videoPath;
  late CameraFileType contentType;
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
  final bool _imagePickerActive = false;
  final bool _processing = false;
  final bool _canceled = false;
  final double _progress = 0.0;
  final int _videoDuration = 0;
  final String _processPhase = '';
  final bool _debugMode = false;

  Widget _getProgressBar() {
    return Container(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(bottom: 30.0),
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

      MessagingProvider.instance
          .showProgressNotification(event.bytesTransferred, event.totalBytes);
    }
  }

  @override
  void initState() {
    if (!kIsWeb) initCamera();

    super.initState();
  }

  void initCamera() {
    availableCameras().then((List<CameraDescription> availableCameras) {
      cameras = availableCameras;

      if (cameras!.isNotEmpty) {
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
      return const Spacer();
    }

    CameraDescription selectedCamera = cameras![indexCamera];
    CameraLensDirection? lensDirection = selectedCamera.lensDirection;

    return Container(
      child: Align(
        alignment: Alignment.centerLeft,
        child: MaterialButton(
          onPressed: onSwitchCamera,
          child: Row(
            children: [
              Icon(
                getCameraLensIcon(lensDirection),
                color: Colors.white,
              ),
              Text(
                lensDirection
                        .toString()
                        .substring(lensDirection.toString().indexOf('.') + 1)[0]
                        .toUpperCase() +
                    lensDirection
                        .toString()
                        .substring(lensDirection.toString().indexOf('.') + 1)
                        .substring(1),
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cameraFlash() {
    if (cameras == null || cameras!.isEmpty) {
      return const Spacer();
    }

    return Container(
      child: Align(
        alignment: Alignment.centerRight,
        child: MaterialButton(
          onPressed: () {
            //TorchCompat.turnOn();
          }, //onFlash,
          child: Row(
            children: [
              const Icon(Icons.wb_sunny, color: Colors.white),
              const Text(
                'Lanterna',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cameraGallery() {
    if (cameras == null || cameras!.isEmpty) {
      return const Spacer();
    }

    return galleryButton();
  }

  Widget galleryButton() {
    if (!kIsWeb) {
      return Container(
        child: Align(
          alignment: Alignment.centerRight,
          child: MaterialButton(
            onPressed: gallerySelect,
            child: Row(
              children: [
                const Icon(
                  Icons.image,
                  color: Colors.white,
                ),
                const Text(
                  'Galeria',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                )
              ],
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
                padding: const EdgeInsets.all(25),
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
    postId = const Uuid().v4();
  }

  Widget cameraButton() {
    return GestureDetector(
      child: Icon(
        Icons.camera,
        size: 100,
        color: cameraIconColor ?? Colors.white,
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

      contentType = CameraFileType.image;
      setState(() {
        files.add(XFile(imagePath));
      });
    } catch (error) {
      print(error);
    }
  }

  void startCaptureVideo() async {
    setUuid();

    try {
      Directory directory = await getTemporaryDirectory();

      videoPath = '${directory.path}/$postId.mp4';

      await cameraController!.startVideoRecording(videoPath);

      if (mounted) {
        setState(() {
          cameraIconColor = Colors.red;
        });
      }
    } catch (error) {
      print(error);
    }
  }

  void stopCaptureVideo(context) async {
    try {
      await cameraController!.stopVideoRecording();

      contentType = CameraFileType.video;

      if (mounted) {
        setState(() {
          cameraIconColor = Colors.white;

          files.add(XFile(videoPath));
        });
      }

      videoPlayerController = VideoPlayerController.file(File(videoPath));
      videoPlayerController.initialize();
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

    XFile? file = await ImagePicker().pickVideo(source: ImageSource.gallery);

    if (mounted) {
      setState(() {
        contentType = CameraFileType.video;
        files.add(file);
      });
    }
  }

  void galleryImage() async {
    setUuid();

    Navigator.pop(context);

    XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (mounted) {
      setState(() {
        contentType = CameraFileType.image;
        files.add(file);
      });
    }
  }

  gallerySelect() {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Row(
            children: const <Widget>[
              Icon(Icons.image),
              Padding(padding: EdgeInsets.all(5)),
              Text('Galeria'),
            ],
          ),
          children: <Widget>[
            SimpleDialogOption(
              child: Row(
                children: const <Widget>[
                  Icon(Icons.camera),
                  Padding(padding: EdgeInsets.all(5)),
                  Text('Imagem'),
                ],
              ),
              onPressed: galleryImage,
            ),
            SimpleDialogOption(
              child: Row(
                children: const <Widget>[
                  Icon(Icons.videocam),
                  Padding(padding: EdgeInsets.all(5)),
                  Text('Vídeo'),
                ],
              ),
              onPressed: galleryVideo,
            ),
            SimpleDialogOption(
              child: Row(
                children: const <Widget>[
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

  Future<String> uploadFile(XFile file) async {
    late UploadTask uploadTask;

    const String imageMetaContentType = 'image/jpeg';
    const String videoMetaContentType = 'video/mp4';

    String imagePath =
        '${flybisUserOwner!.uid}/posts/images/$postId/$postId.jpg';
    String videoPath =
        '${flybisUserOwner!.uid}/posts/videos/$postId/$postId.mp4';

    String metaContentType = contentType == CameraFileType.image
        ? imageMetaContentType
        : videoMetaContentType;

    String path = contentType == CameraFileType.image ? imagePath : videoPath;

    Uint8List fileData = await file.readAsBytes();

    try {
      uploadTask = storage
          .child(path)
          .putData(fileData, SettableMetadata(contentType: metaContentType));
    } catch (error) {
      print('File upload error: $error');
    }

    uploadTask.snapshotEvents.listen(_onUploadProgress);

    TaskSnapshot uploadSnapshot = await uploadTask;

    String downloadUrl = await uploadSnapshot.ref.getDownloadURL();

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
          title: const Text('Photo Filter Example'),
          image: imageDecode,
          filters: presetFiltersList,
          filename: fileName,
          loader: const Center(child: CircularProgressIndicator()),
          fit: BoxFit.contain,
          //backgroundColor: widget.pageColor,
        ),
      ),
    );

    if (imagefile != null && imagefile.containsKey('image_filtered')) {
      if (mounted) {
        setState(() {
          files[0] = XFile((imagefile['image_filtered'] as File).path);
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
    if (placemark.locality!.isNotEmpty && placemark.country!.isNotEmpty) {
      formatedAdress = '${placemark.locality}, ${placemark.country}';
    } else if (placemark.locality!.isNotEmpty) {
      formatedAdress = '${placemark.locality}';
    } else if (placemark.country!.isNotEmpty) {
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
        FlybisPostContent(contentUrl: contentUrl, contentType: contentType.name)
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
        postId = const Uuid().v4();
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
          SizedBox(
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
      preferredSize: const Size.fromHeight(0),
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
        pageHeader: widget.pageHeader,
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
          icon: const Icon(Icons.arrow_back),
          onPressed: clearImage,
        ),
        title: const Text('Caption Post'),
        actions: <Widget>[
          MaterialButton(
            child: const Text('Post'),
            onPressed: isUploading ? null : () => post(),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Stack(
            children: <Widget>[
              SizedBox(
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
                                      child: MaterialButton(
                                        color: Colors.blue,
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.remove_red_eye,
                                              color: Colors.white,
                                            ),
                                            const Text(
                                              'Aplicar Filtros',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
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
                                : const Padding(
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
                                  child: UtilsWidget.iconButton(
                                    color: Colors.blue,
                                    icon: const Icon(
                                      Icons.remove_red_eye,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Editar Vídeo',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    onPressed: () => Get.to(
                                      VideoEditor(file: File(files[0]!.path)),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        : const Text('')),
              ),
              isUploading
                  ? utils_widget.UtilsWidget().linearProgress(context)
                  : const Padding(padding: EdgeInsets.zero),
            ],
          ),
          const Padding(
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
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Write a caption',
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.pin_drop,
                color: Theme.of(context).iconTheme.color, size: 35),
            title: Row(
              children: <Widget>[
                SizedBox(
                  width: 190,
                  child: TextField(
                    controller: locationControler,
                    decoration: const InputDecoration(
                      hintText: 'Where was this photo taken ?',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const Spacer(),
                !kIsWeb
                    ? UtilsWidget.iconButton(
                        color: Colors.blue,
                        icon: const Icon(
                          Icons.pin_drop,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Get Now',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        onPressed: getUserLocation,
                      )
                    : const Padding(padding: EdgeInsets.zero),
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

    if (files.isEmpty) {
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
