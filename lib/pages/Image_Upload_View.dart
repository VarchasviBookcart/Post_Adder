import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:post_adder/services/Image_Uploader.dart';

class ImageCapture extends StatefulWidget {
  //Captures an image from the gallery or camera
  @override
  _ImageCaptureState createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {
  File _imageFile; //Active image file
  String _imageFileName;
  final picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    //the source can be the camera or the gallery
    PickedFile pickedFile = await picker.getImage(source: source);
    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }

  Future<void> _cropImage() async {
    File _cropped = await ImageCropper.cropImage(
      sourcePath: _imageFile.path,
      androidUiSettings: AndroidUiSettings(
        toolbarColor: Colors.blueAccent,
        toolbarWidgetColor: Colors.white,
        toolbarTitle: 'Crop It',
      ),
    );

    setState(() {
      _imageFile = _cropped ?? _imageFile;
      /***********************
       * Null-aware operators
       * Dart offers some handy operators for dealing with values that might be null.
       *  One is the ??= assignment operator, which assigns a value to a variable only
       *  if that variable is currently null:
       *  For our case it means that is cropped is null, that is the user cancels the
       *  modifications then the existing image file is returned
       * **********************/
    });
  }

  //remove Image
  void _clear() {
    setState(() {
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('ADD IMAGE'),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/addpost');
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey.shade700,
        child: Row(
          children: <Widget>[
            Expanded(
              child: IconButton(
                icon: Icon(Icons.photo_camera),
                color: Colors.yellowAccent,
                onPressed: () => _pickImage(ImageSource.camera),
              ),
            ),
            Expanded(
              child: IconButton(
                icon: Icon(Icons.photo_library),
                color: Colors.redAccent,
                onPressed: () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          if (_imageFile != null) ...[
            Image.file(
              _imageFile,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    child: Icon(Icons.crop),
                    onPressed: _cropImage,
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    child: Icon(Icons.clear),
                    onPressed: _clear,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                autofocus: true,
                maxLines: 1,
                decoration: InputDecoration(hintText: 'ENTER NAME FOR IMAGE'),
                onFieldSubmitted: (value) {
                  setState(() {
                    _imageFileName = value;
                  });
                },
              ),
            ),
            if (_imageFileName != null)
              Uploader(
                file: _imageFile,
                filepath: _imageFileName,
              ), //uploads image to Firebase
          ],
        ],
      ),
    );
  }
}
