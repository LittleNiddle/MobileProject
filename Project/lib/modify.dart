import 'dart:io';
import 'package:flutter/material.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

var imageUrl;
var price;
var description;

class EditPage extends StatefulWidget {
  const EditPage({Key? key}) : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  @override
  void initState() {
    super.initState();
  }

  XFile? _image;
  String downloadURL = "";

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    String cuid = user!.uid;

    final String name = ModalRoute.of(context)!.settings.arguments as String;
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final ImagePicker imagePicker = ImagePicker();
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    void removeItem(String name) async {
      FirebaseFirestore.instance.collection('wishlists').doc(cuid).update({
        'items': FieldValue.arrayRemove([name])
      }).then((_) {
        print("value removed successfully");
      }).catchError((error) {
        print("Failed to remove value: $error");
      });
    }

    void getCloud(String product) async {
      var snapShot = await FirebaseFirestore.instance
          .collection('info')
          .where('name', isEqualTo: product)
          .get();

      var doc = snapShot.docs.first;
      price = doc['price'];
      description = doc['description'];
      imageUrl = doc['url'];

      await DefaultCacheManager().removeFile(imageUrl);
    }

    getCloud(name);

    firebase_storage.Reference storageRef = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('Final/' + name + '.png');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit', style: TextStyle(fontSize: 20)),
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
              removeItem(name);
              storageRef.delete();
              firebase_storage.Reference storageReference = firebase_storage
                  .FirebaseStorage.instance
                  .ref()
                  .child('Final/' + nameController.text + '.png');

              await storageReference.putFile(File(_image!.path));
              String downloadUrl = await storageReference.getDownloadURL();

              await firestore
                  .collection('info')
                  .where('name', isEqualTo: name)
                  .get()
                  .then((querySnapshot) {
                querySnapshot.docs.forEach((doc) {
                  doc.reference.update({
                    'name': nameController.text,
                    'price': double.parse(priceController.text),
                    'description': descriptionController.text,
                    'timestampM': FieldValue.serverTimestamp(),
                    'url': downloadUrl
                  });
                });
              });
              await firestore
                  .collection('users')
                  .where('name', isEqualTo: name)
                  .get()
                  .then((querySnapshot) {
                querySnapshot.docs.forEach((doc) {
                  doc.reference.update({
                    'name': nameController.text,
                  });
                });
              });

              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView(children: [
        FutureBuilder<String>(
          future: storageRef.getDownloadURL(),
          builder:
              (BuildContext context, AsyncSnapshot<String> imageUrlSnapshot) {
            if (imageUrlSnapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (imageUrlSnapshot.hasError) {
              return Text('Error: ${imageUrlSnapshot.error}');
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 18 / 11,
                      child: _image == null
                          ? Image.network(imageUrl)
                          : Image.file(File(_image!.path)),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: () async {
                          final image = await imagePicker.pickImage(
                              source: ImageSource.gallery);
                          setState(() {
                            _image = image;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 1, 1),
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              TextField(
                                controller: nameController,
                                decoration: InputDecoration(hintText: name),
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              TextField(
                                controller: priceController,
                                decoration:
                                    InputDecoration(hintText: price.toString()),
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 20.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const SizedBox(height: 5),
                          TextField(
                            controller: descriptionController,
                            decoration: InputDecoration(hintText: description!),
                          ),
                        ]),
                  ),
                ),
              ],
            );
          },
        ),
      ]),
    );
  }
}
