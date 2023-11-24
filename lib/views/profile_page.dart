// ...

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userPhoto;

  Future<void> _uploadPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        userPhoto = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: GestureDetector(
                onTap: _uploadPhoto,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: userPhoto != null
                      ? FileImage(File(userPhoto!))
                      : const NetworkImage(
                              'https://upload.wikimedia.org/wikipedia/commons/8/89/Portrait_Placeholder.png')
                          as ImageProvider,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Tap to upload your photo'),
            const SizedBox(height: 20),
            buildProfileDetail('Name', "Ranjeet Kumar"),
            buildProfileDetail('Gender', "Male"),
            buildProfileDetail('Email', "example@gmail.com"),
            buildProfileDetail('Phone', "+91 9876543210"),
          ],
        ),
      ),
    );
  }

  Widget buildProfileDetail(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:   ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value ?? 'Not provided'),
        ],
      ),
    );
  }
}

// ...
