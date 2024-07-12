import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

void main() {
  runApp(DigitalBusinessCardApp());
}

class DigitalBusinessCardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Business Card',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BusinessCardPage(),
    );
  }
}

class BusinessCardPage extends StatefulWidget {
  @override
  _BusinessCardPageState createState() => _BusinessCardPageState();
}

class _BusinessCardPageState extends State<BusinessCardPage> {
  String name = '';
  String jobTitle = '';
  String phoneNumber = '';
  String emailAddress = '';
  String location = '';
  bool showCard = false;
  Uint8List? imageForSendToAPI;

  final ImagePicker _imagePicker = ImagePicker();
  final GlobalKey _cardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Business Card'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickProfilePicture,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: imageForSendToAPI != null
                    ? MemoryImage(imageForSendToAPI!)
                    : AssetImage('assets/images/profile.png') as ImageProvider,
                child: imageForSendToAPI == null
                    ? Icon(Icons.add_a_photo, size: 50)
                    : null,
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person),
              ),
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Job Title',
                prefixIcon: Icon(Icons.work),
              ),
              onChanged: (value) {
                setState(() {
                  jobTitle = value;
                });
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
              ),
              onChanged: (value) {
                setState(() {
                  phoneNumber = value;
                });
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email),
              ),
              onChanged: (value) {
                setState(() {
                  emailAddress = value;
                });
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Location',
                prefixIcon: Icon(Icons.location_on),
              ),
              onChanged: (value) {
                setState(() {
                  location = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showCard = true;
                });
              },
              child: Text('Save'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _exportBusinessCard,
              child: Text('Export Business Card'),
            ),
            SizedBox(height: 20),
            if (showCard) _buildBusinessCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessCard() {
    return RepaintBoundary(
      key: _cardKey,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageForSendToAPI != null)
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: MemoryImage(imageForSendToAPI!),
                  ),
                ),
              if (imageForSendToAPI == null)
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text(
                  'Name: $name',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              ListTile(
                leading: Icon(Icons.work),
                title: Text(
                  'Job Title: $jobTitle',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              ListTile(
                leading: Icon(Icons.phone),
                title: Text(
                  'Phone: $phoneNumber',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              ListTile(
                leading: Icon(Icons.email),
                title: Text(
                  'Email: $emailAddress',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              ListTile(
                leading: Icon(Icons.location_on),
                title: Text(
                  'Location: $location',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickProfilePicture() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      final temp = await pickedFile.readAsBytes();
      setState(() {
        imageForSendToAPI = temp;
      });
    }
  }

  Future<void> _exportBusinessCard() async {
    try {
      // Step 1: Create a `RenderRepaintBoundary` to capture the card as an image.
      RenderRepaintBoundary boundary =
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Step 2: Get the external storage directory.
      Directory? directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw FileSystemException('Failed to get external storage directory.');
      }

      // Step 3: Save the image to the external storage.
      String fileName =
          "business_card_${DateTime.now().millisecondsSinceEpoch}.png";
      String filePath = '${directory.path}/$fileName';
      File file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // Step 4: Show a snackbar to indicate success and allow opening the file.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Business card exported successfully!'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () {
              OpenFile.open(filePath);
            },
          ),
        ),
      );
    } catch (e) {
      // Handle errors here.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export business card: $e'),
        ),
      );
    }
  }
}
