import 'dart:io';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:post_adder/models/post_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Post_Uploader {
  final FirebaseStorage _storage = FirebaseStorage(
      storageBucket: 'gs://fir-image-storage-c5c34.appspot.com/');
  StorageUploadTask _uploadTask;

  createPostDocument(PostInfo postInfo) async {
    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint postLocation;
    postLocation =
        geo.point(latitude: postInfo.latitude, longitude: postInfo.longitude);

    DocumentReference docref =
        Firestore.instance.collection('posts').document();
    await docref.setData({
      'name': postInfo.username,
      'description': postInfo.description,
      'email': postInfo.userEmail,
      'price': postInfo.price,
      'postID': docref.documentID,
      'postedTime': DateTime.now(),
      'postLocation': postLocation.data,
      'numberofImages': postInfo.numberOfImages,
    }); //First add basic info to the posts document

    List<String> imageUrls = await _getImageUrls(postInfo.imageList,
        docref.documentID, postInfo); //first we get the image urls

    await docref.updateData({
      'imageUrls': FieldValue.arrayUnion(imageUrls)
    }); //add the imageUrls as an update
  }

  Future<List<String>> _getImageUrls(
      List<File> imageFiles, String postID, PostInfo postInfo) async {
    //This function should upload the images one by one and
    //simultaneously get the download url for each and save them to the list
    String url = '';
    List<String> urls = [];
    for (int i = 0; i < imageFiles.length; i++) {
      url = await uploadImage(imageFiles[i],
          postInfo.userEmail + '_' + postID + '_0' + i.toString());
      //filepath = asingh@test.com_postID_00
      urls.add(url);
    }

    return urls;
  }

  Future<String> uploadImage(File image, String imageFilePath) async {
    String url = '';
    int compressionQuality = 80;
    int fileSize = image.lengthSync();
    String filepath = imageFilePath + '.png';
    print('\n\nFILE SIZE BEFORE COMPRESSION IN BYTES : $fileSize\n\n');
    //Compression according to file size
    if (fileSize > 5000000) // >5MB
    {
      compressionQuality = 60;
    } else if (fileSize > 3000000) //3MB-5MB
    {
      compressionQuality = 70;
    }
    StorageReference ref;
    //Compression and then upload
    await FlutterNativeImage.compressImage(image.path,
            quality: compressionQuality,
            percentage: 100) //actual compression being done.
        .then((value) {
      print(
          'COMPRESSION COMPLETE, WILL NOW BEGIN UPLOAD*****************************************************');
      _uploadTask =
          _storage.ref().child('post_images/' + filepath).putFile(value);
      print(
          'UPLOAD COMPLETE*****************************************************');
    });
    print(
        'Trying to get the download Url *****************************************************');
    ref = _storage.ref().child('post_images').child(filepath);
    print(
        'Ref initialized with ************************************************************');
    print(ref.path);
    print('Waiting for 5 seconds');
    await Future.delayed(Duration(seconds: 5));
    print('WAIT FOR 5 seconds over');
    url = await ref.getDownloadURL();
    print('URL $url *****************************************************');
    return url;
  }
}
