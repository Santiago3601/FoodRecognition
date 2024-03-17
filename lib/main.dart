import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Upload Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImageUploadScreen(),
    );
  }
}

class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  final picker = ImagePicker();
  File? _image;

  Future getImageFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future getImageFromGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadImage() async {
    if (_image == null) {
      print('No image selected.');
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('YOUR_API_ENDPOINT'),
    );
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Image uploaded successfully');
    } else {
      print('Failed to upload image. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Recognition App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? Text('No image selected.')
                : Image.file(_image!),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: getImageFromCamera,
              child: Text('Take Photo'),
            ),
            ElevatedButton(
              onPressed: getImageFromGallery,
              child: Text('Choose from Gallery'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploadImage,
              child: Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}
