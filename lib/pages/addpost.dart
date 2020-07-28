import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:post_adder/models/post_info.dart';
import 'package:post_adder/services/post_uploader.dart';

class AddPost extends StatefulWidget {
  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  List<File> imageList =
      []; //State variable holding the list of images, currently initialized as an empty list
  int imageNumber =
      0; //Number of images and also the index at which the next imageFile has to be added
  File _imageFile; //Active image file
  final picker = ImagePicker();
  PostInfo postInfo = PostInfo();
  String description;
  int price;
  ///////////////
  //These are a class of utility functions
  Future<void> _pickImage(ImageSource source) async {
    //the source can be the camera or the gallery
    PickedFile pickedFile =
        await picker.getImage(source: source); //The file location
    setState(() {
      _imageFile = File(pickedFile.path);
    });
    await _cropImage();
    setState(() {
      imageList.add(_imageFile);
      imageNumber++;
      print('----------IMAGE ADDED----------');
      print('NUMBER OF IMAGES IS $imageNumber');
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
      print(
          '--------------------------In the setState of _cropImage()--------------------------');
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
  void _clear(int index) {
    setState(() {
      _imageFile = null;
      imageList.removeAt(index);
      imageNumber--;
      print('----------IMAGE DELETED at Index $index----------');
      print('NUMBER OF IMAGES IS $imageNumber');
    });
  }

  ///////////////
  @override
  Widget build(BuildContext context) {
//    print('------------Rebuild Initiated----------');
//    File newImage = ModalRoute.of(context).settings.arguments;
//    if (newImage != null) {
//      imageList.add(newImage);
//      print('New Image added to list, list length is at ${imageList.length}');
//    }

    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/homepage');
          },
        ),
        centerTitle: true,
        title: Text('Add a new post'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: GridView.count(
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                crossAxisCount: 2,
                children: <Widget>[
                  if (imageList.length != 0) ...[
                    for (int i = 0; i < imageList.length; i++) ...[
                      Stack(
                        fit: StackFit.expand,
                        alignment: Alignment.center,
                        children: <Widget>[
                          Container(
                            color: Colors.grey[300],
                            child: Image.file(imageList[i]),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              icon: Icon(
                                Icons.close,
                                size: 35,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                _clear(i);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                  if (imageList.length == 0) ...[
                    Container(
                      child: Column(
                        children: <Widget>[
                          Text(
                            'NO IMAGES ADDED, PLEASE ADD IMAGES',
                            style: TextStyle(fontSize: 25.0),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Icon(
                            Icons.image,
                            size: 35.0,
                          ),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),
            TextFormField(
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
              decoration: InputDecoration(
                  hintText: 'Enter Description for the post',
                  border: OutlineInputBorder(gapPadding: 10.0)),
              onChanged: (value) {
                description = value;
              },
            ),
            Divider(),
            TextFormField(
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  hintText: 'Enter Price',
                  border: OutlineInputBorder(gapPadding: 10.0)),
              onChanged: (value) {
                price = int.parse(value);
              },
            ),
            SizedBox(
              height: 20.0,
            ),
            RaisedButton(
              child: Text(
                'Submit',
                style: TextStyle(fontSize: 25.0),
              ),
              onPressed: () {
                //TODO: Add the Images to firebase storage after compression
                //Give them all unique names
                //Add the info about the post to the user's database
                //Update the Posts collection with the post data like Post ID,
                //image Urls, number of images, Date and time of posting , user who posted it
                //price at which it is posted
                postInfo.userEmail = 'abc@test.com';
                postInfo.username = 'Asingh';
                postInfo.longitude = 15.0253;
                postInfo.latitude = 45.2451;
                postInfo.price = price;
                postInfo.description = description;
                postInfo.numberOfImages = imageNumber;
                postInfo.imageList = imageList;
                Post_Uploader post_uploader = Post_Uploader();
                post_uploader.createPostDocument(postInfo);
              },
            ),
            Text('Crop Window'),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey.shade400,
        child: Row(
          children: <Widget>[
            Expanded(
              child: IconButton(
                icon: Icon(Icons.photo_camera),
                color: Color(0xFFE43E9C),
                onPressed: () => _pickImage(ImageSource.camera),
              ),
            ),
            Expanded(
              child: IconButton(
                icon: Icon(Icons.photo_library),
                color: Color(0xFF8952CB),
                onPressed: () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
