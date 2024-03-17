import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:food_recognition/screens/review_screen.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Upload App',
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
  List<File> _images = [];

  Future<void> _getImageFromCamera() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  Future<void> _getImageFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  bool _isNextButtonEnabled() {
    return _images.isNotEmpty;
  }

  Future<void> _copyImagesToAssets() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String assetsDirPath = '${appDocDir.path}/assets/images/toUpload';

    // Create assets/images directory if it doesn't exist
    final Directory assetsDir = Directory(assetsDirPath);
    if (!await assetsDir.exists()) {
      await assetsDir.create(recursive: true);
    }

    for (int i = 0; i < _images.length; i++) {
      final String imageName = 'image_$i.jpg';
      final File newImage = await _images[i].copy('$assetsDirPath/$imageName');
    }

    // Navigate to next screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NextScreen()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Upload'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              'Demo Food Recognition',
              style: TextStyle(fontSize: 24.0),
            ),
          ),
          SizedBox(height: 150),
          Expanded(
            child: _images.isEmpty
                ? Center(child: Text('Selecciona imagenes'))
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.all(8.0),
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          image: FileImage(_images[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.delete_outline),
                        onPressed: () {
                          _removeImage(index);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 200),
            // Adjust max height as needed
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ElevatedButton(
                      onPressed: _getImageFromCamera,
                      child: Text('Camera'),
                    ),
                    SizedBox(width: 50),
                    ElevatedButton(
                      onPressed: _getImageFromGallery,
                      child: Text('Gallery'),
                    )
                  ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _isNextButtonEnabled()
                            ? _copyImagesToAssets
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 24.0),
                          child: Text(
                            'Continuar',
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

