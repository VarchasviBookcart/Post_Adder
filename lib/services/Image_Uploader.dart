import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Uploader extends StatefulWidget {
  final File file; //the file to be uploaded
  final String filepath; //the filepath name with which it will be uploaded
  Uploader({Key key, this.file, this.filepath}) : super(key: key);
  //this takes 2 parameters, the file and the filepath
  @override
  _UploaderState createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  final FirebaseStorage _storage = FirebaseStorage(
      storageBucket: 'gs://fir-image-storage-c5c34.appspot.com/');
  //this url is the url at which the data is stored in firebase
  StorageUploadTask
      _uploadTask; //provides current state of the upload as well as the event stream required to update the UI

  void _startUpLoad() async {
    int compressionQuality = 80;
    int fileSize = widget.file.lengthSync(); //size of file in bytes
    /* The widget.file is used to get the argument from the
    * above Stateful class into this State */
    String filepath = 'images/' + widget.filepath + '.png';
    /*Here widget.filepath can be the user's email address, or anything unique

    * */
    //'images/${DateTime.now()}.png'; //unique file path required in the bucket for all uploads.
    //here we are using the current date and time. We can also use something else, something like user id
    print('\n\nFILE SIZE BEFORE COMPRESSION IN BYTES : $fileSize\n\n');
    if (fileSize > 5000000) // >5MB
    {
      compressionQuality = 60;
    } else if (fileSize > 3000000) //3MB-5MB
    {
      compressionQuality = 70;
    }

    await FlutterNativeImage.compressImage(widget.file.path,
            quality: compressionQuality,
            percentage: 100) //actual compression being done.
        .then((value) {
      setState(() {
        _uploadTask = _storage
            .ref()
            .child(filepath)
            .putFile(value); //after compression completes the upload is started
        //This is the actual method which starts the upload
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_uploadTask != null) {
      return StreamBuilder<StorageTaskEvent>(
        stream: _uploadTask.events,
        builder: (context, snapshot) {
          var event = snapshot?.data?.snapshot;
          /*
           *Conditional property access
           *To guard access to a property or method of an object that might be null,
           *put a question mark (?) before the dot (.):
           *myObject?.someProperty
           *The preceding code is equivalent to the following:
           *(myObject != null) ? myObject.someProperty : null*/
          double progresspercent = (event != null)
              ? (event.bytesTransferred / event.totalByteCount)
              : 0;
          return Column(
            children: <Widget>[
              if (_uploadTask.isComplete) ...[
                Text(
                  '🎉🎉🎉',
                  style: TextStyle(fontSize: 25),
                ),
                Text(
                  'Upload Completed !',
                  style: TextStyle(fontSize: 25),
                ),
              ],
              if (_uploadTask.isPaused)
                FlatButton(
                  child: Icon(Icons.play_arrow),
                  onPressed: _uploadTask.resume,
                ),
              if (_uploadTask.isInProgress)
                FlatButton(
                  child: Icon(Icons.pause),
                  onPressed: _uploadTask.pause,
                ),
              CircularProgressIndicator(
                backgroundColor: Colors.grey.shade400,
                value: progresspercent,
              ),
              SizedBox(
                height: 5.0,
              ),
              Text('${(progresspercent * 100).toStringAsFixed(2)} % '),
            ],
          );
        },
      );
    } else {
      //uploading is not in progress
      List<Widget> displayWidget = [];
      if (widget.file.lengthSync() > 2000000) //>2MB
      {
        displayWidget.add(
          Text(
            'PLEASE UPLOAD IMAGE OF FILE SIZE LESS THAN 2MB FOR FASTER UPLOAD',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        );
      }
      displayWidget.add(
        FlatButton(
          child: Icon(
            Icons.cloud_upload,
            semanticLabel: 'Click to Upload',
          ),
          onPressed: _startUpLoad,
        ),
      );

      return Column(
        children: displayWidget,
      );
    }
  }
}
