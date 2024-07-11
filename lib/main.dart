import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
                  showCard = true; // 顯示名片
                });
              },
              child: Text('Save'),
            ),
            SizedBox(height: 20),
            // 如果 showCard 為 true，則顯示名片
            if (showCard) _buildBusinessCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessCard() {
    return Card(
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
}
