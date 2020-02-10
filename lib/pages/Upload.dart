import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flybis/packages/photofilters/lib/photofilters.dart';
import 'package:flybis/plugins/image_network/image_network.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:flybis/models/User.dart';
import 'package:flybis/widgets/Progress.dart';
import 'package:flybis/pages/Home.dart';

import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class Upload extends StatefulWidget {
  final User currentUser;

  final Color pageColor;

  Upload({this.currentUser, this.pageColor});

  @override
  _UploadState createState() => _UploadState();
}

enum FileMode { IMAGE, VIDEO }

class _UploadState extends State<Upload>
    with AutomaticKeepAliveClientMixin<Upload> {
  File file;
  String imagePath;
  String videoPath;
  FileMode fileMode;
  bool isUploading = false;

  String postId = Uuid().v4();
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

  @override
  void initState() {
    super.initState();

    initCamera();
  }

  void initCamera() {
    availableCameras().then((availableCameras) {
      cameras = availableCameras;

      if (cameras.length > 0) {
        setState(() {
          indexCamera = 0;
        });
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
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    }
  }

  Future initCameraController(CameraDescription cameraDescription) async {
    if (cameraController != null) {
      await cameraController.dispose();
    }

    // 3
    cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.ultraHigh,
    );

    // If the controller is updated then update the UI.
    // 4
    cameraController.addListener(() {
      // 5
      if (mounted) {
        setState(() {});
      }

      if (cameraController.value.hasError) {
        print('Camera error ${cameraController.value.errorDescription}');
      }
    });

    // 6
    try {
      await cameraController.initialize();
    } on CameraException catch (error) {
      // _showCameraException(e);
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
    if (cameras == null || cameras.isEmpty) {
      return Spacer();
    }

    return Container(
      child: Align(
        alignment: Alignment.centerRight,
        child: FlatButton.icon(
          onPressed: onFlash,
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
          onPressed: handleChooseFromGallery,
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
    if (enableFlash) {
      enableFlash = false;
    } else if (!enableFlash) {
      enableFlash = true;
    }
  }

  void onCaptureImage(context) async {
    try {
      imagePath =
          (await getTemporaryDirectory()).path + '/' + '${DateTime.now()}.jpg';

      await cameraController.takePicture(imagePath);

      fileMode = FileMode.IMAGE;
      file = File(imagePath);

      /*Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Image.file(File(imagePath)),
        ),
      );*/

    } catch (error) {
      print(error);
    }
  }

  void startCaptureVideo() async {
    try {
      videoPath =
          (await getTemporaryDirectory()).path + '/' + '${DateTime.now()}.mp4';

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

      fileMode = FileMode.VIDEO;
      file = File(videoPath);

      videoPlayerController = VideoPlayerController.file(File(videoPath))
        ..initialize();
      videoPlayerController.play();
    } catch (error) {
      print(error);
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();

    super.dispose();
  }

  handleTakePhoto() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
        source: ImageSource.camera, maxWidth: 960, maxHeight: 675);
    setState(() {
      this.file = file;
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxWidth: 960, maxHeight: 675);
    setState(() {
      this.file = file;
    });
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text('Create Post'),
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Photo with Camera'),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: Text('Image from Gallery'),
                onPressed: handleChooseFromGallery,
              ),
              SimpleDialogOption(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  Container buildSplashScreen() {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset('assets/images/upload.svg', height: 260),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: RaisedButton(
              onPressed: () => selectImage(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'Upload Image',
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

      if (fileMode == FileMode.IMAGE) {
        uploadTask = storageRef
            .child(widget.currentUser.id + "/posts/images/post_$postId.jpg")
            .putFile(file);
      } else if (fileMode == FileMode.VIDEO) {
        uploadTask = storageRef
            .child(widget.currentUser.id + "/posts/videos/post_$postId.mp4")
            .putFile(file);
      }

      StorageTaskSnapshot storageSnap = await uploadTask.onComplete;

      String downloadUrl = await storageSnap.ref.getDownloadURL();

      return downloadUrl;
    }

    return null;
  }

  Future filterImage(context) async {
    var fileName = file.path.split("/").last;
    var image = Im.decodeImage(file.readAsBytesSync());
    image = Im.copyResize(image, width: 600);
    Map imagefile = await Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new PhotoFilterSelector(
          title: Text("Photo Filter Example"),
          image: image,
          filters: presetFiltersList,
          filename: fileName,
          loader: Center(child: CircularProgressIndicator()),
          fit: BoxFit.contain,
        ),
      ),
    );
    if (imagefile != null && imagefile.containsKey('image_filtered')) {
      setState(() {
        file = imagefile['image_filtered'];
      });
      print(file.path);
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
    String mediaUrl,
    String location,
    String description,
  }) {
    postsRef
        .document(widget.currentUser.id)
        .collection('userPosts')
        .document(postId)
        .setData({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "username": widget.currentUser.username,
      "mediaUrl": mediaUrl,
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
    setState(() {
      isUploading = true;
    });

    await compressImage();
    String mediaUrl = await uploadFile(file);

    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationControler.text,
      description: captionControler.text,
    );
    captionControler.clear();
    locationControler.clear();

    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.pageColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: clearImage,
        ),
        title: Text(
          "Caption Post",
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Post',
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0),
            ),
            onPressed: isUploading ? null : () => handleSubmit(),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Padding(padding: EdgeInsets.zero),
          Container(
            width: MediaQuery.of(context).size.width,
            child: fileMode == FileMode.IMAGE
                ? AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(file),
                        ),
                      ),
                    ),
                  )
                : (fileMode == FileMode.VIDEO
                    ? AspectRatio(
                        aspectRatio:
                            videoPlayerController.value.aspectRatio * 0.7,
                        child: Container(
                          child: VideoPlayer(
                            videoPlayerController,
                          ),
                        ),
                      )
                    : Text("")),
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
                    hintText: 'Write a caption', border: InputBorder.none),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35,
            ),
            title: Container(
              width: 280,
              child: TextField(
                controller: locationControler,
                decoration: InputDecoration(
                    hintText: 'Where was this photo taken ?',
                    border: InputBorder.none),
              ),
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              color: Colors.blue,
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
              label: Text(
                'Use Current Location',
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              onPressed: getUserLocation,
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              color: Colors.blue,
              icon: Icon(
                FeatherIcons.star,
                color: Colors.white,
              ),
              label: Text(
                "Filtrar Imagem",
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              onPressed: () {
                filterImage(context);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget buildCamera() {
    final Orientation orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          backgroundColor: widget.pageColor,
        ),
      ),
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

  get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (file == null) {
      if (!kIsWeb) {
        if (cameraController != null && cameraController.value.isInitialized) {
          return buildCamera();
        } else {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(0),
              child: AppBar(
                backgroundColor: widget.pageColor,
              ),
            ),
            body: Container(
              color: Colors.black,
            ),
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
