import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth auth = FirebaseAuth.instance;
User? user = auth.currentUser;
String uid = user!.uid;

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String imageUrl = "";

  @override
  void initState() {
    super.initState();
    defaultImage();
  }

  Future<void> defaultImage() async {
    firebase_storage.Reference storageRef = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('Final/Handing.png');
    String url = await storageRef.getDownloadURL();
    setState(() {
      imageUrl = url;
    });

    var response = await http.get(Uri.parse(url));
    var imageData = response.bodyBytes;

    firebase_storage.Reference newRef = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('Final/Handong.png');

    await newRef.putData(imageData);

    print('Image uploaded to new reference');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add', style: TextStyle(fontSize: 20)),
        centerTitle: true,
        leading: Flexible(
          child: TextButton(
            child: const Text('Cancel', style: TextStyle(fontSize: 10)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Save'),
            onPressed: () async {
              if (_image != null) {
                firebase_storage.Reference storageReference = firebase_storage
                    .FirebaseStorage.instance
                    .ref()
                    .child('Final/' + nameController.text + '.png');

                await storageReference.putFile(File(_image!.path));
                String downloadUrl = await storageReference.getDownloadURL();

                FirebaseFirestore.instance.collection('info').add({
                  'name': nameController.text,
                  'price': double.parse(priceController.text),
                  'description': descriptionController.text,
                  'uid': uid,
                  'timestamp': FieldValue.serverTimestamp(),
                  'url': downloadUrl,
                });

                FirebaseFirestore.instance
                    .collection('users')
                    .add({'name': nameController.text, 'count': 0});
              } else {
                defaultImage();
              }
            },
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          _image == null
              ? Image.network(
                  imageUrl,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return const Center(
                        child: Icon(Icons.circle_outlined, size: 100));
                  },
                )
              : Image.file(File(_image!.path)),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: () async {
                final image =
                    await _picker.pickImage(source: ImageSource.gallery);
                setState(() {
                  _image = image;
                });
              },
            ),
          ),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Product Name'),
          ),
          TextField(
            controller: priceController,
            decoration: const InputDecoration(hintText: 'Price'),
          ),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(hintText: 'Description'),
          ),
        ],
      ),
    );
  }
}
