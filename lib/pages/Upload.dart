import "dart:io";
import 'dart:math';

import "package:cloud_firestore/cloud_firestore.dart";
import 'package:flybis/models/VideoInfo.dart';
import "package:flybis/plugins/photofilters/photofilters.dart";
import "package:flybis/plugins/image_network/image_network.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import 'package:flybis/services/EncodingProvider.dart';
import 'package:flybis/services/VideoProvider.dart';
import "package:geolocator/geolocator.dart";
import "package:image/image.dart" as Im;
import "package:image_picker/image_picker.dart";
import "package:path_provider/path_provider.dart";
import "package:progress_dialog/progress_dialog.dart";
import 'package:torch_compat/torch_compat.dart';
import "package:uuid/uuid.dart";

import "package:flybis/models/User.dart";
import "package:flybis/widgets/Progress.dart";
import "package:flybis/pages/App.dart";
import "package:flybis/widgets/Utils.dart";

import "package:flybis/widgets/VideoWidget.dart";

import "package:camera/camera.dart";
import "package:video_player/video_player.dart";
import "package:flutter_feather_icons/flutter_feather_icons.dart";

import 'package:path/path.dart' as p;

class Upload extends StatefulWidget {
  final User currentUser;

  final Color pageColor;

  Upload({this.currentUser, this.pageColor});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload>
    with AutomaticKeepAliveClientMixin<Upload> {
  File file;
  String imagePath;
  String videoPath;
  String contentType;
  bool isUploading = false;

  String postId;
  TextEditingController captionControler = TextEditingController();
  TextEditingController locationControler = TextEditingController();

  int indexCamera;
  Color cameraIconColor;
  bool hasCamera = false;
  bool enableFlash = false;
  List<CameraDescription> cameras;
  CameraController cameraController;

  VideoPlayerController videoPlayerController;
  //ChewieController chewieController;

  ProgressDialog progressDialog;

  final thumbWidth = 100;
  final thumbHeight = 150;
  List<VideoInfo> _videos = <VideoInfo>[];
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

  Future<String> _takeVideo(var videoFile) async {
    //if (_debugMode) {
    //videoFile = File(
    //'/storage/emulated/0/Android/data/com.learningsomethingnew.fluttervideo.flutter_video_sharing/files/Pictures/ebbafabc-dcbe-433b-93dd-80e7777ee4704451355941378265171.mp4');
    //} else {
    //if (_imagePickerActive) return;

    //_imagePickerActive = true;
    //videoFile = await ImagePicker.pickVideo(source: ImageSource.camera);
    //_imagePickerActive = false;

    if (videoFile == null) return null;
    //}
    setState(() {
      _processing = true;
    });

    String contentUrl;

    try {
      contentUrl = await _processVideo(videoFile);
    } catch (e) {
      print('${e.toString()}');
    } finally {
      setState(() {
        _processing = false;
      });
    }

    return contentUrl;
  }

  Future<String> _processVideo(File rawVideoFile) async {
    final String rand = '${new Random().nextInt(10000)}';
    final videoName = postId; //'video$rand';
    final Directory extDir = await getApplicationDocumentsDirectory();
    final outDirPath = '${extDir.path}/Videos/$videoName';
    final videosDir = new Directory(outDirPath);
    videosDir.createSync(recursive: true);

    final rawVideoPath = rawVideoFile.path;
    final info = await EncodingProvider.getMediaInformation(rawVideoPath);
    final aspectRatio = EncodingProvider.getAspectRatio(info);

    setState(() {
      _processPhase = 'Generating thumbnail';
      _videoDuration = EncodingProvider.getDuration(info);
      _progress = 0.0;
    });

    final thumbFilePath =
        await EncodingProvider.getThumb(rawVideoPath, thumbWidth, thumbHeight);

    setState(() {
      _processPhase = 'Encoding video';
      _progress = 0.0;
    });

    final encodedFilesDir =
        await EncodingProvider.encodeHLS(rawVideoPath, outDirPath);

    setState(() {
      _processPhase = 'Uploading thumbnail to firebase storage';
      _progress = 0.0;
    });
    final thumbUrl =
        await _uploadFile(thumbFilePath, videoName); //'thumbnail');
    final videoUrl = await _uploadHLSFiles(encodedFilesDir, videoName);

    final videoInfo = VideoInfo(
      contentUrl: videoUrl,
      thumbUrl: thumbUrl,
      coverUrl: thumbUrl,
      aspectRatio: aspectRatio,
      //uploadedAt: DateTime.now().millisecondsSinceEpoch,
      fileName: videoName,
    );

    setState(() {
      _processPhase = 'Saving video metadata to cloud firestore';
      _progress = 0.0;
    });

    await VideoProvider.saveVideo(videoInfo);

    setState(() {
      _processPhase = '';
      _progress = 0.0;
      _processing = false;
    });

    return videoUrl;
  }

  Future<String> _uploadHLSFiles(dirPath, videoName) async {
    final videosDir = Directory(dirPath);

    var playlistUrl = '';

    final files = videosDir.listSync();
    int i = 1;
    for (FileSystemEntity file in files) {
      final fileName = p.basename(file.path);
      final fileExtension = getFileExtension(fileName);
      if (fileExtension == 'm3u8') _updatePlaylistUrls(file, videoName);

      setState(() {
        _processPhase = 'Uploading video file $i out of ${files.length}';
        _progress = 0.0;
      });

      final downloadUrl = await _uploadFile(file.path, videoName);

      if (fileName == 'master.m3u8') {
        playlistUrl = downloadUrl;
      }
      i++;
    }

    return playlistUrl;
  }

  void _updatePlaylistUrls(File file, String videoName) {
    final lines = file.readAsLinesSync();
    var updatedLines = List<String>();

    for (final String line in lines) {
      var updatedLine = line;
      if (line.contains('.ts') || line.contains('.m3u8')) {
        updatedLine = "${widget.currentUser.uid}%2Fposts%2Fvideos%2F" +
            '$videoName%2F$line?alt=media';
      }
      updatedLines.add(updatedLine);
    }
    final updatedContents =
        updatedLines.reduce((value, element) => value + '\n' + element);

    file.writeAsStringSync(updatedContents);
  }

  String getFileExtension(String fileName) {
    final exploded = fileName.split('.');
    return exploded[exploded.length - 1];
  }

  Future<String> _uploadFile(filePath, folderName) async {
    final file = new File(filePath);
    final basename = p.basename(filePath);

    final StorageReference ref = FirebaseStorage.instance
        .ref()
        .child(widget.currentUser.uid + "/posts/videos/")
        .child(folderName)
        .child(basename);
    StorageUploadTask uploadTask = ref.putFile(file);
    uploadTask.events.listen(_onUploadProgress);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String videoUrl = await taskSnapshot.ref.getDownloadURL();
    return videoUrl;
  }

  @override
  void initState() {
    /*VideoProvider.listenToVideos((newVideos) {
      setState(() {
        _videos = newVideos;
      });
    });*/

    EncodingProvider.enableStatisticsCallback((int time,
        int size,
        double bitrate,
        double speed,
        int videoFrameNumber,
        double videoQuality,
        double videoFps) {
      if (_canceled) return;

      setState(() {
        _progress = time / _videoDuration;
      });
    });

    super.initState();

    if (!kIsWeb) {
      initCamera();
    }
  }

  void _onUploadProgress(event) {
    if (event.type == StorageTaskEventType.progress) {
      final double progress =
          event.snapshot.bytesTransferred / event.snapshot.totalByteCount;
      setState(() {
        _progress = progress;
      });
    }
  }

  void initCamera() {
    availableCameras().then((availableCameras) {
      cameras = availableCameras;

      if (cameras.length > 0) {
        if (mounted) {
          setState(() {
            indexCamera = 0;
          });
        }
        initCameraController(cameras[indexCamera]);
        print("Has ${cameras.length.toString()} Cameras Availables");
      } else {
        print("No Cameras Availables");
      }
    }).catchError((onError) {
      print(onError);
    });

    if (cameraController != null) {
      cameraController.initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  Future initCameraController(CameraDescription cameraDescription) async {
    if (cameraController != null) {
      await cameraController.dispose();
    }

    cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
    );

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (cameraController.value.hasError) {
        print("Camera error ${cameraController.value.errorDescription}");
      }
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (error) {
      print(error);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Widget cameraToggle() {
    if (cameras == null || cameras.isEmpty) {
      return Spacer();
    }

    CameraDescription selectedCamera = cameras[indexCamera];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

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
                    .substring(lensDirection.toString().indexOf(".") + 1)[0]
                    .toUpperCase() +
                lensDirection
                    .toString()
                    .substring(lensDirection.toString().indexOf(".") + 1)
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
    if (cameras == null || cameras.isEmpty) {
      return Spacer();
    }

    return Container(
      child: Align(
        alignment: Alignment.centerRight,
        child: FlatButton.icon(
          onPressed: () {
            TorchCompat.turnOn();
          }, //onFlash,
          icon: Icon(
            FeatherIcons.sun,
            color: Colors.white,
          ),
          label: Text(
            "Lanterna",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget cameraGallery() {
    if (cameras == null || cameras.isEmpty) {
      return Spacer();
    }

    return Container(
      child: Align(
        alignment: Alignment.centerRight,
        child: FlatButton.icon(
          onPressed: gallerySelect,
          icon: Icon(
            FeatherIcons.image,
            color: Colors.white,
          ),
          label: Text(
            "Galeria",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  setUuid() {
    postId = Uuid().v4();
  }

  Widget cameraButton() {
    return GestureDetector(
      child: Icon(
        FeatherIcons.aperture,
        size: 100,
        color: cameraIconColor != null ? cameraIconColor : Colors.white,
      ),
      onTap: () => onCaptureImage(context),
      onLongPress: () => startCaptureVideo(),
      onLongPressUp: () => stopCaptureVideo(context),
    );
  }

  IconData getCameraLensIcon(CameraLensDirection direction) {
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
    indexCamera = indexCamera < cameras.length - 1 ? indexCamera + 1 : 0;

    CameraDescription selectedCamera = cameras[indexCamera];

    initCameraController(selectedCamera);
  }

  void onFlash() {
    TorchCompat.turnOn();
    /*if (enableFlash) {
      TorchCompat.turnOff();
      enableFlash = false;
    } else if (!enableFlash) {
      TorchCompat.turnOn();
      enableFlash = true;
    }*/
  }

  void onCaptureImage(context) async {
    setUuid();

    try {
      imagePath = (await getTemporaryDirectory()).path + "/$postId.jpg";

      await cameraController.takePicture(imagePath);

      contentType = "image";
      file = File(imagePath);
    } catch (error) {
      print(error);
    }
  }

  void startCaptureVideo() async {
    setUuid();

    try {
      videoPath = (await getTemporaryDirectory()).path + "/$postId.mp4";

      await cameraController.startVideoRecording(videoPath);

      cameraIconColor = Colors.red;
    } catch (error) {
      print(error);
    }
  }

  void stopCaptureVideo(context) async {
    try {
      await cameraController.stopVideoRecording();

      cameraIconColor = Colors.white;

      contentType = "video";
      file = File(videoPath);

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
    if (!kIsWeb) {
      cameraController?.dispose();
      TorchCompat.dispose();
    }

    super.dispose();
  }

  galleryVideo() async {
    setUuid();

    Navigator.pop(context);

    File file = await ImagePicker.pickVideo(source: ImageSource.gallery);

    if (mounted) {
      setState(() {
        this.contentType = "video";
        this.file = file;
      });
    }
  }

  galleryImage() async {
    setUuid();

    Navigator.pop(context);

    File file = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (mounted) {
      setState(() {
        this.contentType = "image";
        this.file = file;
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
              Icon(FeatherIcons.image),
              Padding(padding: EdgeInsets.all(5)),
              Text("Galeria"),
            ],
          ),
          children: <Widget>[
            SimpleDialogOption(
                child: Row(
                  children: <Widget>[
                    Icon(FeatherIcons.camera),
                    Padding(padding: EdgeInsets.all(5)),
                    Text("Imagem"),
                  ],
                ),
                onPressed: galleryImage),
            SimpleDialogOption(
                child: Row(
                  children: <Widget>[
                    Icon(FeatherIcons.video),
                    Padding(padding: EdgeInsets.all(5)),
                    Text("Vídeo"),
                  ],
                ),
                onPressed: galleryVideo),
            SimpleDialogOption(
              child: Row(
                children: <Widget>[
                  Icon(FeatherIcons.x),
                  Padding(padding: EdgeInsets.all(5)),
                  Text("Cancelar"),
                ],
              ),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  Container buildSplashScreen() {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: RaisedButton(
              onPressed: gallerySelect,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                "Upload Image",
                style: TextStyle(color: Colors.white, fontSize: 22.0),
              ),
              color: Colors.deepOrange,
            ),
          )
        ],
      ),
    );
  }

  Future<String> uploadFile(file) async {
    if (!kIsWeb) {
      StorageUploadTask uploadTask;

      if (contentType == "image") {
        try {
          uploadTask = storageRef
              .child(widget.currentUser.uid + "/posts/images/$postId.jpg")
              .putFile(file, StorageMetadata(contentType: "image/jpeg"));
        } catch (error) {
          print("Image upload error: $error");
        }
      } else if (contentType == "video") {
        try {
          uploadTask = storageRef
              .child(widget.currentUser.uid + "/posts/videos/$postId.mp4")
              .putFile(file, StorageMetadata(contentType: "video/mp4"));
        } catch (error) {
          print("Video upload error: $error");
        }
      }

      uploadTask.events.listen(_onUploadProgress);

      StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
      String downloadUrl = await storageSnap.ref.getDownloadURL();

      return downloadUrl;
    } else {
      return null;
    }
  }

  Future filterImage(context) async {
    var fileName = file.path.split("/").last;
    var image = Im.decodeImage(file.readAsBytesSync());
    image = Im.copyResize(image, width: 600);

    Map imagefile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoFilterSelector(
            title: Text("Photo Filter Example"),
            image: image,
            filters: presetFiltersList,
            filename: fileName,
            loader: Center(child: CircularProgressIndicator()),
            fit: BoxFit.contain,
            backgroundColor: widget.pageColor),
      ),
    );

    if (imagefile != null && imagefile.containsKey("image_filtered")) {
      if (mounted) {
        setState(() {
          file = imagefile["image_filtered"];
        });
      }
    }
  }

  getUserLocation() async {
    Position position = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];

    String formatedAdress;
    if (placemark.locality.length > 0 && placemark.country.length > 0) {
      formatedAdress = "${placemark.locality}, ${placemark.country}";
    } else if (placemark.locality.length > 0) {
      formatedAdress = "${placemark.locality}";
    } else if (placemark.country.length > 0) {
      formatedAdress = "${placemark.country}";
    } else {
      formatedAdress = "Desconhecido";
    }

    locationControler.text = formatedAdress;
  }

  createPostInFirestore({
    String contentUrl,
    String location,
    String description,
  }) {
    postsRef
        .document(widget.currentUser.uid)
        .collection("userPosts")
        .document(postId)
        .setData({
      "id": postId,
      "uid": widget.currentUser.uid,
      "username": widget.currentUser.username,
      "contentUrl": contentUrl,
      "contentType": contentType,
      "description": description,
      "location": location,
      "timestamp": FieldValue.serverTimestamp(),
      "likes": {},
      "likesCount": 0,
      "dislikes": {},
      "dislikesCount": 0,
    });
  }

  handleSubmit() async {
    if (mounted) {
      setState(() {
        isUploading = true;
      });
    }

    progressDialog.show();

    String contentUrl;

    if (contentType == 'video') {
      contentUrl = await _takeVideo(file);
    } else {
      //await compressImage();
      contentUrl = await uploadFile(file);
    }

    createPostInFirestore(
      contentUrl: contentUrl,
      location: locationControler.text,
      description: captionControler.text,
    );
    captionControler.clear();
    locationControler.clear();
    if (mounted) {
      setState(() {
        file = null;
        isUploading = false;
        postId = Uuid().v4();
      });
    }

    progressDialog.hide();
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;

    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());

    final compressedImageFile = File("$path/img_$postId.jpg")
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));

    if (mounted) {
      setState(() {
        file = compressedImageFile;
      });
    }
  }

  clearImage() {
    if (mounted) {
      setState(() {
        file = null;
      });
    }
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.pageColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: clearImage,
        ),
        title: Text("Caption Post"),
        actions: <Widget>[
          FlatButton(
            child: Text("Post"),
            onPressed: isUploading ? null : () => handleSubmit(),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                child: contentType == "image"
                    ? AspectRatio(
                        aspectRatio: MediaQuery.of(context).size.width /
                            (MediaQuery.of(context).size.height * 0.5),
                        child: Stack(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(file),
                                ),
                              ),
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
                                    FeatherIcons.eye,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    "Aplicar Filtros",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  onPressed: () {
                                    filterImage(context);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : (contentType == "video"
                        ? VideoWidget(
                            file: file,
                          ) //adaptiveVideo(context, videoPlayerController)
                        : Text("")),
              ),
              isUploading
                  ? linearProgress()
                  : Padding(padding: EdgeInsets.zero),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: ImageNetwork.cachedNetworkImageProvider(
                widget.currentUser.photoUrl,
              ),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: captionControler,
                decoration: InputDecoration(
                  hintText: "Write a caption",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(FeatherIcons.mapPin, color: Colors.black, size: 35),
            title: Row(
              children: <Widget>[
                Container(
                  width: 190,
                  child: TextField(
                    controller: locationControler,
                    decoration: InputDecoration(
                      hintText: "Where was this photo taken ?",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Spacer(),
                RaisedButton.icon(
                  color: Colors.blue,
                  icon: Icon(
                    Icons.my_location,
                    color: Colors.white,
                  ),
                  label: Text(
                    "Get Now",
                    style: TextStyle(color: Colors.white),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  onPressed: getUserLocation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCamera() {
    final Orientation orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: appBar(),
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: AspectRatio(
              aspectRatio: cameraController.value.aspectRatio,
              child: CameraPreview(
                cameraController,
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

  buildProgressDialog(BuildContext context) {
    progressDialog = new ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
    );

    progressDialog.style(
      message: _processPhase, //"Uploading file...",
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
    );
  }

  Widget appBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(0),
      child: AppBar(
        elevation: 0,
        backgroundColor: widget.pageColor,
      ),
    );
  }

  @override
  get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    buildProgressDialog(context);

    if (file == null) {
      if (!kIsWeb) {
        if (cameraController != null && cameraController.value.isInitialized) {
          return buildCamera();
        } else {
          return Scaffold(
            appBar: appBar(),
            body: Container(color: Colors.black),
          );
        }
      } else {
        return buildSplashScreen();
      }
    } else {
      return buildUploadForm();
    }
  }
}
