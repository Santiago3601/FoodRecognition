import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class NextScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Uploader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImageUploader(),
    );
  }
}
class ImageUploader extends StatefulWidget {
  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  final String serverUrl = "https://api.logmeal.es/v2/image/segmentation/complete/v1.0";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Uploader"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await uploadImages();
          },
          child: Text('Upload Images'),
        ),
      ),
    );
  }

  Future<void> uploadImages() async {
    // Replace 'YOUR_TOKEN_HERE' with your actual token
    String token = '168044cd5c0cc81208d8481e38ec7c8aa8336097';
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory imagesDir  = Directory('${appDocDir.path}/assets/images/toUpload');

    List<FileSystemEntity> files = imagesDir.listSync();

    for (FileSystemEntity file in files) {
      if (file is File) {
        String fileName = path.basename(file.path);
        if (fileName.endsWith('.jpg') || fileName.endsWith('.png')) {
          // String url = '$serverUrl/upload';
          var request = http.MultipartRequest('POST', Uri.parse(serverUrl));
          request.headers['Authorization'] = 'Bearer $token';
          request.fields['language'] = 'spa'; // Add your parameters here
          // request.fields['param2'] = 'value2'; // Add more parameters if needed
          request.files.add(await http.MultipartFile.fromPath('image', file.path));

          http.StreamedResponse response = await request.send();

          if (response.statusCode == 200) {
            // Save JSON response
            String responseBody = await response.stream.bytesToString();
            Directory jsonDir = await getApplicationDocumentsDirectory();
            // Create assets/images directory if it doesn't exist
            final Directory assetsDir = Directory('${jsonDir.path}/$fileName.json');
            if (!await assetsDir.exists()) {
              await assetsDir.create(recursive: true);
            }

            File jsonFile = File('${jsonDir.path}/$fileName.json');
            jsonFile.writeAsString(responseBody);

            print('Uploaded $fileName successfully');
          } else {
            print('Failed to upload $fileName');
          }
        }
      }
    }
  }
}